#lang pollen/mode racket/base

(require racket/match
         racket/port
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
  (format "~a/users/~a/collections/~a/items/top?include=data,bibtex&key=~a"
          base-url user-id collection-id key))

(define (get-json url)
  (displayln "[info] zotero: Fetching data from api.zotero.org …")
  (call/input-url
   (string->url url)
   get-pure-port
   port->string))

(define (parse-date-or-year date-string)
  (with-handlers ([exn:gregor:parse?
                   (λ (exn) (iso8601->date date-string))])
    (parse-date date-string "LLLL d, y")))

(define (htable) (get-json target))

(define (fmt-name fnames lname)
  (let ([fname (string-join (for/list ([name (string-split fnames)])
                              (string (car (string->list name)))) ".")])
    (format "~a, ~a." lname fname)))

(define (author? x)
  (equal? (hash-ref x 'creatorType) "author"))

(define (journal-article data)
  ; when itemType = journalArticle
  (let* ([title (hash-ref data 'title)]
         [authors (filter author? (hash-ref data 'creators))]
         [fmt-authors (for/list ([author (in-list authors)])
                        (fmt-name (hash-ref author 'firstName)
                                  (hash-ref author 'lastName)))]
         [pub-title (hash-ref data 'publicationTitle)]
         [year (number->string (->year (parse-date-or-year (hash-ref data 'date))))]
         [pages (string-replace (hash-ref data 'pages) "-" "–")]
         [volume (hash-ref data 'volume)]
         [issue (hash-ref data 'issue)])
    (txexpr* 'div '[[class "bib-desc"]]
             `(strong ,title) "." '(br)
             (string-append (string-join fmt-authors ", " #:before-last ", and ") " ")
             year ". "
             `(i ,pub-title) ", "
             volume (if (> (string-length issue) 0) (format " (~a)" issue) "") ", "
             pages ".")))

(define (conference-paper data)
  (let* ([title (hash-ref data 'title)]
         [authors (map (λ (c) (fmt-name (hash-ref c 'firstName) (hash-ref c 'lastName)))
                       (filter (λ (c) (equal? (hash-ref c 'creatorType) "author"))
                               (hash-ref data 'creators)))]
         [year (number->string (->year (parse-date-or-year (hash-ref data 'date))))]
         [proceedings (hash-ref data 'proceedingsTitle)]
         [pages (string-replace (hash-ref data 'pages) "-" "–")]
         [location (hash-ref data 'place)]
         [publisher (hash-ref data 'publisher)])
    (txexpr* 'div '[[class "bib-desc"]]
             `(strong ,title) "." '(br)
             (string-append (string-join authors ", " #:before-last ", and ") " ")
             year ". "
             "In " `(i ,proceedings) ", "
             "(" location "), "
             publisher ", "
             pages ".")))

(define (bib-items)
  (define raw-string (htable))
  (define raw-json (string->jsexpr raw-string))
  (displayln raw-string)
  (for/list ([item (sort raw-json date>?
                         #:key (λ (x) (parse-date-or-year (or (nested-hash-ref x 'data 'date) "2019"))))])
    (let* ([data (hash-ref item 'data)]
           [bibtex (hash-ref item 'bibtex)]
           [bibtex-entry-formatted (string-replace (string-trim bibtex) "\t" "  ")]
           [type (hash-ref data 'itemType)]
           [doi (hash-ref data 'DOI)])
      (txexpr*
       'div '[[class "bib-item"]]
       (match type
         ["journalArticle" (journal-article data)]
         ["conferencePaper" (conference-paper data)]
         [_ "How embarrassing."])
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
