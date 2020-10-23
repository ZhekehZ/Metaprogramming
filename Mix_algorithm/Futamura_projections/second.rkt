#lang racket

(require "../pretty-printer.rkt"
         "../../FlowChart_interpreter/flowchart.rkt"
         "../mix.rkt"
         "../Test_cases/turing.rkt"
)

(define VS0 (hash 'PROGRAM tm-int 'DIVISION tm-division))

;; MIX GENERATED COMPILER FOR TM 
(define compiler (fc-int mix `(,mix ,mix-division ,VS0)))

(pretty-display compiler) (newline)
#| OUTPUT IS TOO BIG TO BE COPIED HERE |#

(printf ">>> COMPILER SIZE = ~a\n" (- (length compiler) 1))
#| OUTPUT: >>> COMPILER SIZE = 21 |#

;;   ----- TEST -----
(define compiled (fc-int compiler `(,(hash 'Q tm-program))))
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
