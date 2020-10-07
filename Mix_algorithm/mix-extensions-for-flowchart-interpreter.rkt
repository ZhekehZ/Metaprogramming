#lang racket

(require "../FlowChart_interpreter/flowchart.rkt")

(define (try-eval cmd marked-args)
  (define static (foldl (lambda (x y) (and (equal? (car x) 'STATIC) y)) #t marked-args))
  (define args (map cadr marked-args))
  (if static `(STATIC ,(apply (eval-ns cmd) args)) `(DYNAMIC (,cmd ,@args)))
)

(define (rec-reduce expr vs)
  (if (list? expr)
    (if (equal? 'quote (car expr))
      `(STATIC ,(second expr))
      (try-eval (first expr) (map (lambda (x) (rec-reduce x vs)) (rest expr)))
    )
    (if (hash-has-key? vs expr) `(STATIC ,(hash-ref vs expr)) `(DYNAMIC ,expr))
  ) 
)

(define (get-new-read-statement read VS0)
  (define (isNotBinded x)(not (hash-has-key? VS0 x)))
  (cons 'read (filter isNotBinded (rest read)))
)

(fc-define-func "reduce" (lambda (expr vs) (cadr (rec-reduce expr vs))))
(fc-define-func "bool" (lambda (cond a b) (if cond a b)))
(fc-define-func "get-new-read-statement" get-new-read-statement)