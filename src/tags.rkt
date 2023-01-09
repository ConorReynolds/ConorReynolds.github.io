#lang pollen/mode racket/base

(require racket/contract
         txexpr
         gregor)

(provide (except-out (all-defined-out) project-root))

(define project-root
  (getenv "PROJECT_ROOT"))


; ==============================================================================
; Simple formatting

(define (em . elems)
  `(em ,@elems))

(define (bold . elems)
  `(strong ,@elems))

(define (underline . elems)
  `(span [[style "text-decoration: underline"]] ,@elems))

(define (strikethrough . elems)
  `(span [[style "text-decoration: line-through"]] ,@elems))

(define (sc-form . elems)
  (txexpr 'span '[[style "font-feature-settings: 'ss10'"]] elems))

(define (publish-date iso-yy-mm-dd)
  (txexpr 'time `[[datetime ,iso-yy-mm-dd]]
          (list (~t (iso8601->date iso-yy-mm-dd)
                    "d MMMM y"))))

(define/contract (author name)
  (-> string? txexpr?)
  (txexpr* 'span `[[class "author"]] name))

(define/contract (email . elems)
  (->* () #:rest (listof string?) txexpr?)
  (define email-address (apply string-append elems))
  (txexpr* 'a `[[class "email"]
                [href ,(format "mailto:~a" email-address)]]
           email-address))

(define (work . elems)
  (txexpr 'cite null elems))

(define (quotation #:author author . elems)
  (txexpr* 'blockquote null
           (cons '@ elems)
           `(author ,author)))


; ==============================================================================
; Callout Blocks

(define/contract (callout-block title elems)
  (-> string? txexpr-elements? txexpr?)
  (txexpr* 'div `[[class "callout"]
                  [data-callout ,(string-downcase (regexp-replace* #px"\\s+" title "-"))]]
           `(div [[class "callout-title"]] ,title)
           `(div [[class "callout-body"]] ,@elems)))

(define (note . elems)
  (callout-block "Note" elems))

(define (warning . elems)
  (callout-block "Warning" elems))

(define (key-takeaway . elems)
  (callout-block "Key Takeaway" elems))

; ==============================================================================
; Lists

(define (hang-list #:compact [compact? #t] . elems)
  (let ([tx (txexpr 'ul `[[class "hang-list"]] elems)])
    (if compact?
        (attr-join tx 'class "compact-list")
        (attr-join tx 'class "loose-list"))))

; ==============================================================================
; Buttons

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

; =============================================================================
; Formatting characters

(define thinspace (string #\u2009))
(define soft-hyphen "\u00AD")
(define (nbsp) (string #\u00A0))
(define (linebreak) (string #\newline))

; =============================================================================
; Geogebra embeds

; These really aren’t great. Might occasionally be useful.
(define/contract (geogebra id)
  (-> string? txexpr?)
  (txexpr 'iframe
          `[[src ,(format "https://www.geogebra.org/calculator/~a?embed" id)]
            [width "100%"] [allowfullscreen ""]
            [style "aspect-ratio: 3 / 2; border: 1px solid #e4e4e4;border-radius: 4px;"]
            [frameborder "0"]]))
