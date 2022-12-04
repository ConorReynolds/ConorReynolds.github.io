#lang pollen

◊(require racket/list racket/string txexpr pollen/core pollen/pagetree pollen/template sugar/coerce)
◊(let () (current-pagetree (load-pagetree "../index.ptree")) "")
◊(define (grab-strs tx)
  (define soft-hyphen "\u00AD")
  (string-normalize-spaces
    (regexp-replace* soft-hyphen
      (string-join (or (findf*-txexpr tx string?) null)) "")))

elasticlunr.clearStopWords();

var searchIndex = elasticlunr(function () {
  this.setRef('id');
  this.addField('title');
  this.addField('toctitle');
  this.addField('body');
});

var id = 0;

◊for/splice[([page (cdr (flatten (current-pagetree)))]
             #:when (not (regexp-match #rx"^resources" (symbol->string page))))]{
  searchIndex.addDoc({
    "id": id++,
    "title": `◊(select-from-metas 'title page)`,
    "toctitle": `◊(select-from-metas 'toc-title page)`,
    "body": `◊(grab-strs (get-doc page))`,
    "url": `◊|page|`,
  });
  ◊(linebreak)
}