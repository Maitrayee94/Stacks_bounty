;; Import Clarity-Bitcoin library
(use-trait clarity-bitcoin::clarity-bitcoin-trait .clarity-bitcoin-trait)

;; Define NFT using SIP-009 standard
(define-non-fungible-token my-nft uint)

;; Constants
(define specific_sender_address "tb1qzh54u7ae4nx5da2a85j04azrdlzuduy2lnwwcl")
(define specific_recipient_address "tb1q0fqsg3zhwnpndscdqfg3r8t04lz6d5uakjvc3p")
(define specific_amount 0.005)

;; Function to check if a specific sender address exists in the inputs
(define-read-only (check-condition-1 (inputs (list 10 (tuple (sender principal) (amount uint)))) sender-address)
  (is-some? (find (fun (input) (is-eq? (get sender input) sender-address)) inputs))
)

;; Function to check if a specific recipient address and amount exist in the outputs
(define-read-only (check-condition-2 (outputs (list 10 (tuple (recipient principal) (amount uint)))) recipient-address amount)
  (is-some? (find (fun (output) (and (is-eq? (get recipient output) recipient-address) (is-eq? (get amount output) amount))) outputs))
)

;; Function to parse the Bitcoin transaction and check conditions
(define-read-only (parse-bitcoin-transaction (tx-bytes (buff 1000)))
  (let (
    (parsed-tx (unwrap-panic (clarity-bitcoin::parse-tx tx-bytes)))
    (inputs (get inputs parsed-tx))
    (outputs (get outputs parsed-tx))
  )
    (and (check-condition-1 inputs specific_sender_address)
         (check-condition-2 outputs specific_recipient_address specific_amount))
  )
)

;; Function to mint the NFT if the conditions are met
(define-public (mint-nft-if-conditions-met (tx-bytes (buff 1000)) (recipient principal) (token-id uint))
  (begin
    (asserts! (parse-bitcoin-transaction tx-bytes) (err "Transaction conditions not met"))
    (unwrap! (nft-mint? my-nft token-id recipient) (err "Failed to mint NFT"))
  )
)

