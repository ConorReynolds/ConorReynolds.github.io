#lang pollen/mode racket/base

(require
  racket/date
  racket/file
  racket/string
  racket/list

  txexpr
  pollen/core
  pollen/setup
  pollen/decode

  pollen/unstable/pygments
  pollen/unstable/typography
  hyphenate
  )

(provide (all-defined-out))

(module setup racket/base
  (provide (all-defined-out))
  (define poly-targets '(html tex)))

(define no-hyphens-attr '(hyphens "none"))

(define (hyphenate-block block-tx)
  (define (no-hyphens? tx)
    (or (member (get-tag tx) '(th h1 h2 h3 h4 style script))
        (member no-hyphens-attr (get-attrs tx))))
  (hyphenate block-tx
             #:min-left-length 3
             #:min-right-length 3
             #:omit-txexpr no-hyphens?))

(define text-typography
  (compose1 smart-quotes smart-dashes smart-ellipses))

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

(define (latex-ellipses str)
  (regexp-replace* #px"\\.{3}" str "\\\\dots{}"))

(define (html-root elems)
  (define elements-with-paragraphs
    (decode-elements elems #:txexpr-elements-proc decode-paragraphs))
  (list* 'div '((id "doc"))
         (decode-elements elements-with-paragraphs
                          #:block-txexpr-proc hyphenate-block
                          #:string-proc (compose1 make-quotes-hangable
                                                  text-typography)
                          #:exclude-tags '(style script code))))

(define (root . xs)
  (case (current-poly-target)
    [(html) (html-root xs)]
    [else (decode-elements #:string-proc (compose1 smart-dashes smart-ellipses) xs)]))

; Checks if a math expression ends in any one of a number of problematic characters.
; If so, add relevant space.
(define (mkern str)
  (define kerning-table
    (make-hash '(("M" . "2.5")
                 ("F" . "2.5")
                 ("P" . "2.5")
                 ("T" . "2.3")
                 ("\\phi" . "0.3"))))
  (define match? (regexp-match #rx"([MFPT]|\\\\phi)$" str))
  (if (and (boolean? match?) (not match?)) str
      (string-append str "\\mkern" (hash-ref kerning-table (first match?)) "mu")))

; non-breaking space
(define nbsp " ")

; Correct spacing after full-stop which does not end a sentence.
; Irrelevant if frenchspacing is active (tex)
(define ._
  (case (current-poly-target)
    [(tex) ".\\"]
    [else "."]))


(define (get-date)
  (date->string (current-date)))


(define (chapter #:label [label #f] 
                 #:numbered [numbered #t]
                 #:short [short #f]
                 . elems)
  (case (current-poly-target)
    [(tex)
     (if (string? label)
         (apply string-append
                `("\\chapter" ,(if numbered "" "*") "[" ,@(if (string? short) '(short) elems) "]"
                              "{" ,@elems "}"
                              "\n\\label{chap:" ,label "}"))
         (apply string-append
                `("\\chapter" ,(if numbered "" "*") "[" ,@(if (string? short) '(short) elems) "]"
                              "{" ,@elems "}")))]
    [(html) 
     `(h2
       ,(if (string? label) `((id ,(string-append "chap:" label))) '())
       ,@elems)]
    [else "[!not implemented]"]))


(define (section #:label [label #f]
                 #:numbered [numbered #t]
                 . elems)
  (case (current-poly-target)
    [(tex)
     (if (string? label)
         (apply string-append `("\\section" ,(if numbered "" "*") "{" ,@elems "}\n\\label{sec:" ,label "}"))
         (apply string-append `("\\section" ,(if numbered "" "*") "{" ,@elems "}")))]
    [(html)
     `(h3
       ,(if (string? label) `((id ,(string-append "sec:" label))) '())
       ,@elems)]
    [else (map string-upcase elems)]))

(define (subsection #:label [label #f]
                    #:numbered [numbered #t]
                    . elems)
  (case (current-poly-target)
    [(tex)
     (if (string? label)
         (apply string-append `("\\subsection" ,(if numbered "" "*") "{" ,@elems "}\n\\label{subsec:" ,label "}"))
         (apply string-append `("\\subsection" ,(if numbered "" "*") "{" ,@elems "}")))]
    [(html)
     `(h4
       ,(if (string? label) `((id ,(string-append "subsec:" label))) '())
       ,@elems)]
    [else (map string-upcase elems)]))

(define (em . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\emph{" ,@elems "}"))]
    [(html) `(em ,@elems)]
    [else `("*" ,@elems "*")]))

(define (include . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\input{" ,@elems ".tex}"))]
    [else ""]))

(define (ul #:compact [compact #t] . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\begin{itemize}"
                                  ,(if compact "[noitemsep]" "") "\n"
                                  ,@elems
                                  "\n\\end{itemize}"))]
    [else (txexpr 'ul 
                  (if compact 
                      '((class "compact-list")) 
                      '((class "loose-list"))) 
                  elems)]))

(define (ol #:compact [compact #t] . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\begin{enumerate}"
                                  ,(if compact "[noitemsep]" "") "\n"
                                  ,@elems
                                  "\n\\end{enumerate}"))]
    [else (txexpr 'ol 
                  (if compact
                      '((class "compact-list")) 
                      '((class "loose-list"))) 
                  elems)]))

(define (li . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("  \\item " ,@elems))]
    [else `(li ,@elems)]))

(define (extlink #:desc [desc #f] url . elems)
  (case (current-poly-target)
    [(tex) (apply string-append 
                  `(,@elems "\\pagenote{"
                            ,(if (string? desc) (string-append "\\textit{" desc "}\\\\") "")
                            "\\url{" ,url "}}"))]
    [(html) `(a [[class "extlink"] [href ,url]] ,@elems)]
    [else "[!not implemented]"]))

(define (crossref url . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\textsc{" ,@elems "}"))]
    [(html) `(a [[class "crossref"] [href ,url]] ,@elems)]))

(define (cite . label)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\autocite{" ,@label "}"))]
    [(html) "[?]"]
    [else "[?]"]))

(define (sc . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\textsc{" ,@elems "}"))]
    [(html) `(span [[class "smallcaps"]] ,@elems)]
    [else elems]))

(define ($ . elems)
  (define raw (apply string-append elems))
  (define space-corrected (mkern raw))
  (case (current-poly-target)
    [(tex) (apply string-append `("\\( " ,space-corrected " \\)"))]
    [(html) (apply string-append `("\\(" ,@elems "\\)"))]
    [else elems]))

(define ($$ #:align [align #f] . elems)
  (define env (if align "align*" "equation*"))
  (case (current-poly-target)
    [(tex) (apply string-append `("\\begin{" ,env "}\n  " ,@elems "\n\\end{" ,env "}"))]
    [(html) (apply string-append `("\\begin{align*}\n  " ,@elems "\n\\end{align*}"))]
    [else elems]))

(define (quot . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\textquote{" ,@elems "}"))]
    [(html) `(span "‘" ,@elems "’")]
    [else elems]))

(define (verb . elems)
  (define raw (apply string-append elems))
  (case (current-poly-target)
    [(tex) (apply string-append `("\\Verb|" ,raw "|"))]
    [(html) `(code ,raw)]))

(define (code . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\texttt{" ,@elems "}"))]
    [(html) `(code ,@elems)]))

(define (codeblock [lang 'racket] . elems)
  (define raw (apply string-append elems))
  (case (current-poly-target)
    [(tex) (apply string-append
                  `("\\begin{minted}{"
                    ,(symbol->string lang) "}\n"
                    ,@elems
                    "\n\\end{minted}"))]
    [(html) (highlight
             #:python-executable "python3"
             lang
             (apply string-append elems))]
    [else raw]))

(define (coqblock . elems)
  (codeblock 'coq (apply string-append elems)))


(define (codeexample [lang 'racket] . elems)
  (define raw (apply string-append elems))
  (case (current-poly-target)
    [(tex) (apply string-append
                  `("\\begin{VerbatimOut}{minted.doc.out}\n"
                    ,@elems
                    "\n\\end{VerbatimOut}\n"
                    "\\inputminted{" ,(symbol->string lang) "}{build/minted.doc.out}"))]
    [(html) (highlight
             #:python-executable "python3"
             lang
             (apply string-append elems))]
    [else raw]))


;; Similar to MB’s Beautiful Racket -- I just don’t like sidenotes very much in HTML
(define (aside . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("\\marginpar{\\raggedright\\footnotesize " ,@elems "}"))]
    [(html) `(span [[class "tooltip"]
                    [onclick "this.classList.toggle(\"show-tooltip\")"]]
                   "+"
                   (span [[class "tooltip-inner"]] ,@elems))]
    [else "[asides not yet implemented]"]))


(define hrule
  (case (current-poly-target)
    [(tex) "\\pfbreak"]
    [(html) '(hr)]
    [else "[hrule not yet implemented]"]))


(define mainmatter
  (case (current-poly-target)
    [(tex) "\\mainmatter"]
    [else ""]))

(define backmatter
  (case (current-poly-target)
    [(tex) "\\backmatter"]
    [else ""]))

(define (latex)
  (case (current-poly-target)
    [(tex) "\\LaTeX{}"]
    [else "LaTeX"]))

(define \R
  "\\mathbb{R}")

(define \Sig
  "\\mathsf{Sig}")

(define \FOPEQ
  "\\text{\\sffamily\\itshape FOPEQ}")

(define \EVT
  "\\text{\\sffamily\\itshape EVT}")

(define (\set . elems)
  (apply string-append `("\\{" ,@elems "\\}" )))

(define \defeq "≜")

(define (ipa . elems)
  (case (current-poly-target)
    [(tex) (apply string-append `("{\\ipafont " ,@elems "}"))]
    [else `(span [[class "ipa"]] ,@elems)]))

(define (EventB . elems)
  (case (current-poly-target)
    [(tex) "Event\\nobreakdash-B"]
    [else "Event‑B"]))
