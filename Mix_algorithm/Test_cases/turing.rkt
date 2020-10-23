#lang racket

(provide tm-int tm-division
         tm-program
         run-tm-unit-tests)
(require "../../FlowChart_interpreter/flowchart.rkt"
         rackunit
)


;; Helpful functions
(fc-define-func "lookup-fst" (λ (lbl lst) (drop lst (index-where lst (λ (x) (equal? (car x) lbl))))))
(fc-define-func "safe-head" (λ (x) (if (empty? x) '_ (first x))))
(fc-define-func "safe-tail" (λ (x) (if (empty? x)  x (rest  x))))

;; TM division for Mix
(define tm-division (set 'Q 'Qtail 'Instruction 'Operator 'Symbol 'NextLabel))

;; TURING MACHINE INTERPRETER on FlowChart
(define tm-int
  '(
      (read Q Right)
      (init
         (* Qtail := Q)
         (* Left  := '())
         (goto loop)
      )
      (loop (if (empty? Qtail) stop continue))
      (continue
         (* Instruction := (first Qtail))
         (* Qtail       := (rest Qtail))
         (* Operator    := (second Instruction))
         (goto cont0)
      )
      (cont0 (if (equal? Operator 'right) do-right cont1))
      (cont1 (if (equal? Operator 'left ) do-left  cont2))
      (cont2 (if (equal? Operator 'write) do-write cont3))
      (cont3 (if (equal? Operator 'goto ) do-goto  cont4))
      (cont4 (if (equal? Operator 'if   ) do-if    error))
      (do-right
         (* Left  := (cons (safe-head Right) Left))
         (* Right := (safe-tail Right))
         (goto loop)
      )
      (do-left
         (* Right := (cons (safe-head Left) Right))
         (* Left  := (safe-tail Left))
         (goto loop)
      )
      (do-write
         (* Symbol := (third Instruction))
         (* Right  := (cons Symbol (safe-tail Right)))
         (goto loop)
      )
      (do-goto
         (* NextLabel := (third Instruction))
         (* Qtail     := (lookup-fst NextLabel Q))
         (goto loop)
      )
      (do-if
         (* Symbol    := (third Instruction))
         (* NextLabel := (fifth Instruction))
         (if (equal? Symbol (safe-head Right)) jump loop)
      )
      (jump
         (* Qtail := (lookup-fst NextLabel Q))
         (goto loop)
      )
      (error (return (list 'syntaxerror Instruction)))
      (stop (return Right))
   )
)

;; Simple TM Program
(define tm-program
  '(
    (0 if 0 goto 3)
    (1 right)
    (2 goto 0)
    (3 write 1)
    )
  )

;; TEST ARGS
(define tm-tape-1 '(1 1 1 0 1 0 1))
(define tm-tape-2 '(1 1 1 1 1 1 0))

;; TEST RESUTLS
(define tm-expected-1 '(1 1 0 1))
(define tm-expected-2 '(1))


(define (run-tm-unit-tests prog)
  (test-case "TM tests"
      (check-equal? tm-expected-1 (fc-int prog `(,tm-tape-1)))
      (check-equal? tm-expected-2 (fc-int prog `(,tm-tape-2)))
      (printf ">>> TM tests: ALL TESTS PASSED!\n\n")
  )
)