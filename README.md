GoalLock: All-or-Nothing Crowdfunding Smart Contract
====================================================

**GoalLock** is a secure and transparent **all-or-nothing crowdfunding smart contract** built on the Stacks blockchain. It ensures that funds are only released to campaign creators if the funding goal is met by the deadline. If the goal is not achieved, contributors can claim refunds, guaranteeing trust and fairness in decentralized fundraising.

* * * * *

Table of Contents
-----------------

1.  Features

2.  How It Works

3.  Contract Functions

4.  Error Codes

5.  Usage

6.  Contributing

7.  License

* * * * *

Features
--------

-   **All-or-Nothing Model**: Funds are only released to the campaign owner if the funding goal is met by the deadline.

-   **Secure Refunds**: Contributors can claim refunds if the campaign fails to meet its goal.

-   **Transparent Tracking**: Campaign details and contributions are publicly accessible on the blockchain.

-   **Deadline Enforcement**: Campaigns automatically end at the specified block height.

-   **Immutable Records**: All contributions and claims are permanently recorded on the blockchain.

* * * * *

How It Works
------------

1.  **Create a Campaign**: A user creates a campaign by specifying a funding goal and duration.

2.  **Contribute**: Users contribute funds to active campaigns.

3.  **Claim Funds**: If the campaign reaches its goal by the deadline, the owner can claim the funds.

4.  **Refund**: If the campaign fails, contributors can claim refunds.

* * * * *

Contract Functions
------------------

### Core Functions

#### `create-campaign`

-   **Description**: Creates a new crowdfunding campaign.

-   **Parameters**:

    -   `funding-goal`: The target amount to be raised (in micro-STX).

    -   `duration`: The number of blocks until the campaign ends.

-   **Returns**: The ID of the newly created campaign.

#### `contribute`

-   **Description**: Allows users to contribute funds to a campaign.

-   **Parameters**:

    -   `campaign-id`: The ID of the campaign.

    -   `amount`: The amount to contribute (in micro-STX).

-   **Returns**: `true` if the contribution is successful.

#### `claim-funds`

-   **Description**: Allows the campaign owner to claim funds if the goal is met.

-   **Parameters**:

    -   `campaign-id`: The ID of the campaign.

-   **Returns**: `true` if the funds are successfully claimed.

#### `refund`

-   **Description**: Allows contributors to claim refunds if the campaign fails.

-   **Parameters**:

    -   `campaign-id`: The ID of the campaign.

-   **Returns**: `true` if the refund is successfully processed.

### Read-Only Functions

#### `get-campaign`

-   **Description**: Retrieves details of a specific campaign.

-   **Parameters**:

    -   `campaign-id`: The ID of the campaign.

-   **Returns**: Campaign details (owner, goal, total-funded, deadline, active, claimed).

#### `get-contribution`

-   **Description**: Retrieves a contributor's contribution amount for a specific campaign.

-   **Parameters**:

    -   `campaign-id`: The ID of the campaign.

    -   `contributor`: The principal address of the contributor.

-   **Returns**: The contribution amount.

* * * * *

Error Codes
-----------

| Code | Error Message | Description |
| --- | --- | --- |
| `u300` | `ERR-NOT-AUTHORIZED` | The caller is not authorized to perform the action. |
| `u301` | `ERR-CAMPAIGN-NOT-FOUND` | The specified campaign does not exist. |
| `u302` | `ERR-CAMPAIGN-ACTIVE` | The campaign is still active and cannot be finalized. |
| `u303` | `ERR-GOAL-NOT-REACHED` | The campaign did not reach its funding goal. |
| `u304` | `ERR-DEADLINE-NOT-PASSED` | The campaign deadline has not yet passed. |
| `u305` | `ERR-ALREADY-CLAIMED` | The campaign funds have already been claimed. |

* * * * *

Usage
-----

### Prerequisites

-   A Stacks-compatible wallet (e.g., Hiro Wallet).

-   STX tokens for gas fees and contributions.

### Steps

1.  **Deploy the Contract**: Deploy the smart contract to the Stacks blockchain.

2.  **Create a Campaign**: Use the `create-campaign` function to start a new campaign.

3.  **Contribute**: Use the `contribute` function to fund active campaigns.

4.  **Claim Funds**: If the goal is met, the campaign owner can use `claim-funds` to withdraw the funds.

5.  **Refund**: If the campaign fails, contributors can use `refund` to reclaim their contributions.

* * * * *

Contributing
------------

We welcome contributions to improve GoalLock! Here's how you can help:

1.  **Report Issues**: Open an issue to report bugs or suggest improvements.

2.  **Submit Pull Requests**: Fork the repository, make your changes, and submit a PR.

3.  **Spread the Word**: Share GoalLock with your community!

* * * * *
**GoalLock** ensures trust, transparency, and fairness in decentralized crowdfunding. Start your campaign today! 🚀
