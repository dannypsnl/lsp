#lang racket

(provide (all-defined-out))

(require (for-syntax racket/base
                     syntax/parse)
         racket/class
         racket/contract/base
         racket/match
         "json-util.rkt")

;;; lsp Position
(define-match-expander Pos
  (λ (stx)
    (syntax-parse stx
      [(_ #:line l #:char c)
       (syntax/loc stx
         (hash-table ['line (? exact-nonnegative-integer? l)]
                     ['character (? exact-nonnegative-integer? c)]))]))
  (λ (stx)
    (syntax-parse stx
      [(_ #:line l #:char c)
       (syntax/loc stx
         (hasheq 'line l
                 'character c))])))

;;; lsp Range
(define-json-expander Range
  [start any/c]
  [end any/c])

(define (racket-pos->Pos t pos)
  (define line (send t position-paragraph pos))
  (define line-begin (send t paragraph-start-position line))
  (define char (- pos line-begin))
  (Pos #:line line #:char char))

(define (Pos->racket-pos t pos)
  (match-define (Pos #:line line #:char char) pos)
  (line/char->racket-pos t line char))

(define (line/char->racket-pos t line char)
  (+ char (send t paragraph-start-position line)))

(define (start/end->Range t start end)
  (Range #:start (racket-pos->Pos t start) #:end (racket-pos->Pos t end)))
