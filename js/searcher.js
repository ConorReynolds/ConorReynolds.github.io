const searchBar = document.getElementById('searchbar');
const searchForm = document.getElementById('searchbar-outer');
var searchResults = document.getElementById('searchresults-outer');


document.addEventListener('keydown', (event) => {
    if (event.key === "/") {
        event.preventDefault();
        searchBar.focus();
    }
});

searchForm.addEventListener('submit', function (event) {
    event.preventDefault();
    let topResult = searchResults.firstChild.firstChild;
    if (topResult && topResult.firstChild.href) {
        window.location.assign(getAbsoluteUrl(topResult.firstChild.href));
    }
});

searchBar.oninput = function (_event) {
    if (searchBar.value === '') {
        while (searchResults.firstChild) {
            searchResults.removeChild(searchResults.firstChild);
        }
    }

    getSearchResults(searchBar.value);
};

function getSearchResults(query) {
    const results = searchIndex.search(query, {
        expand: true,
        bool: "AND",
        fields: {
            title: {boost: 2},
            body: {boost: 1},
        },
    });
    var resultslist = document.createElement('ul');
    for (let result of results) {
        var link = document.createElement('a');
        link.href = `/${result.doc.url}?search=${query}`;
        link.textContent = result.doc.title;
        var item = document.createElement('li');
        item.appendChild(link);
        resultslist.appendChild(item);
    }
    searchResults.replaceChildren(resultslist);
}
