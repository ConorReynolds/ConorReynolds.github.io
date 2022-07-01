// Can't tweak something elsewhere? Do it here.

// Footnote backlinks currently use ↩︎, which I’m not really a fan of since it
// can appear really ugly on some devices. This scans for them and replaces the
// character with a FontAwesome ‘equivalent’.
document.querySelectorAll('a.footnote-backref').forEach((element) => {
    element.innerHTML = `<i class="fa fa-chevron-up"></i>`;
});


// This BibBase link is useless, so we remove it.
document.querySelectorAll('a.bibbase.bibbase_page.link').forEach((element) => {
    let parent = element.parentElement;
    
    element.remove();

    // Set the style here rather than in CSS, since I’m not 100% sure that
    // span.bibbase_paper_content.dontprint is the same as the parent of an
    // a.bibbase.bibbase_page.link
    if (parent !== null) {
        parent.style.display = 'flex';
        parent.style.gap = '1em';
        parent.innerHTML = parent.innerHTML.replace(/&nbsp;/g, '')
    }
});
