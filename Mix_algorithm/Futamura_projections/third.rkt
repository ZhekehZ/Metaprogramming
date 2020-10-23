#lang racket

(require "../pretty-printer.rkt"
         "../../FlowChart_interpreter/flowchart.rkt"
         "../mix.rkt"
         "../Test_cases/turing.rkt"
)
(define VS0 (hash 'PROGRAM mix 'DIVISION mix-division))

;; THIRD PROJECTION
(define cogen (fc-int mix `(,mix ,mix-division ,VS0)))
(printf ">>> COMPILER GENERATOR SIZE = ~a\n" (- (length cogen) 1))
#| OUTPUT: >>> COMPILER GENERATOR SIZE = 33 |#


;;  ----- TEST -----
(define tm-compiler (fc-int cogen `(,
  (hash 'PROGRAM tm-int
        'DIVISION (set 'Q 'Qtail 'Instruction 'Operator 'Symbol 'NextLabel))))
  )

(define compiled (fc-int tm-compiler `(,(hash 'Q tm-program))))
(run-tm-unit-tests compiled)
(pretty-display compiled)
#| OUTPUT:

read Right 
init0:
	Left	:= '()
	if (equal? '0 (safe-head Right))
	  then goto jump1
	  else goto loop2
loop2:
	Left	:= (cons (safe-head Right) Left)
	Right	:= (safe-tail Right)
	if (equal? '0 (safe-head Right))
	  then goto jump1
	  else goto loop2
jump1:
	Right	:= (cons '1 (safe-tail Right))
	return Right 
|#