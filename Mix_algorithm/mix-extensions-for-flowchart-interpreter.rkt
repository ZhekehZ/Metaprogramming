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

(define (get-new-read-statement read VS0)
  (define (isNotBinded x)(not (hash-has-key? VS0 x)))
  (cons 'read (filter isNotBinded (rest read)))
)

(define (find-blocks-in-pending blocks division)
  (define (get-dynamic-jumps block)
    (match (last block)
      [`(if ,cond ,lbl1 ,lbl2) #:when (not (static? cond division)) (set lbl1 lbl2)]
      [else (set)]
  ))
  (foldl (λ (x acc) (set-union acc (get-dynamic-jumps x))) (set (caar blocks)) blocks)
)

(fc-define-func "reduce" reduce)
(fc-define-func "evaluate" eval-expr)
(fc-define-func "get-new-read-statement" get-new-read-statement)
(fc-define-func "static?" static?)
(fc-define-func "find-blocks-in-pending" find-blocks-in-pending)