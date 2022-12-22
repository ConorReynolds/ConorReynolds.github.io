#lang pollen/mode racket/base

(require racket/contract
         racket/file
         racket/string
         racket/set
         sugar/coerce
         txexpr
         json

         "tags.rkt")

(define project-root
  (getenv "PROJECT_ROOT"))

(provide cite)

(define/contract (bibjson-to-hashmap bibjson)
  (-> (listof (hash/c symbol? jsexpr?))
      (and/c hash? hash-equal? (not/c immutable?) hash-strong?))
  (make-hash
   (map (λ (item) (cons (hash-ref item 'id) item))
        bibjson)))

(define bib
  (let* ([file-contents (file->string (format "~a/references.json" project-root))]
         [flat-json (string->jsexpr file-contents)])
    (bibjson-to-hashmap flat-json)))

(define/contract (format-citation #:authors authors
                                  #:title title
                                  #:year year
                                  #:url url)
  (-> #:authors (listof hash?) #:title string? #:year string? #:url (or/c string? #f) txexpr?)
  (define authors-formatted
    (string-join
     (for/list ([author-ht (in-list authors)])
       (format "~a, ~a"
               (hash-ref author-ht 'family)
               (string-join (for/list ([given-name (string-split (hash-ref author-ht 'given))])
                              (string (string-ref given-name 0)))
                            (string-append "." thinspace) #:after-last ".")))
     "; " #:before-last "; and "))
  (txexpr* '@ '[] (em (if url `(a [[href ,url]] ,title) title)) ", " authors-formatted ", " year))

(define/contract (cite-tooltip formatted-text)
  (-> txexpr? txexpr?)
  (txexpr* 'span `[[class "cite-tooltip"]]
           formatted-text))

(define (cite-info cite-key)
  (let* ([bib-item (hash-ref bib cite-key)]
         [title (hash-ref bib-item 'title)]
         [year (->string (caar (hash-ref (hash-ref bib-item 'issued) 'date-parts)))]
         [authors (hash-ref bib-item 'author)]
         [first-author (hash-ref (car authors) 'family)]
         [doi (hash-ref bib-item 'DOI #f)]
         [url (hash-ref bib-item 'URL #f)]
         [lnk (if doi (format "https://doi.org/~a" doi) url)])
    (values title year authors lnk)))

(define/contract (cite . id)
  (->* () #:rest (listof string?) txexpr?)
  (define cite-key (apply string-append id))
  (define-values (title year authors url)
    (cite-info cite-key))
  (define first-author (hash-ref (car authors) 'family))
  (txexpr* 'span `[[class "citation"]
                   [cite-key ,cite-key]
                   [onclick "this.classList.toggle(\"clicked\")"]]
           "(" first-author
           (if (> (length authors) 1)
               `(@ (em " et al."))
               '(@))
           ", "
           year ")"
           (cite-tooltip (format-citation #:authors authors
                                          #:title title
                                          #:year year
                                          #:url url))))
