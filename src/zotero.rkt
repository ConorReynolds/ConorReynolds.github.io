#lang pollen/mode racket/base

(require racket/port
         racket/string
         racket/file
         net/url
         json
         nested-hash
         txexpr
         gregor

         (only-in "tags.rkt" copy-button))

(provide bib-items)

(define project-root
  (getenv "PROJECT_ROOT"))


(define base-url "https://api.zotero.org")
(define user-id "4711353")
(define collection-id "I9IF6ZAC")

(define key
  (file->string (format "~a/zotero.key" project-root)))

(define target
  (format "~a/users/~a/collections/~a/items?include=data,bibtex&key=~a"
          base-url user-id collection-id key))

(define (get-json url)
  (displayln "[info] zotero: Fetching data from api.zotero.org …")
  (call/input-url
   (string->url url)
   get-pure-port
   (compose1 string->jsexpr port->string)))

(define (htable) (get-json target))

(define (fmt-name fnames lname)
  (let ([fname (string-join (for/list ([name (string-split fnames)])
                              (string (car (string->list name)))) ".")])
    (format "~a, ~a." lname fname)))

(define (parse-date-or-year date-string)
  (with-handlers ([exn:gregor:parse?
                   (λ (exn) (iso8601->date date-string))])
    (parse-date date-string "LLLL d, y")))

(define (bib-items)
  (for/list ([item (sort (htable) date>?
                         #:key (λ (x) (parse-date-or-year (or (nested-hash-ref x 'data 'date) "2019"))))]
             #:unless (equal? (nested-hash-ref item 'data 'itemType) "attachment"))
    (let* ([data (hash-ref item 'data)]
           [bibtex (hash-ref item 'bibtex)]
           [bibtex-entry-formatted (string-replace (string-trim bibtex) "\t" "  ")]
           [title (hash-ref data 'title)]
           [authors (map (λ (c) (fmt-name (hash-ref c 'firstName) (hash-ref c 'lastName)))
                         (filter (λ (c) (equal? (hash-ref c 'creatorType) "author"))
                                 (hash-ref data 'creators)))]
           [editors (map (λ (c) (fmt-name (hash-ref c 'firstName) (hash-ref c 'lastName)))
                         (filter (λ (c) (equal? (hash-ref c 'creatorType) "editor"))
                                 (hash-ref data 'creators)))]
           [proceedings (hash-ref data 'proceedingsTitle)]
           [pages (string-replace (hash-ref data 'pages) "-" "–")]
           [location (hash-ref data 'place)]
           [pubdate (hash-ref data 'date)]
           [publisher (hash-ref data 'publisher)]
           [doi (hash-ref data 'DOI)])
      (txexpr* 'div '[[class "bib-item"]]
               `(div [[class "bib-desc"]]
                     (em ,title) ". "
                     ,(string-append (string-join authors "; " #:before-last "; and ") " ")
                     "In "
                     ,(if (not (null? editors))
                          (string-append (string-join editors "; " #:before-last "; and ") ", editor(s), ")
                          "")
                     (em ,proceedings) ", "
                     "pages " ,pages ", "
                     ,location ", "
                     ,pubdate ". "
                     ,publisher)
               `(div [[class "bib-links"]]
                     (a [[class "doi-link extlink"]
                         [href ,(format "https://www.doi.org/~a" doi)]]
                        "Link")
                     (button [[class "show-bibtex"]
                              [onclick "this.parentElement.parentElement.querySelector('.bibtex').classList.toggle('show-bibtex')"]]
                             "BibTeX"))
               `(div [[class "bibtex"]]
                     ,(copy-button bibtex-entry-formatted)
                     (pre [[hyphens "none"]] ,bibtex-entry-formatted))))))
