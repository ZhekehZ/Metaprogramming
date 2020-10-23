#lang racket

(require "../FlowChart_interpreter/flowchart.rkt")
(provide fc-int-fc fc-division)

;; Helpful functions
(fc-define-func "map-cons" (λ (x y) (map cons x y)))
(fc-define-func "map-first" (λ (x) (map first x)))
(fc-define-func "map-rest" (λ (x) (map rest x)))
(fc-define-func "evaluate" eval-expr)

;; FlowChart division for Mix
(define fc-division
  (set 'PROGRAM 'VarList 'Labels 'BlockCommands 'Blocks 'CurrentBlock
       'Statement 'Command 'Expr 'Var 'Then 'Else 'Label)
)

;; FlowChart interpreter on FlowChart
(define fc-int-fc
 '(
     (read PROGRAM INPUT)
     (_init
        (* VarList        := (cdar PROGRAM))
        (* Env            := (make-immutable-hash (map-cons VarList INPUT)))
        (* Labels         := (map-first (rest PROGRAM)))
        (* BlockCommands  := (map-rest (rest PROGRAM)))
        (* Blocks         := (make-immutable-hash (map-cons Labels BlockCommands)))
        (* CurrentBlock   := (car BlockCommands))
        (goto _eval-block)
     )
     (_eval-block
        (* Statement    := (first CurrentBlock))
        (* CurrentBlock := (rest CurrentBlock))
        (* Command      := (first Statement))
        (goto _switch-*)
     )
     (_switch-*      (if (equal? Command '*     ) _case-*      _switch-if))
     (_switch-if     (if (equal? Command 'if    ) _case-if     _switch-goto))
     (_switch-goto   (if (equal? Command 'goto  ) _case-goto   _switch-return))
     (_switch-return (if (equal? Command 'return) _case-return _default))
     (_default (return (format '"INVALID COMMAND: ~a" Command)))
     (_case-*
        (* Expr := (fourth Statement))
        (* Var  := (second Statement))
        (* Env  := (hash-set Env Var (evaluate Expr Env)))
        (goto _eval-block)
     )
     (_case-if
        (* Expr := (second Statement))
        (* Then := (third Statement))
        (* Else := (fourth Statement))
        (if (evaluate Expr Env) _case-if-then _case-if-else)
     )
     (_case-if-then
        (* CurrentBlock := (hash-ref Blocks Then))
        (goto _eval-block)
     )
     (_case-if-else
        (* CurrentBlock := (hash-ref Blocks Else))
        (goto _eval-block)
     )
     (_case-goto
        (* Label := (second Statement))
        (* CurrentBlock := (hash-ref Blocks Label))
        (goto _eval-block)
     )
     (_case-return
        (* Expr := (second Statement))
        (return (evaluate Expr Env))
     )
  )
)
