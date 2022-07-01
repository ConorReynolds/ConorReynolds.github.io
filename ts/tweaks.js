(() => {
  // <stdin>
  document.querySelectorAll("a.footnote-backref").forEach((element) => {
    element.innerHTML = `<i class="fa fa-chevron-up"></i>`;
  });
  document.querySelectorAll("a.bibbase.bibbase_page.link").forEach((element) => {
    let parent = element.parentElement;
    element.remove();
    if (parent !== null) {
      parent.style.display = "flex";
      parent.style.gap = "1em";
      parent.innerHTML = parent.innerHTML.replace(/&nbsp;/g, "");
    }
  });
})();
