#lang racket

(require "../../FlowChart_interpreter/flowchart.rkt"
         "../pretty-printer.rkt"
         "../Test_cases/turing.rkt"
         "../Test_cases/lookup.rkt"
         "../mix.rkt"
         rackunit
)

;;  ----- TEST 1 -----
;; LOOKUP function on FlowChart

(define mix-generated-lookup
 (fc-int mix `(,lookup ,lookup-division
        ,(hash 'name 'c                     ;; name = c
               'namelist '(a b c d e f)     ;; namelist = (a, b, c, d, e, f)
        )
 ))
)

(run-lookup-unit-tests mix-generated-lookup)
(pretty-display mix-generated-lookup)
#| OUTPUT

read valuelist 
search0:
	valuelist	:= (cdr valuelist)
	valuelist	:= (cdr valuelist)
	return (car valuelist) 
|#

(newline) (newline)

;;  ----- TEST 2 -----
;; TURING MACHINE INTERPRETER on FlowChart

(define mix-generated-tm-program
 (fc-int mix `(,tm-int ,tm-division ,(hash 'Q tm-program)))
)

(run-tm-unit-tests mix-generated-tm-program)
(pretty-display mix-generated-tm-program)
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