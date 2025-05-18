;; Entity Verification Contract
;; This contract validates reporting organizations

(define-data-var admin principal tx-sender)

;; Map of verified entities
(define-map verified-entities principal
  {
    name: (string-utf8 100),
    industry: (string-utf8 50),
    verification-date: uint,
    is-active: bool
  }
)

;; Error codes
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_ALREADY_VERIFIED u101)
(define-constant ERR_NOT_VERIFIED u102)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Register a new entity
(define-public (register-entity (entity principal) (name (string-utf8 100)) (industry (string-utf8 50)))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-none (map-get? verified-entities entity)) (err ERR_ALREADY_VERIFIED))

    (map-set verified-entities entity {
      name: name,
      industry: industry,
      verification-date: block-height,
      is-active: true
    })

    (ok true)
  )
)

;; Deactivate an entity
(define-public (deactivate-entity (entity principal))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (match (map-get? verified-entities entity)
      entity-data (begin
        (map-set verified-entities entity (merge entity-data { is-active: false }))
        (ok true)
      )
      (err ERR_NOT_VERIFIED)
    )
  )
)

;; Check if an entity is verified
(define-read-only (is-verified (entity principal))
  (match (map-get? verified-entities entity)
    entity-data (ok (get is-active entity-data))
    (err ERR_NOT_VERIFIED)
  )
)

;; Get entity details
(define-read-only (get-entity-details (entity principal))
  (map-get? verified-entities entity)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (var-set admin new-admin)
    (ok true)
  )
)
