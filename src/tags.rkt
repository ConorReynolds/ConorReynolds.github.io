#lang pollen/mode racket/base

(require txexpr
         gregor)

(provide (except-out (all-defined-out) project-root))

(define project-root
  (getenv "PROJECT_ROOT"))

(define (copy-button str)
  `(button [[class "copy-button"]
            [title "Copy snippet to clipboard"]
            [onclick ,(format "copyAndConfirm(this, String.raw`~a`)" str)]]
           (i [[class "fas fa-copy"]])))

(define (download-button filename text)
  `(button [[class "download-button"]
            [title ,(format "Download snippet as ~a" filename)]
            [onclick ,(format "download(this, `~a`, String.raw`~a`)"
                              filename text)]]
           (i [[class "fa fa-download"]])))

(define (publish-date iso-yy-mm-dd)
  (txexpr 'time `[[datetime ,iso-yy-mm-dd]]
          (list (~t (iso8601->date iso-yy-mm-dd)
                    "d MMMM y"))))
