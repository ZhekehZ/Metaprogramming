#lang racket

(require "../../FlowChart_interpreter/flowchart.rkt"
         "../pretty-printer.rkt"
         "../TM_for_tests/turing.rkt"
         "../mix.rkt"
         rackunit
)

;;  ----- TEST 1 -----
;; LOOKUP function on FlowChart :: A -> List A -> List B -> B
(define lookup
 '(
    (read name namelist valuelist)
    (search
       (* same-name := (equal? name (car namelist)))
       (if same-name found cont)
    )
    (cont
       (* valuelist := (cdr valuelist))
       (* namelist := (cdr namelist))
       (goto search)
    )
    (found
       (return (car valuelist))
    )
  )
)

(define mix-generated-lookup
 (fc-int mix `(
        ,lookup
        ,(set 'name 'namelist 'same-name)
        ,(hash 'name 'c                     ;; name = c
               'namelist '(a b c d e f)     ;; namelist = (a, b, c, d, e, f)
        )
 ))
)

(define lookup-list-1 '(1 2 3 4 5 6 7))
(define lookup-list-2 '(a b c))

(define lookup-expected-1 '3)
(define lookup-expected-2 'c)

(test-case "Lookup tests"
    (check-equal? lookup-expected-1 (fc-int mix-generated-lookup `(,lookup-list-1)))
    (check-equal? lookup-expected-2 (fc-int mix-generated-lookup `(,lookup-list-2)))
    (printf ">>> Lookup tests: ALL TESTS PASSED!\n\n")
)

(pretty-print mix-generated-lookup)
#| OUTPUT

read valuelist 
search0:
	valuelist := (cdr valuelist)
	valuelist := (cdr valuelist)
	return (car valuelist)
|#




;;  ----- TEST 2 -----
;; TURING MACHINE INTERPRETER on FlowChart

(define mix-generated-tm-program
 (fc-int mix `(
        ,tm-int
        ,(set 'Q 'Qtail 'Instruction 'Operator 'Symbol 'NextLabel)
        ,(hash 'Q tm-program)
 ))
)

(run-tm-unit-tests mix-generated-tm-program)
(pretty-print mix-generated-tm-program)
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