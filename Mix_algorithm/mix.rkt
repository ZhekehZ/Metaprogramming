#lang racket

(require "mix-extensions-for-flowchart-interpreter.rkt")
(provide mix)

(define mix
  '(
    (read PROGRAM DIVISION VS0)
    (_init
        (* Pending      := (set (list (caadr PROGRAM) VS0)))
        (* Marked       := (set))
        (* ResidualCode := (list (get-new-read-statement (car PROGRAM) VS0)))
        (goto _while-pending)
    )
    (_while-pending (if (set-empty? Pending) _final _while-pending-body))
    (_while-pending-body
        (* Pick    := (set-first Pending))
        (* Pending := (set-rest Pending))
        (* Marked  := (set-add Marked Pick))
        (* Code    := (list Pick))
        (* PP      := (car Pick))
        (* VS      := (cadr Pick))
        (goto _while-pending-body-lookup)
    )
    (_while-pending-body-lookup
        (* LookupD := (cdr PROGRAM))
        (goto _while-pending-body-lookup-body)
    )
    (_while-pending-body-lookup-body
        (* BB      := (car LookupD))
        (* LookupD := (cdr LookupD))
        (if (equal? PP (car BB)) _while-pending-body-found _while-pending-body-lookup-body)
    )
    (_while-pending-body-found
        (* BB   := (cdr BB))
        (goto _while-BB)
    )
    (_while-BB (if (empty? BB) _add-code _while-BB-body))
    (_while-BB-body
        (* Command := (car BB))
        (* BB      := (cdr BB))
        (goto _switch-Command)
    )
    (_switch-Command (* Val := (car Command)) (goto _case_assign))
    (_case_assign (if (equal? Val '*     ) _do-assign _case_goto  ))
    (_case_goto   (if (equal? Val 'goto  ) _do-goto   _case_if    ))
    (_case_if     (if (equal? Val 'if    ) _do-if     _case_return))
    (_case_return (if (equal? Val 'return) _do-return _defaut     ))
    (_defaut (return (format '"INVALID COMMAND ~a" Command)))
    (_do-assign
         (* X   := (second Command))
         (* Exp := (fourth Command))
         (if (set-member? DIVISION X) _static-assign _dynamic-assign)
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
         (* PP := (second Command))
         (goto _while-pending-body-lookup)
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
         (if (set-member? DIVISION Exp) _static-if _dynamic-if)
    )
    (_static-if
         (* PP := (bool (evaluate Exp VS) PP-then PP-else))
         (goto _while-pending-body-lookup)
    )
    (_dynamic-if
         (* Pick-then := (list PP-then VS))
         (* Pick-else := (list PP-else VS))
         (* Pending   := (set-add Pending Pick-then))
         (* Pending   := (set-add Pending Pick-else))
         (* Pending   := (set-subtract Pending Marked))
         (* Code      := (append Code (list (list 'if (reduce Exp VS) Pick-then Pick-else))))
         (goto _while-BB)
    )
    (_add-code 
        (* ResidualCode := (append ResidualCode (list Code)))
        (goto _while-pending)
    )
    (_final (return ResidualCode))
   )
)

