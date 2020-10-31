#lang racket

(require "flowchart-int.rkt"
         "../FlowChart_interpreter/flowchart.rkt"
         "../Mix_algorithm/mix.rkt"
         "../Mix_algorithm/pretty-printer.rkt"
         "../Mix_algorithm/Test_cases/turing.rkt"
         rackunit)

;; ---- TEST ----
(define (run-minimal-test test-name executor)
  (define tm-tape-1 '(1 1 1 0 1 0 1))
  (define tm-tape-2 '(1 1 1 1 1 1 0))

  (define tm-expected-1 '(1 1 0 1))
  (define tm-expected-2 '(1))

  (test-case (format "Test: ~a" test-name)
      (check-equal? tm-expected-1 (executor tm-tape-1))
      (check-equal? tm-expected-2 (executor tm-tape-2))
      (printf ">>> ~a: OK!\n\n" test-name)
  )
)

;; ---- FIRST PROJECTION ----
;;   tm-interpreter := mix (fc-int, tm-int)
(define tm-interpreter (fc-int mix `(,fc-int-fc ,fc-division ,(hash 'PROGRAM tm-int))))
;;   test: λ tape. tm-interpreter (tm-program, tape) 
(run-minimal-test "1st projection" (λ (tape) (fc-int tm-interpreter `((,tm-program ,tape)))))



;; ---- SECOND PROJECTION ----
;;   fc-interpreter := mix (mix, fc-int)
(define fc-interpreter (fc-int mix `(,mix ,mix-division
                                          ,(hash 'PROGRAM fc-int-fc 'DIVISION fc-division))))
;;   test: λ tape. fc-int (fc-interpreter (tm-int, tm-program, tape))
(run-minimal-test "2nd projection"
                  (λ (tape) (fc-int (fc-int fc-interpreter
                                           `(,(hash 'PROGRAM tm-int
                                                    'INPUT `(,tm-program ,tape))))
                                    '())))



;; ---- THIRD PROJECTION ----
;;   cogen := mix (mix, mix)
(define cogen (fc-int mix `(,mix ,mix-division ,(hash 'PROGRAM mix 'DIVISION mix-division))))
;; FlowChart to FlowChart compiler
;;   fc-id-compiler := cogen (fc-int)
(define fc-id-compiler (fc-int cogen `(,(hash 'PROGRAM fc-int-fc 'DIVISION fc-division))))
;;   tm-int-2 := fc-id-compiler (tm-int)
(define tm-int-2 (fc-int fc-id-compiler `(,(hash 'PROGRAM tm-int))))
(run-minimal-test "3rd projection" (λ (tape) (fc-int tm-int-2 `((,tm-program ,tape)))))

;;;; (pretty-display fc-id-compiler) (newline)
(printf ">>> ID COMPILER SIZE = ~a\n" (- (length fc-id-compiler) 1))
#| OUTPUT: >>> ID COMPILER SIZE = 17 |#
