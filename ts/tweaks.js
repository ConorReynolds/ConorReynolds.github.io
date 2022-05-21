(() => {
  // <stdin>
  document.querySelectorAll("a.footnote-backref").forEach((element) => {
    element.innerHTML = `<i class="fa fa-chevron-up"></i>`;
  });
})();
