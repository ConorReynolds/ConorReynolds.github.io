/// If coming from the search bar (i.e. url has search=... param)
/// then simulate a Ctrl+F for that term.
function findSearchTerm() {
    const url = window.location.href;

    if (!url.includes('?')) {
        return;
    }

    const query = window.location.search;
    const urlParams = new URLSearchParams(query);
    const term = urlParams.get('search');

    window.find(term);
}

window.addEventListener('load', function (_event) {
    findSearchTerm();
});
