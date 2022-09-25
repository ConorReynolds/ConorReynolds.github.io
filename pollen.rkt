#lang pollen/mode racket/base

(require
  racket/date
  racket/file
  racket/string
  racket/list
  racket/match

  (submod txexpr safe)
  pollen/core
  pollen/setup
  pollen/decode
  pollen/tag
  pollen/file
  sugar/coerce
  ; pollen-count

  pollen/unstable/pygments
  pollen/unstable/typography
  hyphenate

  "src/glossary.rkt"
  "src/zotero.rkt"
  )

(provide (all-defined-out))
(provide (all-from-out "src/glossary.rkt"))
(provide (all-from-out "src/zotero.rkt"))

(module setup racket/base
  (provide (all-defined-out))
  (define poly-targets '(html)))

(define no-hyphens-attr '(hyphens "none"))

(define (hyphenate-block block-tx)
  (define (no-hyphens? tx)
    (or (member (get-tag tx) '(th h1 h2 h3 h4 style script))
        (member no-hyphens-attr (get-attrs tx))))
  (hyphenate block-tx
             #:min-left-length 3
             #:min-right-length 3
             #:omit-txexpr no-hyphens?))

(define ((make-replacer query+replacement) str)
  (for/fold ([str str])
            ([qr (in-list query+replacement)])
    (match-define (list query replacement) qr)
    (regexp-replace* query str replacement)))

(define (smart-dashes-preserve-space str)
  (define dashes
    ;; fix em dashes first, else they'll be mistaken for en dashes
    ;; \\s is whitespace + #\u00A0 is nonbreaking space
    '((#px"(---|—)" "—") ; em dash
      (#px"(--|–)" "–"))) ; en dash
  ((make-replacer dashes) str))

(define text-typography
  (compose1 smart-quotes smart-dashes-preserve-space smart-ellipses))

(define (make-quotes-hangable str)
  (define substrs (regexp-match* #px"\\s?[“‘]" str #:gap-select? #t))
  (if (= (length substrs) 1)
      (car substrs)
      (cons 'quo (append-map (λ (str)
                               (let ([strlen (string-length str)])
                                 (if (> strlen 0)
                                     (case (substring str (sub1 strlen) strlen)
                                       [("‘") (list '(squo-push) `(squo-pull ,str))]
                                       [("“") (list '(dquo-push) `(dquo-pull ,str))]
                                       [else (list str)])
                                     (list str)))) substrs))))

(define (root . elems)
  (define elements-with-paragraphs
    (decode-elements elems
                     #:txexpr-elements-proc decode-paragraphs
                     #:exclude-tags '(title-block table verbatim)
                     #:exclude-attrs '((class "bib-item"))))
  (list* 'div '((id "doc") (role "main"))
         (decode-elements elements-with-paragraphs
                          ; #:block-txexpr-proc hyphenate-block
                          #:string-proc (compose1 string-proc-extras text-typography)
                          #:exclude-tags '(style script code verbatim))))

(define soft-hyphen "\u00AD")

(define (title-block . elems)
  `(div [[id "title-block"]] ,@elems))

(define (title . elems)
  `(h1 ,@elems))

(define (subtitle . elems)
  `(div [[class "subtitle"]] ,@elems))

(define (section . elems)
  (define strs (findf*-txexpr (cons 'x elems) string?))
  (define label (string-join (list* "#" strs) ""))
  `(h2 [[id ,(substring label 1)] [class "section"]]
       ,@elems
       (a [[class "anchor"]
           [href ,label]
           [title "permalink to this section"]]
          (i [[class "fas fa-link"]]))))

; non-breaking space
(define (nbsp) (string #\u00A0))
(define (linebreak) (string #\newline))

(define (get-date)
  (date->string (current-date)))

(define (get-year)
  (format "~a" (date-year (current-date))))

(define (link url #:class [class-name #f] . tx-elements)
  (let* ([url (string-append "/" (->string url))]
         [tx-elements (if (empty? tx-elements)
                          (list url)
                          tx-elements)]
         [link-tx (txexpr 'a empty tx-elements)]
         [link-tx (attr-set link-tx 'href url)])
    (if class-name
        (attr-set link-tx 'class class-name)
        link-tx)))

(define (format-as-filename target)
  (define nonbreaking-space (string #\u00A0))
  (let* ([x target]
         [x (string-trim x "?")]
         [x (string-downcase x)]
         [x (string-replace x nonbreaking-space "-")]
         [x (string-replace x " " "-")])
    (format "~a.html" x)))

(define (target->url target)
  (define actual-filenames
    (map path->string (remove-duplicates (map ->output-path (directory-list (string->path "."))))))
  (define target-variants (let* ([plural-regex #rx"s$"]
                                 [singular-target (regexp-replace plural-regex target "")]
                                 [plural-target (string-append singular-target "s")])
                            (list singular-target plural-target)))
  (or (for*/first ([tfn (in-list (map format-as-filename target-variants))]
                   [afn (in-list actual-filenames)]
                   #:when (equal? tfn afn))
        tfn)
      "#"))

(define xref
  (case-lambda
    [(target)
     (xref (target->url target) target)]
    [(url target)
     (apply attr-set* (link url target) 'class "xref" no-hyphens-attr)]
    [more-than-two-args
     (apply raise-arity-error 'xref (list 1 2) more-than-two-args)]))

(define (em . elems)
  `(em ,@elems))

(define (bold . elems)
  `(strong ,@elems))

(define (underline . elems)
  `(span [[style "text-decoration: underline;"]] ,@elems))

(define (ul #:compact [compact #t] . elems)
  (txexpr 'ul
          (if compact
              '((class "compact-list"))
              '((class "loose-list")))
          elems))

(define (ol #:compact [compact #t] . elems)
  (txexpr 'ol
          (if compact
              '((class "compact-list"))
              '((class "loose-list")))
          elems))

(define (item . elems)
  `(li ,@elems))

(define (quick-table . elems)
  (define rows-of-text-cells
    (let ([text-rows (filter-not whitespace? elems)])
      (for/list ([text-row (in-list text-rows)])
        (for/list ([text-cell (in-list (string-split text-row "|"))])
          (string-trim text-cell)))))

  (match-define (list tr-tag td-tag th-tag) (map default-tag-function '(tr td th)))

  (define html-rows
    (match-let ([(cons header-row other-rows) rows-of-text-cells])
      (cons (map th-tag header-row)
            (for/list ([row (in-list other-rows)])
              (map td-tag row)))))

  (cons 'table (for/list ([html-row (in-list html-rows)])
                 (apply tr-tag html-row))))


(define (extlink #:desc [desc #f] url . elems)
  `(a [[class "extlink"] [href ,url]] ,@elems))

(define (sc . elems)
  `(span [[class "smallcaps"]] ,@elems))

(define ($ . elems)
  `(span [[class "inline-math"] [hyphens "none"]]
         ,(apply string-append `("\\(" ,@elems "\\)"))))

(define ($$ . elems)
  (apply string-append `("\\begin{align*}\n  " ,@elems "\n\\end{align*}")))

; Call this like `◊verb["…"]`
(define (verb . elems)
  (define raw (apply string-append elems))
  `(code ,raw))

(define (code . elems)
  `(code ,@elems))

(define (codeblock #:wrap [wrap? #f] [lang 'racket] . elems)
  (define raw (apply string-append elems))
  (define rendered (highlight #:python-executable "python3" lang raw))
  (if wrap? (attr-join rendered 'class "code-wrap") rendered))

;; Similar to MB’s Beautiful Racket — I just don’t like sidenotes very much in HTML
(define (aside . elems)
  `(span [[class "tooltip"]
          [onclick "this.classList.toggle(\"show-tooltip\")"]]
         (i [[class "fa fa-plus"] [aria-hidden "true"]])
         (span [[class "tooltip-inner"]] ,@elems)))

(define (muted . elems)
  `(span [[class "muted"]] ,@elems))

(define (latex)
  "LaTeX")

(define hrule
  '(hr))

(define \defeq "≜")

(define (ipa . elems)
  `(span [[class "ipa"]] ,@elems))

(define (©-nbsp str)
  (regexp-replace #px"© " str (string-append "©" (nbsp))))

(define string-proc-extras
  ©-nbsp)
