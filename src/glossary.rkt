#lang racket/base

(provide (all-defined-out))

(define glossary-entries
  (make-hash '()))

(define (abbr short)
  `(span [[class "abbreviation"]
          [onclick "this.classList.toggle(\"clicked\")"]]
         ,short
         (span [[class "abbreviation-inner"]]
               ,(hash-ref glossary-entries short))))
