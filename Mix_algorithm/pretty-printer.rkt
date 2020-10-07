#lang racket

(provide pretty-print)

;; Pretty printer for mix output

(define (get-or-create table key)
  (define index (hash-ref table key (lambda () (hash-count table))))
  `(,(hash-set table key index) ,index)
)

(define (print-assignments all-actions)
  (define (pf:= x) (match x [`(* ,L := ,s) (printf (format "\t~a := ~a\n" L s))]))
  (for-each pf:= (drop-right all-actions 1))
)


(define (print-control all-actions table)
  (define (goto-case label table)
    (define table-index (get-or-create table label))
    (printf "\tgoto ~a~a\n\n" (first label) (second table-index))
    (first table-index)
  )
  (define (if-case x labelA labelB table)
    (define _-indexA (get-or-create table labelA))
    (define table-indexB (get-or-create (first _-indexA) labelB))
    (printf "\tif ~a \n\t\tthen goto ~a~a\n\t\telse goto ~a~a\n\n"
            x (first labelA) (second _-indexA) (first labelB) (second table-indexB))
    (first table-indexB)
  )
  (define (other-cases cmd arg table)
    (printf "\t~a ~a\n\n" cmd (~a arg))
    table
  )
    
  (match (last all-actions)
    [`(goto ,label) (goto-case label table)]
    [`(if ,x ,labelA ,labelB) (if-case x labelA labelB table)]
    [`(write ,x) (other-cases 'write x table)]
    [`(return ,x) (other-cases 'return x table)]
  )
)
  

(define (pretty-print program)
  (define (print-read-stmt read)
    (for-each (lambda (x) (printf "~a " x)) read)
    (newline)
  )
  (define (print-block b table)
    (define block-label (first b))
    (define table-index (get-or-create table block-label))
    (printf "~a~a:\n" (first block-label) (second table-index))
    (print-assignments (rest b))
    (print-control (rest b) (first table-index))
  )
  (print-read-stmt (first program))
  (foldl print-block (hash) (rest program))
  'FINISHED
)