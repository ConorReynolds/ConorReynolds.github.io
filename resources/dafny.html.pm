#lang pollen

◊(define-meta title "Dafny Resources")
◊(define-meta toc-title "Dafny Resources")
◊(define-meta subtitle "Table of contents")
◊(define-meta math? #false)
◊(define-meta created "2022-12-03")

◊(require pollen/pagetree pollen/template sugar/coerce)

◊(let () (current-pagetree (load-pagetree "../index.ptree")) "")

◊(define (node->link node #:capitalize [caps? #f])
    (define node-string (->string node))
    (define link-name
      (let* ([name (select-from-metas 'toc-title node)]
            [name (if caps? (capitalize-first-letter name) name)])
        name))
  ◊link[node-string]{◊link-name})

◊(define (make-toc-subsection pagenode)
  ◊div{◊(node->link pagenode #:capitalize #f)})

◊(apply div #:class "toc"
    (map make-toc-subsection (children 'resources/dafny.html)))
