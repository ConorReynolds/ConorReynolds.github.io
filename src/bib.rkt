#lang pollen/mode racket/base

(require racket/contract
         racket/file
         racket/string
         racket/set
         racket/list
         sugar/coerce
         txexpr
         json

         "tags.rkt")

(define project-root
  (getenv "PROJECT_ROOT"))

(provide cite cite-info format-citation)

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

(define/contract (format-citation #:cite-key cite-key
                                  #:authors authors
                                  #:title title
                                  #:year year
                                  #:url url)
  (-> #:cite-key (or/c string? #f) #:authors (listof hash?) #:title string? #:year string? #:url (or/c string? #f) txexpr?)
  (define authors-formatted
    (string-join
     (for/list ([author-ht (in-list authors)])
       (define literal (hash-ref author-ht 'literal #f))
       (if (not literal)
           (format "~a, ~a"
                   (hash-ref author-ht 'family)
                   (string-join (for/list ([given-name (string-split (hash-ref author-ht 'given))])
                                  (string (string-ref given-name 0)))
                                (string-append "." thinspace) #:after-last "."))
           literal))
     "; " #:before-last "; and "))
  (txexpr* '@ '[] (em (if url `(a [[href ,url] [class "extlink"]] ,title) title)) ", " authors-formatted ", " year
           (if cite-key `(a [[href ,(format "#~a" cite-key)] [class "return"]] "(↑)") '(@))))

(define/contract (cite-tooltip formatted-text)
  (-> txexpr? txexpr?)
  (txexpr* 'span `[[class "cite-tooltip"]]
           formatted-text))

(define (cite-info cite-key)
  (let* ([bib-item (hash-ref bib cite-key)]
         [title (hash-ref bib-item 'title)]
         [year (->string (caar (hash-ref (hash-ref bib-item 'issued) 'date-parts)))]
         [authors (hash-ref bib-item 'author)]
         [literal (hash-ref (car authors) 'literal #f)]
         [first-author (if (not literal)
                           (hash-ref (car authors) 'family)
                           literal)]
         [doi (hash-ref bib-item 'DOI #f)]
         [url (hash-ref bib-item 'URL #f)]
         [lnk (if doi (format "https://doi.org/~a" doi) url)])
    (values title year authors first-author lnk)))

(define/contract (inline-cite cite-key)
  (-> string? txexpr?)
  (define-values (title year authors first-author url)
    (cite-info cite-key))
  ; (define first-author (hash-ref (car authors) 'family))
  (txexpr* 'span `[[class "citation"]
                   [id ,cite-key]
                   [cite-key ,cite-key]
                   [onclick "this.classList.toggle(\"clicked\")"]]
           first-author
           (if (> (length authors) 1)
               `(@ (em " et al."))
               '(@))
           ", "
           year
           (cite-tooltip (format-citation #:cite-key #f
                                          #:authors authors
                                          #:title title
                                          #:year year
                                          #:url url))))

(define/contract (cite . ids)
  (->* () #:rest (listof string?) txexpr?)
  (define list-of-ids (string-split (apply string-append ids) " "))
  (txexpr 'span `[[class "citations"]]
          (add-between
           (for/list ([id (in-list list-of-ids)])
             (inline-cite id))
           '("; ") #:before-first '("(") #:after-last '(")") #:splice? #t)))
