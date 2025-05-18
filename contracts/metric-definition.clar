;; Metric Definition Contract
;; This contract standardizes sustainability measures

(define-data-var admin principal tx-sender)

;; Map of defined metrics
(define-map metrics (string-utf8 50)
  {
    name: (string-utf8 50),
    description: (string-utf8 500),
    unit: (string-utf8 20),
    category: (string-utf8 50),
    created-at: uint
  }
)

;; Error codes
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_METRIC_EXISTS u101)
(define-constant ERR_METRIC_NOT_FOUND u102)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Define a new metric
(define-public (define-metric
    (id (string-utf8 50))
    (name (string-utf8 50))
    (description (string-utf8 500))
    (unit (string-utf8 20))
    (category (string-utf8 50)))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-none (map-get? metrics id)) (err ERR_METRIC_EXISTS))

    (map-set metrics id {
      name: name,
      description: description,
      unit: unit,
      category: category,
      created-at: block-height
    })

    (ok true)
  )
)

;; Update an existing metric
(define-public (update-metric
    (id (string-utf8 50))
    (name (string-utf8 50))
    (description (string-utf8 500))
    (unit (string-utf8 20))
    (category (string-utf8 50)))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some (map-get? metrics id)) (err ERR_METRIC_NOT_FOUND))

    (map-set metrics id {
      name: name,
      description: description,
      unit: unit,
      category: category,
      created-at: block-height
    })

    (ok true)
  )
)

;; Get metric details
(define-read-only (get-metric (id (string-utf8 50)))
  (map-get? metrics id)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (var-set admin new-admin)
    (ok true)
  )
)
