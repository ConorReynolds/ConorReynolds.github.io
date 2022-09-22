var getAbsoluteUrl = function (url) {
  var a = document.createElement('a');

  getAbsoluteUrl = function (url) {
    a.href = url;
    return a.href;
  }
  return getAbsoluteUrl(url);
}

function copyToClipboard(text) {
  let url = getAbsoluteUrl(text);
  navigator.clipboard.writeText(url);
}
