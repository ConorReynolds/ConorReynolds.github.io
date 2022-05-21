const fontSizeInc = document.querySelector('#font-inc');
const fontSizeDec = document.querySelector('#font-dec');
const fontSizeDefault = document.querySelector('#font-default');

function changeFontSize(selector: string, amount: number) {
  // What does this type parameter do exactly? What if #content wasn’t a
  // HTMLElement? Hmm …
  let element = document.querySelector<HTMLElement>(selector);
  let rawFontSize = window.getComputedStyle(element).getPropertyValue('font-size');
  let currentSize = parseFloat(rawFontSize);
  element.style.fontSize = (currentSize + amount) + 'px';
}

fontSizeInc.addEventListener('click', (_event) => {
  changeFontSize('#content', 1);
});

fontSizeDec.addEventListener('click', (_event) => {
  changeFontSize('#content', -1);
});

fontSizeDefault.addEventListener('click', (_event) => {
  let element = document.querySelector<HTMLElement>('#content');
  element.style.fontSize = "18.6667px";
});