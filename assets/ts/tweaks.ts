// Can't tweak something elsewhere? Do it here.

// Footnote backlinks currently use ↩︎, which I’m not really a fan of since it
// can appear really ugly on some devices. This scans for them and replaces the
// character with a FontAwesome ‘equivalent’.
document.querySelectorAll('a.footnote-backref').forEach((element) => {
    element.innerHTML = `<i class="fa fa-chevron-up"></i>`;
});
