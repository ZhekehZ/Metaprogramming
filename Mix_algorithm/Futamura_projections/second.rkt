#lang racket

(require "../pretty-printer.rkt"
         "../../FlowChart_interpreter/flowchart.rkt"
         "../mix.rkt"
         "../TM_for_tests/turing.rkt"
)

(define DIVISION
  (set 'PROGRAM 'DIVISION
       'LabelLookup 'BB 'Command
       'X 'Exp 'PP-then 'PP-else
       'BlocksInPending 'LVA)
)

(define VS0
  (hash 'PROGRAM tm-int
        'DIVISION (set 'Q 'Qtail 'Instruction 'Operator 'Symbol 'NextLabel)
  )
)

;; MIX GENERATED COMPILER FOR TM 
(define compiler (fc-int mix `(,mix ,DIVISION ,VS0)))

(pretty-print compiler)
#| OUTPUT IS TOO BIG TO BE COPIED HERE |#
(printf ">>> COMPILER SIZE = ~a\n" (- (length compiler) 1))
#| OUTPUT: >>> COMPILER SIZE = 21 |#

;;   ----- TEST -----
(define compiled (fc-int compiler `(,(hash 'Q tm-program))))
(run-tm-unit-tests compiled)
(pretty-print compiled)
#| OUTPUT:

init0:
        Left := (quote ())
        if (equal? (quote 0) (safe-head Right))
                then goto jump1
                else goto loop2

jump1:
        Right := (cons (quote 1) (safe-tail Right))
        return Right

loop2:
        Left := (cons (safe-head Right) Left)
        Right := (safe-tail Right)
        if (equal? (quote 0) (safe-head Right))
                then goto jump1
                else goto loop2
|#
