#lang racket/base

(require racket/string)

(provide (all-defined-out))

(define (posttree dir include-drafts?)
  (for/list ([filename (directory-list dir)]
             #:when (and (regexp-match #rx"html.pm$" filename)
                         (if include-drafts?
                             #true (not (regexp-match #rx"^draft" filename)))))
    (let [(filename (path->string filename))]
      (string->symbol
       (format "~a/~a" dir (string-replace filename "html.pm" "html"))))))
