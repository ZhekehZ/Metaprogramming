#lang racket

(require "../../FlowChart_interpreter/flowchart.rkt"
         "../mix.rkt"
)

(define DIVISION
  (set 'PROGRAM 'DIVISION 'LabelLookup 'BB 'Command 'X 'Exp
       'PP-then 'PP-else 'BlocksInPending 'PP-static)
)

(define VS0 (hash 'PROGRAM mix 'DIVISION DIVISION))

(define cogen (fc-int mix `(,mix ,DIVISION ,VS0)))
(printf ">>> COMPILER SIZE = ~a\n" (- (length cogen) 1))
#| OUTPUT: >>> PROGRAM GENERATOR SIZE = 33 |#

