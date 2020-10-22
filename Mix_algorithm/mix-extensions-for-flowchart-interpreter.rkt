#lang racket

(require "../FlowChart_interpreter/flowchart.rkt")

;; static? :: Expr -> Either (Map VarName Constant) (Set VarName) -> Bool
;;   returns true if all free `expr`'s variables are in `vs` 
(define (static? expr vs)
  (define has? (λ (x) ((if (hash? vs) hash-has-key? set-member?) vs x)))
  (match expr
    [`',x #t]
    [`(,fun . ,args) (for/and ([a args]) (static? a vs))]
    [x (has? x)]
  )
)

;; reduce :: Expr -> Map VarName Constant -> Expr
(define (reduce expr vs)
  (define (local-reduce x) (reduce x vs))
  (if (static? expr vs)
    `(quote ,(eval-expr expr vs))
    (match expr
      [`(,func . ,args) `(,func ,@(map local-reduce args))]
      [x x]
    )
  )
)

;; get-new-read-statement :: ReadStmt VarName -> Map VarName Constant -> ReadStmt VarName
;;   where Read Varname stands for S-expression like (read x y z ...)
(define (get-new-read-statement read VS0)
  (define (isNotBinded x)(not (hash-has-key? VS0 x)))
  (cons 'read (filter isNotBinded (rest read)))
)

;; blocks-in-pending optimization
(define (find-blocks-in-pending blocks division)
  (define (get-dynamic-jumps block)
    (match (last block)
      [`(if ,cond ,lbl1 ,lbl2) #:when (not (static? cond division)) (set lbl1 lbl2)]
      [else (set)]
  ))
  (foldl (λ (x acc) (set-union acc (get-dynamic-jumps x))) (set (caar blocks)) blocks)
)


;; ---- Live variable analysis ----

;; dead-live-split-block :: Block -> ((Set VarName, Set VarName), List LabelName)
;;  returns ((set-of-dead, set-of-live), list-of-next-labels) for current block
(define (dead-live-split-block block)
  (define (add-dead-if-not-live x d/l)
    (match d/l [`(,d ,l) (if (set-member? l x) d/l `(,(set-add d x) ,l))])
  )
  (define (add-live-if-not-dead x d/l)
    (match d/l [`(,d ,l) (if (set-member? d x) d/l `(,d ,(set-add l x)))])
  )
  
  (define (process-exp exp d/l)
    (match exp
      [`',x d/l]
      [`(,fun . ,args) (foldl process-exp d/l args)]
      [x (add-live-if-not-dead x d/l)]
      )
    )

  (define (process stmt d/l)
    (match stmt
      [`(* ,x := ,s)   (add-dead-if-not-live x (process-exp s d/l))]
      [`(return ,s)   `(,(process-exp s d/l) ())]
      [`(goto ,lbl)   `(,d/l (,lbl))]
      [`(if ,c ,t ,e) `(,(process-exp c d/l) (,t ,e))]
     )
    )
  (foldl process `(,(set) ,(set)) block)
)

;; get-LVA-data :: Program -> Division -> Map LabelName (List VarName)
;;   returns mapping from labels to their live label lists
(define (get-LVA-data program division)
  ;; https://en.wikipedia.org/wiki/Live_variable_analysis
  (define initial (for/hash ([bl (rest program)])
                    (match (dead-live-split-block (rest bl))
                      [`((,kill ,gen) ,out) (values (first bl) `(,gen ,kill ,out))]
                      )
                    )
    )
  (define (step data)
    (define (collect out data)
      (foldl (λ (lbl acc) (set-union acc (first (hash-ref data lbl)))) (set) out)
      )
    (for/hash ([l (hash->list data)])
      (match l
        [`(,lbl ,live ,kill ,out)
         (values lbl `(,(set-union live (set-subtract (collect out data) kill)) ,kill ,out))]
      ))
    ) 
  (define (process data) ;;  Kleene closure for `step`
    (define new-data (step data))
    (if (equal? new-data data) data (process new-data))
   )
  (for/hash ([entry (hash->list (process initial))])
     (match entry [`(,lbl ,live ,_ ,_) (values lbl (set->list (set-intersect live division)))]))
)

;; pick-live :: LVA -> LabelName -> Map VarName Constant -> Map VarName Constant
;;   filters VS leaving L block live variables only
(define (pick-live lva-data label vs)
  (define (filter-live lva-data label vs)
    (for/hash ([val (hash-ref lva-data label)]) (values val (hash-ref vs val)))
  )
  (list label (filter-live lva-data label vs))
)

;; FC interpreter extensions registration
(fc-define-func "reduce" reduce)
(fc-define-func "evaluate" eval-expr)
(fc-define-func "get-new-read-statement" get-new-read-statement)
(fc-define-func "static?" static?)
(fc-define-func "find-blocks-in-pending" find-blocks-in-pending)
(fc-define-func "get-LVA-data" get-LVA-data)
(fc-define-func "pick-live" pick-live)