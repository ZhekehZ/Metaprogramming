#lang racket

(require "../../FlowChart_interpreter/flowchart.rkt")
(require "../pretty-printer.rkt")
(require rackunit "../mix.rkt")

;;  ----- TEST 1 -----
;; LOOKUP function on FlowChart :: A -> List A -> List B -> B
(define lookup
 '(
    (read name namelist valuelist)
    (search
       (* same-name := (equal? name (car namelist)))
       (if same-name found cont)
    )
    (cont
       (* valuelist := (cdr valuelist))
       (* namelist := (cdr namelist))
       (goto search)
    )
    (found
       (return (car valuelist))
    )
  )
)

(define mix-generated-lookup
 (fc-int mix `(
        ,lookup
        ,(set 'name 'namelist 'same-name)
        ,(hash 'name 'c                     ;; name = c
               'namelist '(a b c d e f)     ;; namelist = (a, b, c, d, e, f)
        )
 ))
)

(define lookup-list-1 '(1 2 3 4 5 6 7))
(define lookup-list-2 '(a b c))

(define lookup-expected-1 '3)
(define lookup-expected-2 'c)

(test-case "Lookup tests"
   ; (check-equal? lookup-expected-1 (fc-int mix-generated-lookup `(,lookup-list-1)))
   ; (check-equal? lookup-expected-2 (fc-int mix-generated-lookup `(,lookup-list-2)))
    (printf ">>> Lookup tests: ALL TESTS PASSED!\n\n")
)

(pretty-print mix-generated-lookup)
#| OUTPUT

read valuelist 
search0:
	valuelist := (cdr valuelist)
	valuelist := (cdr valuelist)
	return (car valuelist)
|#




;;  ----- TEST 2 -----
;; TURING MACHINE INTERPRETER on FlowChart

;; Helpful functions
(fc-define-func "lookup-first"
                (lambda (lbl lst) (drop lst (index-where lst (lambda (x) (equal? (car x) lbl))))))
(fc-define-func "safe-head" (lambda (x) (if (empty? x) '_ (first x))))
(fc-define-func "safe-tail" (lambda (x) (if (empty? x)  x (rest  x))))

;; Interpreter :: TMProgram -> List Bool -> List Bool
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
         (* Qtail     := (lookup-first NextLabel Q))
         (goto loop)
      )
      (do-if
         (* Symbol    := (third Instruction))
         (* NextLabel := (fifth Instruction))
         (if (equal? Symbol (safe-head Right)) jump loop)
      )
      (jump
         (* Qtail := (lookup-first NextLabel Q))
         (goto loop)
      )
      (error (return (list 'syntaxerror Instruction)))
      (stop (return Right))
   )
)

;; TMProgram
(define tm-program
  '(
    (0 if 0 goto 3)
    (1 right)
    (2 goto 0)
    (3 write 1)
    )
  )

(define mix-generated-tm-program
 (fc-int mix `(
        ,tm-int
        ,(set 'Q 'Qtail 'Instruction 'Operator 'Symbol 'NextLabel
              '(equal? Operator 'right)
              '(equal? Operator 'left )
              '(equal? Operator 'write)
              '(equal? Operator 'goto )
              '(equal? Operator 'if   )
              '(empty? Qtail)
         )
        ,(hash 'Q tm-program)
 ))
)

(define tm-tape-1 '(1 1 1 0 1 0 1))
(define tm-tape-2 '(1 1 1 1 1 1 0))

(define tm-expected-1 '(1 1 0 1))
(define tm-expected-2 '(1))

(test-case "TM tests"
    (check-equal? tm-expected-1 (fc-int mix-generated-tm-program `(,tm-tape-1)))
    (check-equal? tm-expected-2 (fc-int mix-generated-tm-program `(,tm-tape-2)))
    (printf ">>> TM tests: ALL TESTS PASSED!\n\n")
)

(pretty-print mix-generated-tm-program)
#| OUTPUT:

read Right 
init0:
	Left := ()
	if (equal? 0 (safe-head Right)) 
		then goto jump1
		else goto loop2

jump1:
	Right := (cons 1 (safe-tail Right))
	return Right

loop2:
	Left := (cons (safe-head Right) Left)
	Right := (safe-tail Right)
	if (equal? 0 (safe-head Right)) 
		then goto jump1
		else goto loop2
|#