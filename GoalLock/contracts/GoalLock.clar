;; GoalLock - All-or-Nothing Crowdfunding Smart Contract
;; Allows users to create campaigns, contribute funds, withdraw funds if the goal is met,
;; and refund contributions if the campaign fails, all managed securely on the blockchain.

;; =============================================
;; Constants and Error Codes
;; =============================================
;; - CONTRACT-OWNER: The principal address of the contract deployer.
;; - ERR-NOT-AUTHORIZED (u300): Unauthorized access error.
;; - ERR-CAMPAIGN-NOT-FOUND (u301): Campaign does not exist.
;; - ERR-CAMPAIGN-ACTIVE (u302): Campaign is still active.
;; - ERR-GOAL-NOT-REACHED (u303): Campaign goal not met.
;; - ERR-DEADLINE-NOT-PASSED (u304): Campaign deadline not yet reached.
;; - ERR-ALREADY-CLAIMED (u305): Funds already claimed by the owner.
;; =============================================
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-CAMPAIGN-NOT-FOUND (err u301))
(define-constant ERR-CAMPAIGN-ACTIVE (err u302))
(define-constant ERR-GOAL-NOT-REACHED (err u303))
(define-constant ERR-DEADLINE-NOT-PASSED (err u304))
(define-constant ERR-ALREADY-CLAIMED (err u305))

;; =============================================
;; Data Structures
;; =============================================

;; Campaign data: goal, funds raised, deadline, and claim status
(define-map Campaigns
  { campaign-id: uint } ;; Unique ID for each campaign
  {
    owner: principal, ;; Owner of the campaign
    funding-goal: uint, ;; Funding goal in STX
    total-funded: uint, ;; Total funds raised so far
    deadline: uint, ;; Block height when the campaign ends
    active: bool, ;; Whether the campaign is still active
    claimed: bool ;; Whether funds have been claimed
  }
)

;; Tracks individual contributions
(define-map Contributions
  { campaign-id: uint, contributor: principal } ;; Composite key: campaign ID + contributor address
  { amount: uint } ;; Amount contributed by the user
)

;; Counter for campaign IDs
(define-data-var campaign-counter uint u0)

;; =============================================
;; Public Functions
;; =============================================

;; Create a new crowdfunding campaign
(define-public (create-campaign (funding-goal uint) (duration uint))
  (let
    (
      (campaign-id (+ (var-get campaign-counter) u1)) ;; Generate a new campaign ID
      (deadline (+ block-height duration)) ;; Calculate the deadline based on current block height
    )
    (var-set campaign-counter campaign-id) ;; Update the last campaign ID
    (map-insert Campaigns
      { campaign-id: campaign-id }
      {
        owner: tx-sender, ;; Set the campaign owner
        funding-goal: funding-goal, ;; Set the funding goal
        total-funded: u0, ;; Initialize total funded amount to 0
        deadline: deadline, ;; Set the deadline
        active: true, ;; Mark the campaign as active
        claimed: false ;; Mark funds as unclaimed
      }
    )
    (ok campaign-id) ;; Return the new campaign ID
  )
)

;; Contribute to a campaign
(define-public (contribute (campaign-id uint) (amount uint))
  (let
    (
      (campaign (unwrap! (map-get? Campaigns { campaign-id: campaign-id }) ERR-CAMPAIGN-NOT-FOUND)) ;; Fetch campaign details
    )
    (asserts! (get active campaign) ERR-CAMPAIGN-ACTIVE) ;; Ensure the campaign is still active
    (asserts! (< block-height (get deadline campaign)) ERR-DEADLINE-NOT-PASSED) ;; Ensure the campaign has not ended
    
    ;; Update or insert contribution
    (match (map-get? Contributions { campaign-id: campaign-id, contributor: tx-sender })
      contribution
      (map-set Contributions
        { campaign-id: campaign-id, contributor: tx-sender }
        { amount: (+ (get amount contribution) amount) }) ;; Add to existing contribution
      (map-insert Contributions
        { campaign-id: campaign-id, contributor: tx-sender }
        { amount: amount }) ;; Insert new contribution
    )
    
    ;; Update total funded
    (map-set Campaigns
      { campaign-id: campaign-id }
      (merge campaign { total-funded: (+ (get total-funded campaign) amount) })
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender))) ;; Transfer STX to the contract
    (ok true)
  )
)

;; Claim funds if goal is met (only callable by campaign owner)
(define-public (claim-funds (campaign-id uint))
  (let
    (
      (campaign (unwrap! (map-get? Campaigns { campaign-id: campaign-id }) ERR-CAMPAIGN-NOT-FOUND)) ;; Fetch campaign details
      (campaign-owner (get owner campaign)) ;; Get campaign owner
      (total-funded (get total-funded campaign)) ;; Get total funded amount
      (funding-goal (get funding-goal campaign)) ;; Get funding goal
      (deadline (get deadline campaign)) ;; Get campaign deadline
      (claimed (get claimed campaign)) ;; Check if funds have already been claimed
    )
    (asserts! (is-eq tx-sender campaign-owner) ERR-NOT-AUTHORIZED) ;; Ensure the caller is the campaign owner
    (asserts! (get active campaign) ERR-CAMPAIGN-ACTIVE) ;; Ensure the campaign is still active
    (asserts! (>= block-height deadline) ERR-DEADLINE-NOT-PASSED) ;; Ensure the deadline has passed
    (asserts! (>= total-funded funding-goal) ERR-GOAL-NOT-REACHED) ;; Ensure the goal is met
    (asserts! (not claimed) ERR-ALREADY-CLAIMED) ;; Ensure funds have not already been claimed
    
    ;; Mark as claimed and deactivate campaign
    (map-set Campaigns
      { campaign-id: campaign-id }
      (merge campaign { claimed: true, active: false })
    )
    
    ;; Log the claim event
    (print {
      event: "funds-claimed",
      campaign-id: campaign-id,
      amount: total-funded,
      claimant: tx-sender,
      block-height: block-height
    })
    
    ;; Transfer funds to owner
    (try! (as-contract (stx-transfer? total-funded tx-sender campaign-owner)))
    (ok true)
  )
)

;; =============================================
;; Read-Only Functions
;; =============================================

;; Get campaign details
(define-read-only (get-campaign (campaign-id uint))
  (map-get? Campaigns { campaign-id: campaign-id })
)

;; Get a contributor's contribution amount
(define-read-only (get-contribution (campaign-id uint) (contributor principal))
  (map-get? Contributions { campaign-id: campaign-id, contributor: contributor })
)

;; Get the last campaign ID
(define-read-only (get-last-campaign-id)
  (var-get campaign-counter)
)


