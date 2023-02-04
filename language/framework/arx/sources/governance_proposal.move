/// Define the GovernanceProposal that will be used as part of on-chain governance by governance.
///
/// This is separate from the governance module to avoid circular dependency between governance and
/// stake.
module arx::governance_proposal {
    friend arx::governance;

    struct GovernanceProposal has store, drop {}

    /// Create and return a GovernanceProposal resource. Can only be called by governance
    public(friend) fun create_proposal(): GovernanceProposal {
        GovernanceProposal {}
    }

    /// Useful for governance to create an empty proposal as proof.
    public(friend) fun create_empty_proposal(): GovernanceProposal {
        create_proposal()
    }

    #[test_only]
    public fun create_test_proposal(): GovernanceProposal {
        create_empty_proposal()
    }
}
