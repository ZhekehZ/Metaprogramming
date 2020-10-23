#lang racket

(provide pretty-print pretty-display)

;; Pretty printer for mix output

(define (pretty-print program)
  (define (get-label table key)
    (define index (hash-ref table key (λ () (hash-count table))))
    (define label (string->uninterned-symbol (format "~a~a" (first key) index)))
    `(,(hash-set table key index) ,label)
  )
  
  (define (print-control stmt table)    
    (match stmt
      [`(goto ,label) (match (get-label table label) [`(,table ,l) `((goto ,l) ,table)])]
      [`(if ,x ,labelA ,labelB)
       (match (get-label table labelA) [`(,table ,lA)
           (match (get-label table labelB) [`(,table ,lB) `((if ,x ,lA ,lB) ,table)])])]
      [else `(,stmt ,table)]
    )
  )
  
  (define (print-block b table)
    (match (get-label table (first b))
      [`(,table ,label) (match (print-control (last b) table)
          [`(,control ,table) `((,label ,@(drop-right (rest b) 1) ,control) ,table)])
     ])
  )
  
  (for/fold ([acc `(,(first program))]
             [table (hash)]
             #:result (reverse acc))
            ([b (rest program)])
    (match (print-block b table) [`(,b ,table) (values (cons b acc) table)]))
)

(define (pretty-display prog)
  (define program (pretty-print prog))
  (define (println-all line) (for ([i line]) (printf "~a " i)) (newline))
  (println-all (first program))
  (for ([b (rest program)])
    (void
     (printf "~a:\n" (first b))
     (for ([st (rest b)]) (match st
       [`(if ,a ,b ,c) (printf "\tif ~a\n\t  then goto ~a\n\t  else goto ~a\n" a b c)]
       [`(* ,a := ,b) (printf "\t~a\t:= ~a\n" a b)]
       [else (void (printf "\t") (println-all st))]
      ))
   ))
  )