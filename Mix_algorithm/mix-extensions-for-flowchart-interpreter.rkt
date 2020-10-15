#lang racket

(require "../FlowChart_interpreter/flowchart.rkt")

 
(define (static? expr vs)
  (define has? (λ (x) ((if (hash? vs) hash-has-key? set-member?) vs x)))
  (match expr
    [`',x #t]
    [`(,fun . ,args) (for/and ([a args]) (static? a vs))]
    [x (has? x)]
  )
)

(define (reduce expr vs)
  (define (local-reduce x) (reduce x vs))
  (if (static? expr vs)
    `(quote ,(eval-expr expr vs))
    (match expr
      [`(,func . ,args) `(,func ,@(map local-reduce args))]
      [x x]
    )
  )
)

(define (evaluate expr env)
  (second (reduce expr env))
)

(define (get-new-read-statement read VS0)
  (define (isNotBinded x)(not (hash-has-key? VS0 x)))
  (cons 'read (filter isNotBinded (rest read)))
)

(define (find-blocks-in-pending pending program)
  (define (add x y) (cons (assoc x program) y))
  (foldl add '() (set-map pending car))
)

(fc-define-func "reduce" reduce)
(fc-define-func "evaluate" evaluate)
(fc-define-func "bool" (λ (cond a b) (if cond a b)))
(fc-define-func "get-new-read-statement" get-new-read-statement)
(fc-define-func "static?" static?)
(fc-define-func "find-blocks-in-pending" find-blocks-in-pending)