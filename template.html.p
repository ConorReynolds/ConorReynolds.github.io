<!DOCTYPE html>
◊(require pollen/setup
          pollen/core
          sugar/coerce
          (submod txexpr safe)
          racket/contract
          racket/list
          racket/set
          racket/file
          racket/string
          json)

◊(define project-root
  (getenv "PROJECT_ROOT"))

◊(define/contract (bibjson-to-hashmap bibjson)
  (-> (listof (hash/c symbol? jsexpr?))
      (and/c hash? hash-equal? (not/c immutable?) hash-strong?))
  (make-hash
   (map (λ (item) (cons (hash-ref item 'id) item))
        bibjson)))

◊(define bib
  (let* ([file-contents (file->string (format "~a/references.json" project-root))]
         [flat-json (string->jsexpr file-contents)])
    (bibjson-to-hashmap flat-json)))

◊(define (cite-info cite-key)
  (let* ([bib-item (hash-ref bib cite-key)]
         [title (hash-ref bib-item 'title)]
         [year (->string (caar (hash-ref (hash-ref bib-item 'issued) 'date-parts)))]
         [authors (hash-ref bib-item 'author)]
         [first-author (hash-ref (car authors) 'family)]
         [doi (hash-ref bib-item 'DOI #f)]
         [url (hash-ref bib-item 'URL #f)]
         [lnk (if doi (format "https://doi.org/~a" doi) url)])
    (values title year authors lnk)))

◊(define/contract (format-citation #:authors authors
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

◊(define (take-noexcept list0 n0)
  (unless (exact-nonnegative-integer? n0)
    (raise-argument-error 'take-noexcept "exact-nonnegative-integer?" 1 list0 n0))
  (let loop ([list list0] [n n0])
    (cond [(zero? n) '()]
          [(pair? list) (cons (car list) (loop (cdr list) (sub1 n)))]
          [else '()])))

◊(define (post? node)
  (regexp-match #rx"^posts/" (symbol->string node)))

◊(define (resource? node)
  (regexp-match #rx"^resources" (symbol->string node)))

◊(define (all-cite-keys doc)
  (define (citation? x)
    (and (txexpr? x)
        (equal? "citation" (attr-ref x 'class #f))))
    (list->set (map (λ (elem) (attr-ref elem 'cite-key))
          (or (findf*-txexpr doc citation?) null))))

◊(define (make-side-nav id label url text)
  ◊div[#:class "nav-outer" #:id id #:role "navigation"]{
    ◊(link (or url "") #:alt label
           ◊div[#:class "nav-inner"]{◊div[#:class "nav-flex" text]})
  })

◊(define (make-top-link id url text)
  ◊div[#:class "nav-top" #:id id #:role "navigation"]{
    ◊(link (or url "") text)
  })

◊(define (make-top-nav-link pagenode)
   (link pagenode (select-from-metas 'toc-title pagenode)))

◊(define (parents node)
   (if (parent node)
     (append (parents (parent node)) (list (parent node)))
     '()))

◊(define all-parents (parents here))
◊(define parent-page (parent here))
◊(define previous-page (previous here))
◊(define next-page (next here))

<html lang="en-gb">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>
    ◊(select-from-metas 'title here) ◊when/splice[(not (equal? here 'index.html))]{| Conor Reynolds}
  </title>

  ◊; Prevent resources from appearing in search results (for now, anyway).
  ◊when/splice[(resource? here)]{
    <meta name="robots" content="noindex,nofollow">
  }

  ◊; KaTeX
  ◊when/splice[(select-from-metas 'math? here)]{
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.2/dist/katex.min.css" integrity="sha384-bYdxxUwYipFNohQlHt0bjN/LCpueqWz13HufFEV1SUatKs1cm4L6fFgCi1jT643X" crossorigin="anonymous">
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.2/dist/katex.min.js" integrity="sha384-Qsn9KnoKISj6dI8g7p1HBlNpVx0I8p1SvlwOldgi3IorMle61nQy4zEahWYtljaz" crossorigin="anonymous"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.2/dist/contrib/auto-render.min.js" integrity="sha384-+VBxd3r6XgURycqtZ117nYw44OOcIax56Z4dCRWbxyPt0Koah1uHoK0o4+/RRE05" crossorigin="anonymous"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            renderMathInElement(document.body, {
                // customised options
                // • auto-render specific keys, e.g.:
                delimiters: [
                    {left: '$$', right: '$$', display: true},
                    {left: '$', right: '$', display: false},
                    {left: '\\(', right: '\\)', display: false},
                    {left: '\\[', right: '\\]', display: true}
                ],
                // • rendering keys, e.g.:
                throwOnError : false
            });
        });
    </script>
  }

  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css" integrity="sha512-KfkfwYDsLkIlwQp6LFnl8zNdLGxu9YAA1QvwINks4PhcElQSvqcyVLLD9aMhXd13uQjoXtEKNosOWaZqXgel0g==" crossorigin="anonymous">

  <link rel="preload" href="/fonts/SourceCodePro/SourceCodePro-Bold.otf.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/fonts/SourceCodePro/SourceCodePro-BoldIt.otf.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/fonts/SourceCodePro/SourceCodePro-Medium.otf.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/fonts/SourceCodePro/SourceCodePro-MediumIt.otf.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="stylesheet" type="text/css" href="/main.css" />
</head>

◊(->html
  ◊body{
    ◊div[#:class "header"]{
      ◊title-block{
        ◊title{◊(select-from-metas 'title here)}
        ◊when/splice[(select-from-metas 'subtitle here)]{
          ◊subtitle{◊(select-from-metas 'subtitle here)}
        }
        ◊when/splice[(post? here)]{
          ◊publish-date[◊(select-from-metas 'created here)]
        }
      }

      ◊when/splice[(not (resource? here))]{
        ◊div[#:class "nav-container"]{
          ◊div[#:class "nav-top" #:role "navigation"]{
            ◊for/splice[([item (add-between (map make-top-nav-link
                                                (map (λ (x) (if (list? x) (car x) x))
                                                (take-noexcept (cdr (current-pagetree)) 4))) "/")])]{
              ◊|item|
            }
          }

          ◊div[#:id "search-wrapper"]{
            ◊form[#:id "searchbar-outer" #:class "searchbar-outer"]{
              ◊input[
                #:type "search" #:id "searchbar" #:name "searchbar"
                #:autocomplete "off"
                #:placeholder "Search …"
                #:aria-controls "searchresults-outer"
                #:aria-describedby "searchresults-header"]
            }
            ◊div[#:id "searchresults-outer" #:class "searchresults-outer"]{
              ◊div[#:id "searchresults-header" #:class "searchresults-header"]
            }
          }
        }
      }
    }

    ◊doc

    ◊when/splice[(not (set-empty? (all-cite-keys doc)))]{
      ◊div[#:class "cite-list"]{
        ◊section{Citations}
        ◊ul{
          ◊for/splice[([cite-key (all-cite-keys doc)])]{
            ◊(let-values ([(title year authors url) ◊(cite-info ◊|cite-key|)])
              ◊li{◊(format-citation #:authors authors #:title title #:year year #:url url)})
          }
        }
      }
    }

    ◊div[#:class "horizontal-rule"]

    ◊div[#:id "footer"]{
      ◊; Last updated on ◊(get-date) ◊(br)
      © Conor Reynolds
        ◊(if (equal? (get-year) "2022")
             "2022"
             (format "2022–~a" (get-year))) ◊(nbsp)
      ◊a[#:href "https://github.com/ConorReynolds" #:class "fab fa-github fa-1x" #:title "GitHub"] ◊(nbsp)
      ◊a[#:href "https://gitlab.cs.nuim.ie/creynolds" #:class "fab fa-gitlab fa-1x" #:title "GitLab"] ◊(nbsp)
      ◊a[#:href "https://twitter.com/ConorEReynolds" #:class "fab fa-twitter fa-1x" #:title "Twitter"] ◊(nbsp)
      ◊a[#:href "https://www.linkedin.com/in/conor-reynolds-931049258/" #:class "fab fa-linkedin-in fa-1x" #:title "LinkedIn"] ◊(nbsp)
      ◊a[#:href "mailto:conor.reynolds@mu.ie" #:class "fas fa-envelope fa-1x" #:title "Email"]
    }

    ◊; ◊when/splice[(resource? here)]{
    ◊;   ◊when/splice[previous-page]{
    ◊;     ◊make-side-nav["prev" "Go to previous page" previous-page]{⟨}
    ◊;   }
    ◊;   ◊when/splice[next-page]{
    ◊;     ◊make-side-nav["next" "Go to next page" next-page]{⟩}
    ◊;   }
    ◊; }
    ◊; ◊(cond
    ◊;   [(and next-page parent-page) ◊make-side-nav["next" next-page]{⟩}]
    ◊;   [(not parent-page) ◊make-side-nav["next" next-page ""]]
    ◊;   [else ""])
  })

<script src="/js/utils.js"></script>
<script src="/js/checkParams.js"></script>

◊; Search Engine
◊when/splice[(not (resource? here))]{
  <script src="/js/elasticlunr.js"></script>
  <script src="/js/search-index.js"></script>
  <script src="/js/searcher.js"></script>
}

◊; Clicky Analytics
◊when/splice[(not (resource? here))]{
  <script async src="//static.getclicky.com/101382862.js"></script>
}

</html>