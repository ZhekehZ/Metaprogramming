#lang racket

(provide lookup lookup-division run-lookup-unit-tests)
(require "../../FlowChart_interpreter/flowchart.rkt"
         rackunit)

;; LOOKUP division for Mix
(define lookup-division (set 'name 'namelist 'same-name))

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

;; TEST ARGS
(define lookup-list-1 '(1 2 3 4 5 6 7))
(define lookup-list-2 '(a b c))

;; TEST RESUTLS
(define lookup-expected-1 '3)
(define lookup-expected-2 'c)


(define (run-lookup-unit-tests prog)
  (test-case "Lookup tests"
    (check-equal? lookup-expected-1 (fc-int prog `(,lookup-list-1)))
    (check-equal? lookup-expected-2 (fc-int prog `(,lookup-list-2)))
    (printf ">>> Lookup tests: ALL TESTS PASSED!\n\n")
  )
)