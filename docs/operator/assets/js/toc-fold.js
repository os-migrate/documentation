/**
 * TOC Folding JavaScript
 * Makes TOC subsections collapsible/expandable
 */

document.addEventListener('DOMContentLoaded', function() {
    initializeTOCFolding();
});

function initializeTOCFolding() {
    const toc = document.getElementById('toc');
    if (!toc) return;

    // Find all TOC items that have sub-lists
    const tocItems = toc.querySelectorAll('ul li');

    tocItems.forEach(function(item) {
        const subList = item.querySelector('ul');
        if (subList) {
            // Mark this item as having children
            item.classList.add('has-children');

            // Create toggle button
            const toggle = document.createElement('button');
            toggle.className = 'toc-toggle expanded';
            toggle.setAttribute('aria-label', 'Toggle subsection');
            toggle.setAttribute('type', 'button');

            // Insert toggle button after the link
            const link = item.querySelector('a');
            if (link) {
                link.parentNode.insertBefore(toggle, link.nextSibling);
            }

            // Add click handler
            toggle.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                toggleTOCSection(item, toggle, subList);
            });

            // Initially expand level 0 and 1, collapse deeper levels
            const depth = getItemDepth(item);
            if (depth > 1) {
                collapseTOCSection(item, toggle, subList);
            }
        }
    });
}

function toggleTOCSection(item, toggle, subList) {
    if (item.classList.contains('collapsed')) {
        expandTOCSection(item, toggle, subList);
    } else {
        collapseTOCSection(item, toggle, subList);
    }
}

function expandTOCSection(item, toggle, subList) {
    item.classList.remove('collapsed');
    item.classList.add('expanding');
    toggle.classList.remove('collapsed');
    toggle.classList.add('expanded');

    // Trigger reflow for animation
    subList.offsetHeight;

    setTimeout(function() {
        item.classList.remove('expanding');
    }, 300);
}

function collapseTOCSection(item, toggle, subList) {
    item.classList.add('collapsing');
    item.classList.remove('expanded');
    toggle.classList.remove('expanded');
    toggle.classList.add('collapsed');

    setTimeout(function() {
        item.classList.remove('collapsing');
        item.classList.add('collapsed');
    }, 300);
}

function getItemDepth(item) {
    let depth = 0;
    let parent = item.parentElement;

    while (parent && parent.id !== 'toc') {
        if (parent.tagName === 'UL') {
            depth++;
        }
        parent = parent.parentElement;
    }

    return depth;
}

// Utility function to expand all sections (for search/navigation)
function expandAllTOCSections() {
    const toc = document.getElementById('toc');
    if (!toc) return;

    const collapsedItems = toc.querySelectorAll('li.collapsed');
    collapsedItems.forEach(function(item) {
        const toggle = item.querySelector('.toc-toggle');
        const subList = item.querySelector('ul');
        if (toggle && subList) {
            expandTOCSection(item, toggle, subList);
        }
    });
}

// Utility function to collapse all sections
function collapseAllTOCSections() {
    const toc = document.getElementById('toc');
    if (!toc) return;

    const expandedItems = toc.querySelectorAll('li.has-children:not(.collapsed)');
    expandedItems.forEach(function(item) {
        const toggle = item.querySelector('.toc-toggle');
        const subList = item.querySelector('ul');
        if (toggle && subList) {
            collapseTOCSection(item, toggle, subList);
        }
    });
}

// Export utility functions for external use
window.TOCFolding = {
    expandAll: expandAllTOCSections,
    collapseAll: collapseAllTOCSections
};