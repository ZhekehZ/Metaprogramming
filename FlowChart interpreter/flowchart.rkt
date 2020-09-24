#lang racket

(provide fc-int)
(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

;; Evaluate expression
;;   e   -- expression
;;   env -- hash table 
(define (eval-expr e env)
  (if (list? e)
    (if (equal? 'quote (first e))
      (second e)                                                                ;; constant expression
      (apply (eval (first e) ns) (map (lambda (x) (eval-expr x env)) (rest e))) ;; function call
    )   
    (hash-ref env e (lambda () (raise (format "INVALID VARIABLE NAME: ~a" e)))) ;; variable
  )
)

;; Evaluate block
;;   block  -- list of commands
;;   env    -- environment
;;   blocks -- hash table (block-name -> block)
(define (eval-block block env blocks)
  (define (continue env) (eval-block (rest block) env blocks))
  (define (jump block-name) (eval-block (hash-ref blocks block-name) env blocks))

  (match (first block)
    [`(:= ,name ,expr)       (continue (hash-set env name (eval-expr expr env)))]
    [`(if ,expr ,then ,else) (jump (if (eval-expr expr env) then else))]
    [`(goto ,label)          (jump label)]
    [`(return ,expr)         (eval-expr expr env)]
    [else                    (raise (format "INVALID COMMAND: ~a" (first block)))]
  )
)

;; FlowChart interpreter
(define (fc-int program input)
  (define (build-hash-table keys values) (make-immutable-hash (map cons keys values)))
  (define vars (build-hash-table (cdar program) input))
  (define block-lables (map first (rest program)))
  (define block-commands (map rest (rest program)))
  (define blocks (build-hash-table block-lables block-commands))
  (eval-block (first block-commands) vars blocks)
)