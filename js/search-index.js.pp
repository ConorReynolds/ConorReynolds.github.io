#lang pollen

◊(require racket/list racket/string txexpr pollen/core pollen/pagetree pollen/template sugar/coerce)
◊(let () (current-pagetree (load-pagetree "../index.ptree")) "")
◊(define (grab-strs tx)
  (define soft-hyphen "\u00AD")
  (string-normalize-spaces
    (regexp-replace* soft-hyphen
      (string-join (findf*-txexpr tx string?)) "")))

elasticlunr.clearStopWords();

var searchIndex = elasticlunr(function () {
  this.setRef('id');
  this.addField('title');
  this.addField('body');
});

var id = 0;

◊for/splice[([page (cdr (flatten (current-pagetree)))])]{
  searchIndex.addDoc({
    "id": id++,
    "title": `◊(select-from-metas 'title page)`,
    "body": `◊(grab-strs (get-doc page))`,
    "url": `◊|page|`,
  });
  ◊(linebreak)
}