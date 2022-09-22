#lang racket/base

(provide (all-defined-out))

(define (take-noexcept list0 n0)
  (unless (exact-nonnegative-integer? n0)
    (raise-argument-error 'take-noexcept "exact-nonnegative-integer?" 1 list0 n0))
  (let loop ([list list0] [n n0])
    (cond [(zero? n) '()]
          [(pair? list) (cons (car list) (loop (cdr list) (sub1 n)))]
          [else '()])))

(define (post? node)
  (regexp-match #rx"^post/" node))
