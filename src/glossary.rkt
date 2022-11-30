#lang racket/base

(provide (all-defined-out))

(define glossary-entries
  (make-hash '(("LEM" . "law of excluded middle"))))

(define (abbr short)
  `(span [[class "abbreviation"]
          [onclick "this.classList.toggle(\"clicked\")"]]
         ,short
         (span [[class "abbreviation-inner"]]
               ,(hash-ref glossary-entries short))))
