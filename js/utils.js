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
