(() => {
  // <stdin>
  var fontSizeInc = document.querySelector("#font-inc");
  var fontSizeDec = document.querySelector("#font-dec");
  var fontSizeDefault = document.querySelector("#font-default");
  function changeFontSize(selector, amount) {
    let element = document.querySelector(selector);
    let rawFontSize = window.getComputedStyle(element).getPropertyValue("font-size");
    let currentSize = parseFloat(rawFontSize);
    element.style.fontSize = currentSize + amount + "px";
  }
  fontSizeInc.addEventListener("click", (_event) => {
    changeFontSize("#content", 1);
  });
  fontSizeDec.addEventListener("click", (_event) => {
    changeFontSize("#content", -1);
  });
  fontSizeDefault.addEventListener("click", (_event) => {
    let element = document.querySelector("#content");
    element.style.fontSize = "18.6667px";
  });
})();
