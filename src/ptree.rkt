#lang racket/base

(require racket/string)

(provide (all-defined-out))

(define (posttree dir)
  (for/list ([filename (directory-list dir)]
             #:when (regexp-match #rx"html.pm$" filename))
    (let [(filename (path->string filename))]
      (string->symbol
       (format "~a/~a" dir (string-replace filename "html.pm" "html"))))))
