#lang racket

(require "flowchart-int.rkt"
         "../FlowChart_interpreter/flowchart.rkt"
         "../Mix_algorithm/Test_cases/turing.rkt"
         "../Mix_algorithm/Test_cases/lookup.rkt"
         rackunit)

;; ---- TEST1 -----
;; LOOKUP function
(define lookup-list-1 '(d (a b c d e f) (1 2 3 4 5 6 7)))
(define lookup-list-2 '(a (1 a 2 a 3) (5 4 3 2 1)))

(define lookup-expected-1 '4)
(define lookup-expected-2 '4)

(test-case "Lookup tests"
    (check-equal? lookup-expected-1 (fc-int fc-int-fc `(,lookup ,lookup-list-1)))
    (check-equal? lookup-expected-2 (fc-int fc-int-fc `(,lookup ,lookup-list-2)))
    (printf ">>> Lookup tests: ALL TESTS PASSED!\n\n")
)

;; ---- TEST2 -----
;; TURING MACHINE INTERPRETER
(define tm-tape-1 '(1 1 1 0 1 0 1))
(define tm-tape-2 '(1 1 1 1 1 1 0))

(define tm-expected-1 '(1 1 0 1))
(define tm-expected-2 '(1))

(test-case "TM tests"
    (check-equal? tm-expected-1 (fc-int fc-int-fc `(,tm-int (,tm-program ,tm-tape-1))))
    (check-equal? tm-expected-2 (fc-int fc-int-fc `(,tm-int (,tm-program ,tm-tape-2))))
    (printf ">>> TM tests: ALL TESTS PASSED!\n\n")
)