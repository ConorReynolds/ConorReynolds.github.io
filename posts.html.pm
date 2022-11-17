#lang pollen

◊(require gregor
          txexpr
          pollen/core
          pollen/pagetree
          sugar/coerce)

◊(let () (current-pagetree (load-pagetree "index.ptree")) "")

◊(define (node->link node)
   (define node-string (->string node))
   (define link-name (select-from-metas 'title node))
   ◊link[node-string]{◊link-name})

◊(define (post-toc)
   (define posts
     (cdr (findf (λ (t) (and (list? t) (equal? (car t) 'posts.html)))
                 (current-pagetree))))
   (define (get-date node)
     (iso8601->date (select-from-metas 'created node)))
   (define in-order
     (sort posts (λ (x y) (date>? (get-date x) (get-date y)))))
   (txexpr 'div '((class "post-list"))
           (for/list ([post in-order])
             `(div [[class "post-item"]]
                    (span [[class "post-title"]] ,(node->link post))
                    " ~ "
                    ,(muted (~t (get-date post) "E, MMMM dd, y"))))))

◊(define-meta title "Posts")
◊(define-meta toc-title "Posts")
◊(define-meta subtitle "Everything I’ve posted to date")

◊(post-toc)
