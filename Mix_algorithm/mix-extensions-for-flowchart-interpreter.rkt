#lang racket

(require "../FlowChart_interpreter/flowchart.rkt")

(define (try-eval cmd marked-args)
  (define static (foldl (lambda (x y) (and (equal? (car x) 'STATIC) y)) #t marked-args))
  (if static `(STATIC  (quote ,(apply (eval-ns cmd) (map get-value marked-args))))
             `(DYNAMIC (,cmd ,@(map get-code marked-args))))
)

(define (rec-reduce expr vs)
  (if (list? expr)
    (if (equal? 'quote (car expr))
        `(STATIC (quote ,(second expr)))
        (try-eval (first expr) (map (lambda (x) (rec-reduce x vs)) (rest expr))))
    (if (hash-has-key? vs expr) `(STATIC (quote ,(hash-ref vs expr))) `(DYNAMIC ,expr))
  )
)

(define (get-code x)
  (match x
    [`(STATIC (quote ,x)) `(quote ,x)]
    [`(DYNAMIC ,x) x])
)

(define (get-value x) 
  (match x
    [`(STATIC (quote ,x)) x]
    [`(DYNAMIC ,x) x])
)

(define (reduce-to-code expr vs) (get-code (rec-reduce expr vs)))
(define (evaluate expr vs) (get-value (rec-reduce expr vs)))

(define (get-new-read-statement read VS0)
  (define (isNotBinded x)(not (hash-has-key? VS0 x)))
  (cons 'read (filter isNotBinded (rest read)))
)

(fc-define-func "reduce" reduce-to-code)
(fc-define-func "evaluate" evaluate)

(fc-define-func "bool" (lambda (cond a b) (if cond a b)))
(fc-define-func "get-new-read-statement" get-new-read-statement)