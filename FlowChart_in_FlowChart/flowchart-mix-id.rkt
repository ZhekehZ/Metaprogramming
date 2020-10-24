#lang racket

(require "flowchart-int.rkt"
         "../FlowChart_interpreter/flowchart.rkt"
         "../Mix_algorithm/mix.rkt"
         "../Mix_algorithm/pretty-printer.rkt"
         "../Mix_algorithm/Test_cases/turing.rkt"
         rackunit)

;; THIRD PROJECTION
(define cogen (fc-int mix `(,mix ,mix-division ,(hash 'PROGRAM mix 'DIVISION mix-division))))


;; FlowChart to FlowChart compiler
(define fc-id-compiler (fc-int cogen `(,(hash 'PROGRAM fc-int-fc 'DIVISION fc-division))))

(pretty-display fc-id-compiler) (newline)
(printf ">>> ID COMPILER SIZE = ~a\n" (- (length fc-id-compiler) 1))
#| OUTPUT: >>> ID COMPILER SIZE = 17 |#

;; ---- TEST ----
(define tm-int-2 (fc-int fc-id-compiler `(,(hash 'PROGRAM tm-int))))

(define tm-tape-1 '(1 1 1 0 1 0 1))
(define tm-tape-2 '(1 1 1 1 1 1 0))

(define tm-expected-1 '(1 1 0 1))
(define tm-expected-2 '(1))

(test-case "TM tests"
    (check-equal? tm-expected-1 (fc-int tm-int-2 `((,tm-program ,tm-tape-1))))
    (check-equal? tm-expected-2 (fc-int tm-int-2 `((,tm-program ,tm-tape-2))))
    (printf ">>> TM tests: ALL TESTS PASSED!\n\n")
)
