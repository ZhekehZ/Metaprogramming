#lang racket

(require "flowchart-int.rkt"
         "../FlowChart_interpreter/flowchart.rkt"
         "../Mix_algorithm/mix.rkt"
         "../Mix_algorithm/pretty-printer.rkt"
         "../Mix_algorithm/TM_for_tests/turing.rkt")

;; MIX division
(define DIVISION
  (set 'PROGRAM 'DIVISION 'LabelLookup 'BB 'Command 'X 'Exp
       'PP-then 'PP-else 'BlocksInPending 'LVA)
)

(define VS0 (hash 'PROGRAM mix 'DIVISION DIVISION))

;; THIRD PROJECTION
(define cogen (fc-int mix `(,mix ,DIVISION ,VS0)))

(define fc-id-compiler (fc-int cogen `(,
  (hash 'PROGRAM fc-int-fc
        'DIVISION (set 'PROGRAM 'VarList 'Labels 'BlockCommands 'Blocks
                       'CurrentBlock 'Statement 'Command 'Expr 'Var
                       'Then 'Else 'Label))))
  )

;; (pretty-print fc-id-compiler)
;; (length fc-id-compiler)
(define compiled-tm (fc-int fc-id-compiler `(,(hash 'PROGRAM tm-int))))
(pretty-print compiled-tm)