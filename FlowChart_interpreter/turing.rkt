#lang racket

(require (only-in "flowchart.rkt" fc-define-func))
(provide tm-int)

(fc-define-func "safe-head" (λ (x) (if (empty? x) '_ (first x))))
(fc-define-func "safe-tail" (λ (x) (if (empty? x)  x (rest  x))))

;; Post's TM interpreter in FlowChart
(define tm-int
  '(
    (read program tape)
    (init
        (* Left :=  '())            ;; left tape part 
        (* S := (car tape))         ;; current symbol
        (* Right := (cdr tape))     ;; right tape part
        (* i := '0)                 ;; current command index
        (* N := (length program))   ;; END command index
        (goto loop)
    )
    (loop
        (* SearchList := program)
        (* CurrentSearchIndex := i)
        (if (< i N) lookup-command finish)
    )
    (lookup-command
        (* Command := (car SearchList))  ;; Current command
        (* SearchList := (cdr SearchList))
        (* CurrentSearchIndex := (- CurrentSearchIndex '1))
        (if (< CurrentSearchIndex '0) switch lookup-command)
    )
    
    (switch (* Val := (second Command)) (goto case-left))
    (case-left  (if (equal? Val 'left ) do-left  case-right))
    (case-right (if (equal? Val 'right) do-right case-write))
    (case-write (if (equal? Val 'write) do-write case-goto))
    (case-goto  (if (equal? Val 'goto ) do-goto  case-if))
    (case-if    (if (equal? Val 'if   ) do-if    fail))
    
    (do-left
        (* Right := (cons S Right))
        (* S := (safe-head Left))
        (* Left := (safe-tail Left))
        (goto inc-and-goto-loop)
    )
    (do-right
        (* Left := (cons S Left))
        (* S := (safe-head Right))
        (* Right := (safe-tail Right))
        (goto inc-and-goto-loop)
    )
    (do-empty
        (* S := '_)
        (goto inc-and-goto-loop)
    )
    (do-write
        (* S := (third Command))
        (goto inc-and-goto-loop)
    )
    (do-goto
        (* i := (third Command))
        (goto loop)
    )
    (do-if
        (* Cond := (equal? (third Command) S))
        (* Command := (list '_ 'goto (fifth Command)))
        (* i := (+ i '1))
        (if Cond do-goto loop)
    )
    (inc-and-goto-loop (* i := (+ i '1)) (goto loop))
    (fail (return (format '"INVALID COMMAND ~a" Command)))
    (finish (return (cons S Right)))
   )
)
