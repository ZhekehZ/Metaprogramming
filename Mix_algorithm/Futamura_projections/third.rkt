#lang racket

(require "../pretty-printer.rkt"
         "../../FlowChart_interpreter/flowchart.rkt"
         "../mix.rkt"
         "../TM_for_tests/turing.rkt"
)

(define DIVISION
  (set 'PROGRAM 'DIVISION 'LabelLookup 'BB 'Command 'X 'Exp
       'PP-then 'PP-else 'BlocksInPending)
)

(define VS0 (hash 'PROGRAM mix 'DIVISION DIVISION))

(define cogen (fc-int mix `(,mix ,DIVISION ,VS0)))
(printf ">>> COMPILER SIZE = ~a\n" (- (length cogen) 1))
#| OUTPUT: >>> PROGRAM GENERATOR SIZE = 33 |#


(define tm-compiler (fc-int cogen `(,
  (hash 'PROGRAM tm-int
        'DIVISION (set 'Q 'Qtail 'Instruction 'Operator 'Symbol 'NextLabel))))
  )

(define compiled (fc-int tm-compiler `(,(hash 'Q tm-program))))
(run-tm-unit-tests compiled)
(pretty-print compiled)
#| OUTPUT:

read Right 
init0:
	Left := (quote ())
	if (equal? '0 (safe-head Right)) 
		then goto jump1
		else goto loop2

jump1:
	Right := (cons (quote 1) (safe-tail Right))
	return Right

loop2:
	Left := (cons (safe-head Right) Left)
	Right := (safe-tail Right)
	if (equal? '0 (safe-head Right)) 
		then goto jump1
		else goto loop2
|#