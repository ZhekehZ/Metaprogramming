#lang racket
;; Post's Turing Machine interpreter

(define (head lst) (if (empty? lst) '_ (first lst))) ;; safe first
(define (tail lst) (if (empty? lst) '() (rest lst))) ;; safe rest

;; performs one TM step
(define (tm-step prog n L s R)
  (define cmd (list-ref prog n))
  (case (second cmd)
    ['left  `(,(+ n 1) ,(tail L) ,(head L) ,(cons s R))]
    ['right `(,(+ n 1) ,(cons s L) ,(head R) ,(tail R))]
    ['write `(,(+ n 1) ,L ,(third cmd) ,R)]
    ['goto  `(,(third cmd) ,L ,s ,R)]
    ['if    `(,(if (equal? (third cmd) s) (fifth cmd) (+ n 1)) ,L ,s ,R)]
    [ else  `(,(+ n 1) ,L ,s ,R)]
  )
)

;; combines two tapes and a symbol into a single tape
(define (tm-concat L s R)
  (filter (λ (x) (not (equal? x '_)))
  (append (reverse L) (cons s R)))
)

;; starts the TM calculation
(define (tm-run prog tape)
  (define N (length prog))
  (define (do-step x y z t) (tm-step prog x y z t))
  (define (run args)
    (if (< (first args) N)
        (run (apply do-step args))
        (apply tm-concat (rest args))
    ) 
  )
  (run `(0 () ,(first tape) ,(rest tape)))
)



;; EXAMPLE

(define prog-example
  '(
    (0: if 0 goto 3)
    (1: right)
    (2: goto 0)
    (3: write 1)
   )
)

(define tape-example '(1 1 1 1 1 1 0 0 1))

(define run-example (tm-run prog-example tape-example))