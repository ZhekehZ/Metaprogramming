#lang racket

(provide tm-int)

;; Post's TM interpreter in FlowChart
(define tm-int
  '(
    (read program tape)
    (init
        (:= Left '())             ;; left tape part 
        (:= S (car tape))         ;; current symbol
        (:= Right (cdr tape))     ;; right tape part
        (:= i '0)                 ;; current command index
        (:= N (length program))   ;; END command index
        (goto loop)
    )
    (loop
        (:= SearchList program)
        (:= CurrentSearchIndex i)
        (if (< i N) lookup-command finish)
    )
    (lookup-command
        (:= Command (car SearchList))  ;; Current command
        (:= SearchList (cdr SearchList))
        (:= CurrentSearchIndex (- CurrentSearchIndex '1))
        (if (< CurrentSearchIndex '0) switch lookup-command)
    )
    
    (switch (:= Val (second Command)) (goto case-left))
    (case-left  (if (equal? Val 'left ) do-left  case-right))
    (case-right (if (equal? Val 'right) do-right case-write))
    (case-write (if (equal? Val 'write) do-write case-goto))
    (case-goto  (if (equal? Val 'goto ) do-goto  case-if))
    (case-if    (if (equal? Val 'if   ) do-if    fail))
    
    (do-left
        (:= Right (cons S Right))
        (if (empty? Left) do-empty do-left-non-empty)
    )
    (do-right
        (:= Left (cons S Left))
        (if (empty? Right) do-empty do-right-non-empty)
    )
    (do-empty
        (:= S '_)
        (goto inc-and-goto-loop)
    )
    (do-left-non-empty
        (:= S (car Left))
        (:= Left (cdr Left))
        (goto inc-and-goto-loop)
    )
    (do-right-non-empty
        (:= S (car Right))
        (:= Right (cdr Right))
        (goto inc-and-goto-loop)
    )
    (do-write
        (:= S (third Command))
        (goto inc-and-goto-loop)
    )
    (do-goto
        (:= i (third Command))
        (goto loop)
    )
    (do-if
        (:= Cond (equal? (third Command) S))
        (:= Command (list '_ 'goto (fifth Command)))
        (:= i (+ i '1))
        (if Cond do-goto loop)
    )
    (inc-and-goto-loop (:= i (+ i '1)) (goto loop))
    (fail (return (format '"INVALID COMMAND ~a" Command)))
    (finish (return (cons S Right)))
   )
)
