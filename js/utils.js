var getAbsoluteUrl = function (url) {
  var a = document.createElement('a');

  getAbsoluteUrl = function (url) {
    a.href = url;
    return a.href;
  }
  return getAbsoluteUrl(url);
}

function copyAndConfirm(node, str) {
  navigator.clipboard.writeText(str);
  const children = node.querySelector('*');
  node.replaceChildren(new DOMParser().parseFromString(
    `<i class="fa fa-check"></i>`,
    'text/html'
  ).body.firstChild);
  setTimeout(function () {
    node.replaceChildren(children);
  }, 1000.0);
}

// This is mainly for spans that are clickable. ARIA attributes need to be
// correctly updated whenever the element is interacted with.
function toggleAriaExpanded(node) {
  node.setAttribute(
    'aria-expanded',
    node.getAttribute('aria-expanded') === 'true'
      ? 'false'
      : 'true'
  );
}

// This is mainly for spans that are clickable. Normally buttons can simulate a
// click by pressing Spacebar or Enter. We need to add this functionality back
// if we're using an element that isn’t a button.
function treatNodeAsButton(node) {
  node.addEventListener('keydown', event => {
    if (event.key === ' ' || event.key === 'Enter' || event.key === "Spacebar") {
      event.preventDefault();
      event.target.click();
    }
  });
}

document.querySelectorAll('span.tooltip').forEach(element => {
  treatNodeAsButton(element);
})
