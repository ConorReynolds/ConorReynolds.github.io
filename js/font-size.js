const fontSizeInc = document.querySelector('#font-inc');
const fontSizeDec = document.querySelector('#font-dec');
const fontSizeDefault = document.querySelector('#font-default');

function changeFontSize(selector, amount) {
    element = document.querySelector(selector);
    style = window.getComputedStyle(element, null).getPropertyValue('font-size');
    currentSize = parseFloat(style);
    element.style.fontSize = (currentSize + amount) + 'px';
}

fontSizeInc.addEventListener('click', (_event) => {
    changeFontSize('html', 1);
});

fontSizeDec.addEventListener('click', (_event) => {
    changeFontSize('html', -1);
});

fontSizeDefault.addEventListener('click', (_event) => {
    element = document.querySelector('html');
    element.style.fontSize = "18.6667px";
});