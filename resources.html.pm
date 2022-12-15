#lang pollen

◊(require pollen/pagetree pollen/template sugar/coerce)

◊(define-meta title "Resources")
◊(define-meta toc-title "Resources")
◊(define-meta subtitle "Assignment sheets and assorted tutorials")

◊(let () (current-pagetree (load-pagetree "index.ptree")) "")

◊(define (node->link node #:redirect [other-node #f] #:capitalize [caps? #f])
    (define node-string (if other-node (->string other-node) (->string node)))
    (define link-name
      (let* ([name (select-from-metas 'toc-title node)]
            [name (if caps? (capitalize-first-letter name) name)])
        name))
  ◊link[node-string]{◊link-name})

◊(define (make-toc-subsection pagenode)
  (define node-children (children pagenode))
  (define first-child (or (not node-children) (car node-children)))
  ◊div{
    ◊(if first-child
        ◊h3[#:class "toc"]{
          ◊(node->link pagenode #:redirect first-child #:capitalize #f)
        }
        ◊h3[#:class "toc"]{◊(node->link pagenode #:capitalize #f)})
    ◊(if first-child
      (apply ul (map (compose1 li node->link) node-children))
      "")})

◊(apply div #:class "toc"
    (map make-toc-subsection (children 'resources.html)))
