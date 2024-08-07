#lang pollen/mode racket/base

(require
  racket/date
  racket/file
  racket/string
  racket/list
  racket/match
  racket/contract

  ; (submod txexpr safe)
  txexpr
  pollen/core
  pollen/setup
  pollen/decode
  pollen/tag
  pollen/file
  sugar/coerce
  sugar/list
  ; pollen-count

  pollen/unstable/pygments
  pollen/unstable/typography
  hyphenate

  "src/tags.rkt"
  "src/bib.rkt"
  "src/glossary.rkt"
  "src/zotero.rkt"
  "src/utils.rkt")

(provide (all-defined-out))
(provide (all-from-out "src/tags.rkt"))
(provide (all-from-out "src/bib.rkt"))
(provide (all-from-out "src/glossary.rkt"))
(provide (all-from-out "src/zotero.rkt"))

(module setup racket/base
  (provide (all-defined-out))
  (require file/glob)
  (define src-files (glob "src/*.rkt"))
  (define cache-watchlist src-files)
  (define poly-targets '(html)))


(define project-root
  (getenv "PROJECT_ROOT"))

(define no-hyphens-attr '(hyphens "none"))
(define no-paragraphs-attr '(paragraphs "none"))
(define no-smart-typography-attr '(smart-typography "none"))

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
  (define (linebreak-proc elems)
    (decode-linebreaks elems " "))
  (define elements-with-paragraphs
    (decode-elements elems
                     #:txexpr-elements-proc (λ (x) (decode-paragraphs x #:linebreak-proc linebreak-proc))
                     #:exclude-tags '(figure table title-block verbatim)
                     #:exclude-attrs `((class "bib-item")
                                       (class "highlight")
                                       ,no-paragraphs-attr)))
  (list* 'div '((id "doc") (role "main"))
         (decode-elements elements-with-paragraphs
                          ; #:block-txexpr-proc hyphenate-block
                          #:string-proc (compose1 string-proc-extras text-typography)
                          #:exclude-attrs `((class "highlight") ,no-smart-typography-attr)
                          #:exclude-tags '(style script code verbatim))))

(define (title-block . elems)
  `(div [[id "title-block"]] ,@elems))

(define (title . elems)
  `(h1 ,@elems))

(define (subtitle . elems)
  `(div [[class "subtitle"]] ,@elems))

(define (number-section)
  `(h2 [[class "number-section"]]))

(define (section #:id [id #f] . elems)
  (define strs (findf*-txexpr (cons '@ elems) string?))
  (define label (string-join (list* "#" (if id (list id) strs)) ""))
  `(h2 [[id ,(substring label 1)] [class "section"]]
       ,@elems
       (a [[class "anchor"]
           [href ,label]
           [title "permalink to this section"]]
          (i [[class "fas fa-link"]]))))

(define (subsection #:id [id #f] . elems)
  (define strs (findf*-txexpr (cons '@ elems) string?))
  (define label (string-join (list* "#" (if id (list id) strs)) ""))
  `(h3 [[id ,(substring label 1)] [class "subsection"]]
       ,@elems
       (a [[class "anchor"]
           [href ,label]
           [title "permalink to this subsection"]]
          (i [[class "fas fa-link"]]))))

(define (get-date)
  (date->string (current-date)))

(define (get-year)
  (format "~a" (date-year (current-date))))

(define (link url #:class [class-name #f] #:alt [alt-text #f] . tx-elements)
  (let* ([url (->string url)]
         [url (if (regexp-match #rx"^#" url) url (string-append "/" url))]
         [tx-elements (if (empty? tx-elements)
                          (list url)
                          tx-elements)]
         [link-tx (txexpr 'a empty tx-elements)]
         [link-tx (attr-set link-tx 'href url)]
         [link-tx (if class-name (attr-set link-tx 'class class-name) link-tx)]
         [link-tx (if alt-text (attr-set link-tx 'alt alt-text) link-tx)])
    link-tx))

(define (format-as-filename target)
  (define nonbreaking-space (string #\u00A0))
  (let* ([x target]
         [x (string-trim x "?")]
         [x (string-downcase x)]
         [x (if (regexp-match "home" x) "index" x)]
         [x (string-replace x nonbreaking-space "-")]
         [x (string-replace x " " "-")])
    (format "~a.html" x)))

(define (target->url target)
  (define actual-filenames
    (map path->string
         (remove-duplicates (map ->output-path
                                 (append (directory-list (string->path project-root))
                                         (directory-list (format "~a/posts/" project-root)))))))
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

(define (ul #:compact [compact #t] . elems)
  (attr-set (txexpr 'ul '() elems)
            'class (if compact "compact-list" "loose-list")))

(define (ol #:compact [compact #t] . elems)
  (attr-set (txexpr 'ol '() elems)
            'class (if compact "compact-list" "loose-list")))

(define (item . elems)
  `(li ,@elems))

(define (block-emphasis . elems)
  `(div [[class "block-emphasis"]]
        ,@elems))

(define (quick-table . elems)
  (define split-into-rows
    (filter-split (decode-elements #:string-proc (λ (x) (string-split x "|")) elems)
                  (λ (x) (and (string? x) (regexp-match "\n" x)))))
  (define rows-of-text-cells
    (let ([text-rows split-into-rows])
      (for/list ([text-row (in-list text-rows)])
        (for/list ([text-cell (in-list (filter-not whitespace? text-row))])
          (if (string? text-cell) (string-trim text-cell) text-cell)))))

  (match-define (list tr-tag td-tag th-tag) (map default-tag-function '(tr td th)))

  (define html-rows
    (match-let ([(cons header-row other-rows) rows-of-text-cells])
      (cons (map th-tag header-row)
            (for/list ([row (in-list other-rows)])
              (map td-tag row)))))

  (attr-set (cons 'table (for/list ([html-row (in-list html-rows)])
                           (apply tr-tag html-row)))
            'class "quick-table"))


(define/contract (kbd #:os [os 'generic] . elems)
  (->* () (#:os (or/c 'mac 'generic)) #:rest (listof string?) txexpr?)
  (define raw (apply string-append elems))
  (define keys (regexp-split #rx"\\+" raw))
  (define replacements
    '(("Cmd" "⌘")
      ("Ctrl" "⌃")
      ("Option" "⌥")
      ("Shift" "⇧")))
  (txexpr 'kbd `((class ,(symbol->string os)))
          (add-between
           (for/list ([key (in-list keys)])
             `(kbd ,(if (eqv? os 'mac)
                        ((make-replacer replacements) (string-trim key))
                        (string-trim key))))
           (if (eqv? os 'generic) "+" ""))))

(define (spoiler . elems)
  (txexpr 'span '[[class "spoiler"]
                  [onclick "this.classList.toggle(\"clicked\")"]]
          elems))

(define (extlink #:desc [desc #f] url . elems)
  `(a [[class "extlink"] [href ,url]] ,@elems))

(define (sc . elems)
  `(span [[class "smallcaps"]] ,@elems))

(define ($ . elems)
  `(span [[class "inline-math"] ,no-hyphens-attr ,no-smart-typography-attr]
         ,(apply string-append `("\\(" ,@elems "\\)"))))

(define ($$ . elems)
  `(div [[class "display-math"] ,no-hyphens-attr ,no-paragraphs-attr ,no-smart-typography-attr]
        ,(apply string-append `("\\[\\begin{aligned}\n  " ,@elems "\n\\end{aligned}\\]"))))

; Call this like `◊verb["…"]`
(define (verb . elems)
  (define raw (apply string-append elems))
  `(code ,raw))

(define (code . elems)
  `(code ,@elems))

(define (codeblock [lang 'text]
                   #:wrap [wrap? #f]
                   #:name [caption #f]
                   #:download [dl? #f]
                   #:id [id #f]
                   . elems)
  (define raw (apply string-append elems))
  (define pre-rendered (highlight #:python-executable "python3" lang raw))
  (define rendered (if wrap? (attr-join pre-rendered 'class "code-wrap") pre-rendered))
  (apply txexpr*
         (get-tag rendered)
         (list* no-paragraphs-attr
                no-smart-typography-attr
                (if id (cons `(id ,id) (get-attrs rendered))
                       (get-attrs rendered)))
         (if caption
             `(div [[class "caption"]]
                   ,caption
                   ,(if dl? (download-button caption raw) '(@)))
             '(@))
         (copy-button raw)
         (get-elements rendered)))

;; Similar to MB’s Beautiful Racket — I just don’t like sidenotes very much in HTML
(define (aside . elems)
  `(span [[class "tooltip"] [role "button"] [aria-expanded "false"] [tabindex "0"]
          [onclick
           "this.classList.toggle(\"show-tooltip\"); toggleAriaExpanded(this);"]]
         (i [[class "fa fa-plus"]])
         (span [[class "tooltip-inner"]] ,@elems)))

(define (image #:width [width "80%"] #:lazy [lazy #t] #:src src #:alt [alt #f] . caption)
  (define alt-text
    (or alt (apply string-append (or (findf*-txexpr (cons '@ caption) string?) null))))
  (let ([src (if (regexp-match #rx"^https?://" src) src (format "/media/~a" src))])
    `(figure
      (img [[src ,src] [style ,(format "width: ~a" width)]
            [alt ,(if (non-empty-string? alt-text)
                      alt-text
                      "no alt text supplied")]
            ,(if lazy '(@ [loading "lazy"] [decoding "async"]) '(@))])
      ,(if (not (null? caption))
           `(figcaption ,(em `(@ ,@caption)))
           '(@)))))

(define (video #:width [width "100%"] #:src src)
  (let ([src (if (regexp-match #rx"^https?://" src) src (format "/media/~a" src))])
    `(video [[width ,width] [onloadstart "this.volume = 0.5"] [controls ""] [muted ""]]
            (source [[src ,src]])
            "Your browser doesn’t support video—sorry!")))

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
