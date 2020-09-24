#lang racket

(require rackunit "turing.rkt" "flowchart.rkt")

(define tm-program
  '(
    (0: if 0 goto 4)
    (1: if _ goto 4)
    (2: right)
    (3: goto 0)
    (4: write 1)
    (5: left)
    (6: if 1 goto 5)
    (7: if 0 goto 5)
    (8: right)
    )
  )

(define tm-tape-1 '(1 1 1 0 1 0 1))
(define tm-tape-2 '(1 1 1 1 1 1 1))

(define expected-1 '(1 1 1 1 1 0 1))
(define expected-2 '(1 1 1 1 1 1 1 1))

(test-case "All tests"
    (check-equal? expected-1 (fc-int tm-int `(,tm-program ,tm-tape-1)))
    (check-equal? expected-2 (fc-int tm-int `(,tm-program ,tm-tape-2)))
    (writeln "ALL TESTS PASSED!")
)
