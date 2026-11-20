#!/usr/bin/env python3
"""
doc_sync.py: generate documentation from source PRs and open a doc PR.

Reads open PRs from os-migrate source repositories, filters out release/version
bumps, asks Claude to generate AsciiDoc content for user-visible changes, then
creates a pull request in the documentation repository.

The documentation uses modular topic files (con_/proc_/ref_) assembled by
index.adoc. To keep generated content inside the published documentation, the
script builds a catalog of every file reachable from index.adoc through
include:: directives, lets Claude choose targets from that catalog only, and
validates every proposed change before pushing anything.

The script must run from a checkout of the documentation repository default
branch: the catalog and the generated changes are computed from the local files.

Required env vars:
  OSM_GITHUB_TOKEN            GitHub token (write access to DOCS_REPO, read to source repos)
  ANTHROPIC_VERTEX_PROJECT_ID Vertex AI project ID
  GOOGLE_APPLICATION_CREDENTIALS_JSON  Service account JSON (or GOOGLE_APPLICATION_CREDENTIALS)
Optional env vars:
  SOURCE_ORG    GitHub org that owns the source repos (default: os-migrate)
  TARGET_REPOS  Comma-separated list of source repos (default: vmware-migration-kit,os-migrate)
  DAYS_BACK     How many days back to scan (default: 1)
  DOCS_REPO     Full repo name for the documentation repo (default: os-migrate/documentation)
  DRY_RUN       Set to "true" to skip PR creation (default: false)
  DOCS_ROOT     Path of the documentation checkout (default: current directory)
"""

import json
import os
import re
import subprocess
import sys
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path, PurePosixPath

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SOURCE_ORG = os.getenv("SOURCE_ORG", "os-migrate")
TARGET_REPOS = os.getenv("TARGET_REPOS", "vmware-migration-kit,os-migrate").split(",")
DAYS_BACK = int(os.getenv("DAYS_BACK", "1"))
DOCS_REPO = os.getenv("DOCS_REPO", "os-migrate/documentation")
DRY_RUN = os.getenv("DRY_RUN", "false").lower() == "true"
DOCS_ROOT = Path(os.getenv("DOCS_ROOT", ".")).resolve()

ROOT_DOCUMENT = "index.adoc"

# Directories that hold the modular guides, with a description for the prompt
# and the anchor prefix used by topics in that directory.
GUIDES = {
    "source/vmware": {
        "description": "VMware to OpenStack guide, for the os_migrate.vmware_migration_kit collection "
        "(source repo: vmware-migration-kit)",
        "anchor_infix": "vmw-",
    },
    "source/os-to-os": {
        "description": "OpenStack to OpenStack guide, for the os_migrate.os_migrate collection "
        "(source repo: os-migrate)",
        "anchor_infix": "osts-",
    },
    "source/shared": {
        "description": "Common reference included by both guides: migrator host, conversion host concepts, "
        "collection installation, glossary",
        "anchor_infix": "",
    },
}

TOPIC_NAME_RE = re.compile(r"^(con|proc|ref)_[a-z0-9]+(?:-[a-z0-9]+)*\.adoc$")
CONTENT_TYPES = {"con": "CONCEPT", "proc": "PROCEDURE", "ref": "REFERENCE"}
INCLUDE_RE = re.compile(r"^include::([^\[]+)\[([^\]]*)\]\s*$", re.MULTILINE)
ID_RE = re.compile(r'^\[id="([^"]+)"\]', re.MULTILINE)
XREF_RE = re.compile(r"xref:([A-Za-z0-9_.-]+)\[")
TITLE_RE = re.compile(r"^=\s+(.+)$", re.MULTILINE)
HEADING_RE = re.compile(r"^(={2,4})\s+(.+)$", re.MULTILINE)

MAX_TARGET_FILES = 4

# Files whose presence (exclusively) marks a PR as a release bump.
RELEASE_ONLY_FILES = frozenset(
    {
        "CHANGELOG.md",
        "CHANGELOG.rst",
        "CHANGES.rst",
        "galaxy.yml",
        "go.mod",
        "go.sum",
        "package.json",
        "package-lock.json",
        "pyproject.toml",
        "setup.cfg",
        "setup.py",
        "VERSION",
        "version.py",
        "Cargo.toml",
        "Cargo.lock",
    }
)

# Regex patterns against PR *title* that indicate a release bump.
RELEASE_TITLE_PATTERNS = [
    re.compile(r"(?i)^release\s+v?\d+\.\d+"),
    re.compile(r"(?i)^bump\s+(version|v)\s*\d"),
    re.compile(r"(?i)^chore[\s:]+release"),
    re.compile(r"(?i)^prepare\s+v?\d+\.\d+"),
    re.compile(r"(?i)^v\d+\.\d+\.\d+(\s|$)"),
    re.compile(r"(?i)^\[release\]"),
    re.compile(r"(?i)^version\s+bump"),
    re.compile(r"(?i)^(bump|update)\s+.*version"),
    re.compile(r"(?i)^bump\s+(major|minor|patch)?\s*release"),
]

CLAUDE_MODEL = "claude-sonnet-4-5"

SYSTEM_PROMPT = """You are a technical documentation writer for the OS Migrate project, an open source Ansible toolbox for parallel cloud migration (VMware to OpenStack, and OpenStack to OpenStack).

The documentation repository is written in AsciiDoc and published as a single HTML page built from index.adoc. It is organised in modular-docs topic files:
- source/vmware/      VMware to OpenStack guide (os_migrate.vmware_migration_kit collection), assembled by assembly_vmware-migration.adoc
- source/os-to-os/    OpenStack to OpenStack guide (os_migrate.os_migrate collection), assembled by assembly_os-to-os-migration.adoc
- source/shared/      Topics included by both guides, assembled by assembly_common-reference.adoc
- source/reference-module-*.adoc and source/reference-role-*.adoc  os_migrate.os_migrate module and role reference

Only files listed in the documentation catalog you receive are published. Any other path, for example a source/operator-*.adoc file or a source/developer-*.adoc file, is NOT published and must never be used.

Topic file conventions:
- File names start with con_ (concept), proc_ (procedure), or ref_ (reference), followed by kebab-case words.
- Each topic file starts with:
    :_mod-docs-content-type: CONCEPT|PROCEDURE|REFERENCE
    [id="<prefix>_<guide>-<kebab-name>"]
    = Title
  followed by an abstract paragraph marked with [role="_abstract"].
  Anchor examples: ref_vmw-custom-nbdkit-plugin (VMware guide), proc_osts-migrating-workloads (OpenStack guide), con_conversion-host (shared).
- Inside a topic, subsections use == and ===, each preceded by its own unique [id="..."] anchor.
- Procedures use .Prerequisites and .Procedure block titles with numbered steps (". Step").
- Code blocks use [source,yaml] / [source,bash] followed by ---- delimiters. Tables use |=== with a header row. Variable lists use `name`:: definitions.
- Cross-reference existing content with xref:<anchor>[] instead of duplicating it. Only use anchors that exist in the catalog or that you define.
- Write intemporally: describe how the product behaves, not what is "new", "now", or "added in this PR". Do not use em dashes or decorative icons.

When a PR introduces user-visible changes (new features, new variables, new playbooks, changed behaviour, new requirements), document what changed and how to use it, in the guide that matches the collection of the source repository. Prefer extending the existing topic that covers the feature. Create a new topic only when no existing topic fits.

Skip documentation for: pure CI changes, internal refactoring with no user-visible impact, test-only changes, release or version bumps, dependency version bumps with no user-visible impact, typo fixes in existing source-repo docs, and changes already covered by the existing documentation."""


# ---------------------------------------------------------------------------
# Documentation catalog
# ---------------------------------------------------------------------------


def _rel(path: Path) -> str:
    return path.resolve().relative_to(DOCS_ROOT).as_posix()


def build_catalog(root_document: str = ROOT_DOCUMENT) -> dict:
    """Return {path: info} for every file reachable from the root document.

    info keys: path, parent (the file that includes it), include_line,
    leveloffset, id, title, content_type, headings, ids, editable.
    """
    catalog = {}

    def visit(path: Path, parent, include_line, leveloffset):
        rel = _rel(path)
        if rel in catalog or not path.is_file():
            return
        text = path.read_text(encoding="utf-8")
        title = TITLE_RE.search(text)
        ctype = re.search(r"^:_mod-docs-content-type:\s*(\S+)", text, re.MULTILINE)
        first_id = ID_RE.search(text)
        catalog[rel] = {
            "path": rel,
            "parent": parent,
            "include_line": include_line,
            "leveloffset": leveloffset,
            "id": first_id.group(1) if first_id else None,
            "title": title.group(1).strip() if title else None,
            "content_type": ctype.group(1) if ctype else None,
            "headings": [f"{m.group(1)} {m.group(2).strip()}" for m in HEADING_RE.finditer(text)],
            "ids": ID_RE.findall(text),
            "editable": is_editable(rel),
        }
        for match in INCLUDE_RE.finditer(text):
            target = (path.parent / match.group(1).strip()).resolve()
            offset = re.search(r"leveloffset=([^,\]]+)", match.group(2))
            visit(target, rel, match.group(0).strip(), offset.group(1) if offset else None)

    visit(DOCS_ROOT / root_document, None, None, None)
    return catalog


def is_editable(rel: str) -> bool:
    """Topic files in a guide directory and module/role references can receive content."""
    p = PurePosixPath(rel)
    if str(p.parent) in GUIDES:
        return bool(TOPIC_NAME_RE.match(p.name))
    return str(p.parent) == "source" and p.name.startswith(("reference-module-", "reference-role-"))


def catalog_summary(catalog: dict) -> str:
    """Compact text listing of the publishable files, grouped by guide."""
    lines = []
    for guide, meta in GUIDES.items():
        lines.append(f"\n## {guide}/: {meta['description']}")
        for rel, info in catalog.items():
            if str(PurePosixPath(rel).parent) != guide:
                continue
            kind = "assembly" if not info["editable"] else (info["content_type"] or "")
            lines.append(f"- {rel} [{kind}] id={info['id']} title={info['title']!r}")
            for heading in info["headings"]:
                lines.append(f"    {heading}")
    refs = [rel for rel, info in catalog.items() if rel.startswith("source/reference-")]
    lines.append("\n## source/: os_migrate.os_migrate module and role reference (one file per module or role)")
    lines.extend(f"- {rel}" for rel in refs)
    return "\n".join(lines)


def all_ids(catalog: dict) -> set:
    return {i for info in catalog.values() for i in info["ids"]}


# ---------------------------------------------------------------------------
# Change validation and application
# ---------------------------------------------------------------------------


class InvalidChange(Exception):
    pass


def _check_style(content: str, where: str, warnings: list):
    if "—" in content:
        warnings.append(f"{where}: contains em dashes")
    if re.search(r"(?i)\b(this pr|new in this release|is now|now supports)\b", content):
        warnings.append(f"{where}: wording might not be intemporal")


def plan_changes(changes: list, catalog: dict) -> tuple:
    """Validate *changes* and return ({path: new_content}, warnings).

    Supported change types:
      {"type": "append", "file": <existing topic>, "content": <AsciiDoc starting with an [id] + == heading>}
      {"type": "new_topic", "file": "source/<guide>/<con|proc|ref>_<name>.adoc",
       "include_after": <existing topic of the same guide>, "content": <full topic file>}
    """
    if not changes:
        raise InvalidChange("no changes proposed")

    files = {}
    warnings = []
    known_ids = all_ids(catalog)
    new_ids = set()
    new_xrefs = []

    def read(rel):
        if rel not in files:
            files[rel] = (DOCS_ROOT / rel).read_text(encoding="utf-8")
        return files[rel]

    for idx, change in enumerate(changes):
        ctype = change.get("type")
        rel = (change.get("file") or "").strip().lstrip("./")
        content = (change.get("content") or "").strip()
        where = f"change {idx} ({ctype} {rel})"
        if not content:
            raise InvalidChange(f"{where}: empty content")

        if ctype == "append":
            info = catalog.get(rel)
            if not info or not info["editable"]:
                raise InvalidChange(f"{where}: target is not a published topic file of the documentation catalog")
            if ":_mod-docs-content-type:" in content or re.search(r"^=\s", content, re.MULTILINE):
                raise InvalidChange(f"{where}: appended content must not contain a topic header or a level 0 title")
            if not re.match(r'^\[id="[^"]+"\]\s*\n={2,4}\s', content):
                raise InvalidChange(f"{where}: appended content must start with an [id] anchor and a == heading")
            files[rel] = read(rel).rstrip() + "\n\n" + content + "\n"

        elif ctype == "new_topic":
            p = PurePosixPath(rel)
            guide = str(p.parent)
            if guide not in GUIDES:
                raise InvalidChange(f"{where}: new topics must be created in one of {', '.join(GUIDES)}")
            if not TOPIC_NAME_RE.match(p.name):
                raise InvalidChange(f"{where}: file name must match <con|proc|ref>_<kebab-name>.adoc")
            if (DOCS_ROOT / rel).exists() or rel in files:
                raise InvalidChange(f"{where}: file already exists")
            expected_type = CONTENT_TYPES[p.name.split("_", 1)[0]]
            if not content.startswith(f":_mod-docs-content-type: {expected_type}"):
                raise InvalidChange(f"{where}: must start with ':_mod-docs-content-type: {expected_type}'")
            if not re.search(r'^\[id="[^"]+"\]\s*\n=\s', content, re.MULTILINE):
                raise InvalidChange(f"{where}: missing [id] anchor followed by a = title")
            anchor_prefix = f"{p.name.split('_', 1)[0]}_{GUIDES[guide]['anchor_infix']}"
            first_id = ID_RE.search(content).group(1)
            if not first_id.startswith(anchor_prefix):
                warnings.append(f"{where}: anchor {first_id!r} does not follow the {anchor_prefix}<name> convention")

            after = (change.get("include_after") or "").strip().lstrip("./")
            after_info = catalog.get(after)
            if not after_info or not after_info["editable"] or str(PurePosixPath(after).parent) != guide:
                raise InvalidChange(f"{where}: include_after must be an existing topic of {guide}")
            assembly = after_info["parent"]
            if not assembly or str(PurePosixPath(assembly).parent) != guide:
                raise InvalidChange(f"{where}: {after} is not included directly by an assembly of {guide}")
            assembly_text = read(assembly)
            include_line = after_info["include_line"]
            if include_line not in assembly_text:
                raise InvalidChange(f"{where}: cannot find {include_line!r} in {assembly}")
            offset = after_info["leveloffset"]
            new_line = f"include::{p.name}[leveloffset={offset}]" if offset else f"include::{p.name}[]"
            files[assembly] = assembly_text.replace(include_line, f"{include_line}\n\n{new_line}", 1)
            files[rel] = content + "\n"
            # Make the new topic available as an include_after target for later changes.
            catalog = dict(catalog)
            catalog[rel] = {
                "path": rel, "parent": assembly, "include_line": new_line, "leveloffset": offset,
                "ids": [], "editable": True,
            }

        else:
            raise InvalidChange(f"{where}: unknown change type")

        ids = ID_RE.findall(content)
        clash = (set(ids) & known_ids) | (set(ids) & new_ids) | {i for i in ids if ids.count(i) > 1}
        if clash:
            raise InvalidChange(f"{where}: anchors already defined: {', '.join(sorted(clash))}")
        new_ids.update(ids)
        new_xrefs.extend((where, target) for target in XREF_RE.findall(content))
        _check_style(content, where, warnings)

    for where, target in new_xrefs:
        if target not in known_ids | new_ids and "." not in target:
            raise InvalidChange(f"{where}: xref to unknown anchor {target!r}")

    return files, warnings


# ---------------------------------------------------------------------------
# Source PR helpers
# ---------------------------------------------------------------------------


def is_release_bump(pr) -> bool:
    """Return True if *pr* is a release / version-bump PR that needs no doc."""
    for pattern in RELEASE_TITLE_PATTERNS:
        if pattern.search(pr.title):
            return True

    label_names = {label.name.lower() for label in pr.labels}
    if label_names & {"release", "version-bump", "chore", "no-doc", "skip-docs"}:
        return True

    # All-files check: only trigger when every changed file is release-related
    try:
        filenames = [f.filename for f in pr.get_files()]
        if filenames and all(
            Path(name).name in RELEASE_ONLY_FILES or name.endswith(".lock") or name.startswith(".github/")
            for name in filenames
        ):
            return True
    except Exception:
        pass

    return False


def get_pr_diff_summary(pr, max_chars: int = 10_000) -> str:
    """Return a text summary of changed files + truncated patches."""
    parts = []
    total = 0
    files = list(pr.get_files())
    for f in files:
        if total >= max_chars:
            parts.append(f"... (truncated; {len(files)} files total)")
            break
        patch = (f.patch or "")[:3_000]
        entry = f"### {f.filename} ({f.status}, +{f.additions}/-{f.deletions})\n{patch}"
        parts.append(entry)
        total += len(entry)
    return "\n\n".join(parts)


def doc_pr_exists(gh, doc_repo_name: str, source_repo: str, pr_number: int) -> bool:
    """Return True if a documentation PR already references source_repo#pr_number."""
    query = f"repo:{doc_repo_name} is:pr {source_repo}#{pr_number} in:title"
    try:
        return gh.search_issues(query).totalCount > 0
    except Exception:
        return False


# ---------------------------------------------------------------------------
# Claude
# ---------------------------------------------------------------------------


def _make_claude_client():
    """Return an AnthropicVertex client using the same env vars as claude-code-security-review."""
    import anthropic

    vertex_project = (os.getenv("ANTHROPIC_VERTEX_PROJECT_ID") or "").strip()
    if not vertex_project:
        raise RuntimeError("ANTHROPIC_VERTEX_PROJECT_ID env var is required.")

    creds_json = os.getenv("GOOGLE_APPLICATION_CREDENTIALS_JSON")
    if creds_json and not os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
        tmp = tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False)
        tmp.write(creds_json)
        tmp.close()
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = tmp.name

    return anthropic.AnthropicVertex(project_id=vertex_project, region="us-east5")


def _ask_json(client, user_message: str, max_tokens: int) -> dict:
    response = client.messages.create(
        model=CLAUDE_MODEL,
        max_tokens=max_tokens,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": user_message}],
    )
    text = response.content[0].text.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```$", "", text)
    return json.loads(text)


def _pr_context(pr, repo_name: str) -> str:
    return f"""**Source PR {SOURCE_ORG}/{repo_name}#{pr.number}: {pr.title}**
URL: {pr.html_url}

**Description:**
{pr.body or "(no description provided)"}

**Changed files and diffs:**
{get_pr_diff_summary(pr)}"""


def analyse_pr(client, pr, repo_name: str, catalog: dict) -> dict:
    """First pass: decide whether docs are needed and which published files to read."""
    message = f"""Analyse this pull request and decide whether it requires new or updated documentation in the `{DOCS_REPO}` documentation repository.

{_pr_context(pr, repo_name)}

**Documentation catalog** (the only published files; headings are listed under each topic):
{catalog_summary(catalog)}

Return ONLY a valid JSON object (no markdown fences) with exactly these fields:
{{
  "needs_docs": <boolean>,
  "skip_reason": "<string, required when needs_docs is false>",
  "target_files": ["<up to {MAX_TARGET_FILES} catalog paths: the topics to extend, the topics a new topic should follow, and related topics to check for existing coverage>"]
}}"""
    return _ask_json(client, message, 1_024)


def generate_changes(client, pr, repo_name: str, catalog: dict, target_files: list) -> dict:
    """Second pass: write the changes with the full text of the target files."""
    targets = [t for t in target_files if t in catalog][:MAX_TARGET_FILES]
    if not targets:
        raise InvalidChange(f"no valid catalog file among proposed targets {target_files}")
    excerpts = []
    for rel in targets:
        info = catalog[rel]
        excerpts.append(f"### {rel} (included by {info['parent']} with {info['include_line']!r})\n"
                        f"{(DOCS_ROOT / rel).read_text(encoding='utf-8')}")
        if info["parent"] and info["parent"] not in targets:
            targets.append(info["parent"])
            excerpts.append(f"### {info['parent']} (assembly)\n"
                            f"{(DOCS_ROOT / info['parent']).read_text(encoding='utf-8')}")

    message = f"""Document this pull request in the `{DOCS_REPO}` documentation repository.

{_pr_context(pr, repo_name)}

**Documentation catalog** (the only published files):
{catalog_summary(catalog)}

**Full text of the relevant files:**
{chr(10).join(excerpts)}

Rules:
- Do not repeat what the files above already document. If everything is already covered, return "needs_docs": false.
- Use one or more changes. Each change is one of:
  * {{"type": "append", "file": "<editable topic from the catalog>", "content": "<AsciiDoc starting with [id=\\"...\\"] then a == heading>"}}
    The content is appended at the end of the topic. Use this to extend an existing topic, for example a new variable in a reference topic.
  * {{"type": "new_topic", "file": "source/<vmware|os-to-os|shared>/<con|proc|ref>_<kebab-name>.adoc", "include_after": "<existing topic of the same directory>", "content": "<complete topic file starting with :_mod-docs-content-type:>"}}
    The script adds the include directive to the assembly, right after the include of include_after.
- Every [id] you define must be new. Every xref must point to an anchor in the catalog or one you define.

Return ONLY a valid JSON object (no markdown fences) with exactly these fields:
{{
  "needs_docs": <boolean>,
  "skip_reason": "<string, required when needs_docs is false>",
  "changes": [<change objects>],
  "pr_title": "<short documentation PR title, without the source PR reference>",
  "pr_body": "<markdown body for the documentation PR: what was documented and where>"
}}"""
    return _ask_json(client, message, 8_192)


# ---------------------------------------------------------------------------
# GitHub
# ---------------------------------------------------------------------------


def create_doc_pr(doc_repo, source_repo_name: str, pr, files: dict, data: dict, warnings: list):
    """Commit *files* on a new branch in a single commit and open a PR."""
    from github import GithubException, InputGitTreeElement

    branch = f"doc-sync/{source_repo_name}-pr-{pr.number}"
    base = doc_repo.default_branch
    try:
        doc_repo.get_branch(branch)
        print(f"    Branch {branch!r} already exists, skipping")
        return None
    except GithubException as exc:
        if exc.status != 404:
            raise

    # The changes are computed from the local checkout, so commit on top of it.
    base_sha = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=DOCS_ROOT, text=True).strip()
    base_commit = doc_repo.get_git_commit(base_sha)
    elements = [InputGitTreeElement(path, "100644", "blob", content=content) for path, content in files.items()]
    tree = doc_repo.create_git_tree(elements, base_commit.tree)
    commit_msg = (f"docs: add documentation for {source_repo_name}#{pr.number}\n\n"
                  f"Auto-generated by doc-sync workflow from {pr.html_url}")
    commit = doc_repo.create_git_commit(commit_msg, tree, [base_commit])
    doc_repo.create_git_ref(f"refs/heads/{branch}", commit.sha)

    body = data.get("pr_body", "").strip()
    body += f"\n\nSource PR: {pr.html_url}\n\nChanged files:\n" + "\n".join(f"- `{p}`" for p in files)
    if warnings:
        body += "\n\n**Review notes (automatic checks):**\n" + "\n".join(f"- {w}" for w in warnings)
    title = f"[Doc Sync] {data.get('pr_title', pr.title).strip()} ({source_repo_name}#{pr.number})"
    return doc_repo.create_pull(title=title, body=body, head=branch, base=base)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main():
    from github import Github, GithubException

    catalog = build_catalog()
    editable = [rel for rel, info in catalog.items() if info["editable"]]
    print(f"Documentation catalog: {len(catalog)} published files, {len(editable)} editable topics")
    if not any(rel.startswith("source/vmware/") for rel in editable):
        raise RuntimeError(f"No guide topics found from {DOCS_ROOT / ROOT_DOCUMENT}; run from the docs checkout")

    gh_client = Github(os.environ["OSM_GITHUB_TOKEN"])
    claude_client = _make_claude_client()

    doc_repo = gh_client.get_repo(DOCS_REPO)
    cutoff = datetime.now(timezone.utc) - timedelta(days=DAYS_BACK)

    report = []

    for repo_name in TARGET_REPOS:
        repo_name = repo_name.strip()
        full_name = f"{SOURCE_ORG}/{repo_name}"
        print(f"\n{'=' * 60}")
        print(f"Scanning PRs in {full_name} (past {DAYS_BACK} day(s))")
        print(f"{'=' * 60}")

        try:
            source_repo = gh_client.get_repo(full_name)
        except GithubException as exc:
            print(f"  Cannot access {full_name}: {exc}, skipping")
            continue

        pulls = source_repo.get_pulls(state="open", sort="updated", direction="desc")

        for pr in pulls:
            if pr.updated_at < cutoff:
                break

            entry = {
                "repo": repo_name,
                "pr_number": pr.number,
                "pr_title": pr.title,
                "pr_url": pr.html_url,
                "action": None,
                "detail": None,
            }
            report.append(entry)
            print(f"\n  PR #{pr.number}: {pr.title}")

            if is_release_bump(pr):
                print("    -> skipped: release bump")
                entry.update(action="skipped", detail="release bump")
                continue

            if doc_pr_exists(gh_client, DOCS_REPO, repo_name, pr.number):
                print("    -> skipped: doc PR already exists")
                entry.update(action="skipped", detail="doc PR already exists")
                continue

            try:
                print("    -> analysing with Claude")
                analysis = analyse_pr(claude_client, pr, repo_name, catalog)
                if analysis.get("needs_docs"):
                    print(f"    -> reading {analysis.get('target_files')}")
                    data = generate_changes(claude_client, pr, repo_name, catalog,
                                            analysis.get("target_files") or [])
                else:
                    data = analysis
                if not data.get("needs_docs"):
                    reason = data.get("skip_reason", "no documentation needed")
                    print(f"    -> skipped by Claude: {reason}")
                    entry.update(action="skipped", detail=reason)
                    continue
                files, warnings = plan_changes(data.get("changes") or [], catalog)
            except (InvalidChange, json.JSONDecodeError) as exc:
                print(f"    -> rejected: {exc}")
                entry.update(action="error", detail=f"rejected generated changes: {exc}")
                continue
            except Exception as exc:
                print(f"    -> error during Claude analysis: {exc}")
                entry.update(action="error", detail=str(exc))
                continue

            entry["files"] = sorted(files)
            entry["warnings"] = warnings
            for path in files:
                print(f"       {'new ' if not (DOCS_ROOT / path).exists() else 'edit'}: {path}")
            for warning in warnings:
                print(f"       warning: {warning}")

            if DRY_RUN:
                print(f"    -> DRY RUN: would create PR: {data.get('pr_title')}")
                entry.update(action="dry_run", detail=data.get("pr_title"), changes=data.get("changes"))
                continue

            try:
                doc_pr = create_doc_pr(doc_repo, repo_name, pr, files, data, warnings)
                if doc_pr:
                    print(f"    -> created doc PR: {doc_pr.html_url}")
                    entry.update(action="created", detail=doc_pr.html_url)
                else:
                    entry.update(action="skipped", detail="branch already exists")
            except Exception as exc:
                print(f"    -> error creating doc PR: {exc}")
                entry.update(action="error", detail=str(exc))

    report_path = Path("doc-sync-report.json")
    report_path.write_text(json.dumps(report, indent=2, default=str))
    print(f"\nReport written to {report_path}")

    errors = [e for e in report if e["action"] == "error"]
    if errors:
        print(f"\n{len(errors)} error(s) occurred, see report for details", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
