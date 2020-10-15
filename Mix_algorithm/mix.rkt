#lang racket

(require "mix-extensions-for-flowchart-interpreter.rkt")
(provide mix)

(define mix
  '(
    (read PROGRAM DIVISION VS0)
    (_init
        (* Pending         := (set (list (caadr PROGRAM) VS0)))
        (* Marked          := (set))
        (* ResidualCode    := (list (get-new-read-statement (car PROGRAM) VS0)))
        (* BlocksInPending := (find-blocks-in-pending (rest PROGRAM) DIVISION))
        (goto _while-pending-prepare)
    )
    (_while-pending-prepare
        (* BB          := '0) ;; Preparing for dynamic IF: resetting all static variables
        (* PP-then     := '0)
        (* PP-else     := '0)
        (* Exp         := '0)
        (* X           := '0)
        (* Command     := '0)
        (* Static-PP   := '0)
        (* LabelLookup := '0)
        (goto _while-pending)
    )
    (_while-pending (if (set-empty? Pending) _final _while-pending-body))
    (_while-pending-body
        (* PP          := (first (set-first Pending)))
        (* VS          := (second (set-first Pending)))
        (* Pending     := (set-rest Pending))
        (* Marked      := (set-add Marked (list PP VS)))
        (* Code        := (list (list PP VS)))
        (* LabelLookup := BlocksInPending)

        (goto _while-pending-body-lookup)
    )
    (_while-pending-body-lookup ;; THE TRICK Begin
        (if (equal? PP (set-first LabelLookup)) _while-pending-body-found _labels-exists-assertation)
    )
    (_labels-exists-assertation
        (* LabelLookup := (set-rest LabelLookup))
        (if (set-empty? LabelLookup) _return-error _while-pending-body-lookup)
    )
    (_return-error
        (return (format '"INVALID LABEL ~a" PP))
    )
    (_while-pending-body-found
        (* BB := (rest (assoc (set-first LabelLookup) PROGRAM)))
        (goto _while-BB)
    )                           ;; THE TRICK End
    (_while-BB (if (empty? BB) _add-code _while-BB-body))
    (_while-BB-body
        (* Command := (first BB))
        (* BB      := (rest BB))
        (goto _case_assign)
    )
    (_case_assign (if (equal? (first Command) '*     ) _do-assign _case_goto  ))
    (_case_goto   (if (equal? (first Command) 'goto  ) _do-goto   _case_if    ))
    (_case_if     (if (equal? (first Command) 'if    ) _do-if     _case_return))
    (_case_return (if (equal? (first Command) 'return) _do-return _defaut     ))
    (_defaut (return (format '"INVALID COMMAND ~a" Command)))
    (_do-assign
         (* X   := (second Command))
         (* Exp := (fourth Command))
         (if (static? X DIVISION) _static-assign _dynamic-assign)
    )
    (_static-assign
         (* VS := (hash-set VS X (evaluate Exp VS)))
         (goto _while-BB)
    )
    (_dynamic-assign
         (* Code := (append Code (list (list '* X ':= (reduce Exp VS)))))
         (goto _while-BB)
    )
    (_do-goto
         (* BB := (rest (assoc (second Command) PROGRAM)))
         (goto _while-BB)
    )
    (_do-return
         (* Exp  := (second Command))
         (* Code := (append Code (list (list 'return (reduce Exp VS)))))
         (goto _while-BB)
    )
    (_do-if
         (* Exp     := (second Command))
         (* PP-then := (third Command))
         (* PP-else := (fourth Command))
         (if (static? Exp DIVISION) _static-if _dynamic-if)
    )
    (_static-if
         (* BB          := '0)
         (* X           := '0)
         (* Command     := '0)
         (* Static-PP   := '0)
         (* LabelLookup := '0)
         (if (evaluate Exp VS) _static-if-dynamic-true _static-if-dynamic-false)
    )
    (_static-if-dynamic-true
         (* BB := (rest (assoc PP-then PROGRAM)))
         (goto _while-BB)
    )
    (_static-if-dynamic-false
         (* BB := (rest (assoc PP-else PROGRAM)))
         (goto _while-BB)
    )
    (_dynamic-if
         (* Pending   := (set-union Pending
                                    (set-subtract (set (list PP-then VS) (list PP-else VS)) Marked)))
         (* Code      := (append Code (list (list 'if (reduce Exp VS)
                                                      (list PP-then VS)
                                                      (list PP-else VS)))))
         (goto _while-BB)
    )
    (_add-code 
        (* ResidualCode := (append ResidualCode (list Code)))
        (goto _while-pending-prepare)
    )
    (_final (return ResidualCode))
   )
)
