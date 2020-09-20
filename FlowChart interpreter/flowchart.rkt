#lang racket

;; FlowChart interpreter

(define (build-hash-table keys values)
  (define (recursive-builder k v acc)
    (if (empty? k)
        acc
        (recursive-builder (rest k) (rest v)
                           (cons `(,(first k) . ,(first v)) acc)
        )
    )
  )
  (make-immutable-hash (recursive-builder keys values '()))
)

(define (fc-int program input)
  (define vars (build-hash-table (cdar program) input))
  (define block-lables (map (lambda (b) (first b)) (rest program)))
  (define block-commands (map (lambda (b) (rest b)) (rest program)))
  (define blocks (build-hash-table block-lables block-commands))
  (define (eval-expr e env)
    (if (list? e)
        (if (equal? 'quote (first e))
            (second e)
            (apply (eval (first e)) (map (lambda (x) (eval-expr x env)) (rest e)))
        )   
        (hash-ref env e)
    )
  )
  (define (eval-assignment x expr env) (hash-set env x (eval-expr expr env)))
  (define (exec-block block-name env)
    (define (process-command command env)
      (if (equal? (first command) ':=)
          (eval-assignment (second command) (third command) env)
          (list command env)
      )
    )
    (match (foldl process-command env (hash-ref blocks block-name))
      [(list jump env)
       (case (first jump)
         ['if     (exec-block ((if (eval-expr (second jump) env) third fourth) jump) env)]
         ['return (eval-expr (second jump) env)]
         ['goto   (exec-block (second jump) env)]
         )
       ]
      )
  )
  (exec-block (first block-lables) vars)
)


;; Post's TM interpreter on the FlowChart

(define tm-int
  '(
    (read program Right)
        (init
        (:= Left '())
        (:= S (car Right))
        (:= Right (cdr Right))
        (:= i '0)
        (:= N (length program))
        (goto loop)
    )
    (loop
        (:= SearchRest program)
        (:= j i)
        (if (< i N) gotoCommand finish)
    )
    (gotoCommand
        (:= Command (car SearchRest))
        (:= SearchRest (cdr SearchRest))
        (:= j (- j '1))
        (if (< j '0) switch gotoCommand)
    )
    
    (switch (:= Val (second Command)) (goto case-left))
    (case-left  (if (equal? Val 'left ) left  case-right))
    (case-right (if (equal? Val 'right) right case-write))
    (case-write (if (equal? Val 'write) write case-goto))
    (case-goto  (if (equal? Val 'goto ) goto case-if))
    (case-if    (if (equal? Val 'if   ) if finish))
    
    (left
        (:= Right (cons S Right))
        (:= S (car Left))
        (:= Left (cdr Left))
        (:= i (+ i '1))
        (goto loop)
    )
    (right
        (:= Left (cons S Left))
        (:= S (car Right))
        (:= Right (cdr Right))
        (:= i (+ i '1))
        (goto loop)
    )
    (write
        (:= S (third Command))
        (:= i (+ i '1))
        (goto loop)
    )
    (goto
        (:= i (third Command))
        (goto loop)
    )
    (if
        (:= Cond (equal? (third Command) S))
        (:= Command (list '0 'goto (fifth Command)))
        (:= i (+ i '1))
        (if Cond goto loop)
    )
    (finish (return (cons S Right)))
   )
)



;; Example

(define tm-example
  '(
    (0: if 0 goto 3)
    (1: right)
    (2: goto 0)
    (3: write 1)
    )
  )

(define tm-tape-example '(1 1 1 0 1 0 1))

;; (fc-int tm-int `(,tm-example ,tm-tape-example))