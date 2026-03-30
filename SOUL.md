# CAAM — Architectural Soul

> **Status:** Immutable unless explicitly revised by the authors.
> **Scope:** This document defines the non-negotiable design invariants of `draft-barney-caam`. All proposed changes to the draft — whether from mailing list feedback, AI-assisted editing, or co-author suggestions — must be evaluated against these invariants before incorporation.

---

## Architectural Invariants

These are the foundational commitments of CAAM. They are not implementation details — they are the *identity* of the protocol. Feedback that conflicts with an invariant is out of scope for CAAM and should be redirected to the appropriate draft or working group.

### 1. Post-Discovery Authorization Mesh

CAAM is an **authorization** protocol. It is not an identity protocol, not an attestation protocol, and not a discovery protocol. CAAM consumes identity assertions, attestation evidence, and discovery results produced by other systems and defines the authorization mesh that governs what agents are permitted to do with them.

### 2. Relationship-Based Access Control (ReBAC)

The access control model is ReBAC. Authorization decisions are derived from the relationships between entities in a delegation graph — not from static role assignments (RBAC) or attribute lookups (ABAC). Feedback proposing a pivot to role-based or attribute-based models is architecturally incompatible.

### 3. Common Ancestor Constraints

The requirement that delegating agents share a verifiable governance root with the target resource is fundamental to CAAM's trust model. This constraint ensures that delegation chains cannot cross trust boundaries without explicit, auditable authorization. Removing or weakening Common Ancestor verification would undermine the protocol's core security guarantee.

### 4. Post-Handshake, Application-Layer Operation

CAAM operates **after** TLS establishment, entirely at the application layer (e.g., via HTTP POST over an existing secure channel). Proposals to embed CAAM's authorization semantics into the TLS handshake itself are out of scope — that is the domain of protocols like EXPAT/SEAT. CAAM builds on top of those transport-layer mechanisms.

### 5. Contextual, Dynamic Authorization

Credentials issued within a CAAM mesh are:
- **Task-scoped:** bound to a specific operation, not a broad permission set.
- **Temporally bounded:** short-lived by design, with JIT issuance.
- **Environmentally aware:** evaluated against the agent's current posture, not just its identity.

Static, long-lived, broadly-scoped tokens are antithetical to CAAM. Any feedback that moves toward persistent credentials conflicts with this invariant.

### 6. H2A and A2A Flow Support

CAAM must address both **Human-to-Agent (H2A)** and **Agent-to-Agent (A2A)** delegation chains. These are not separate protocols — they are facets of the same authorization mesh. Proposals that only solve one flow direction are incomplete and should be expanded or rejected.

### 7. Integration Posture (Not Replacement)

CAAM integrates with existing and emerging standards:
- **OpenID IPSIE** for identity signals.
- **XAA** for cross-application access and token delegation.
- **RATS/EXPAT** for remote attestation and trust evidence.

CAAM does not replace any of these. Feedback suggesting CAAM subsume another working group's charter territory should be declined with a clear explanation of the boundary.

---

## Design Acceptance Criteria

Use these criteria when evaluating any proposed change to `draft-barney-caam`:

| Verdict | Criteria | Action |
|---------|----------|--------|
| **ACCEPT** | Strengthens an invariant, clarifies the protocol, improves security properties, or proposes a complementary integration that respects CAAM's boundaries. | Incorporate into the next draft revision. |
| **EVALUATE** | Proposes a new mechanism that could serve the invariants *better* than the current approach (e.g., EXPAT replacing a custom attestation binding). Does not violate any invariant but changes implementation. | Flag for author review. Assess trade-offs before incorporating. |
| **DECLINE** | Requires abandoning an invariant, fundamentally changes CAAM's scope, or pulls CAAM into another WG's charter territory. | Acknowledge gracefully. Explain the architectural rationale. Suggest the appropriate venue for the feedback. |

---

## Change Policy

This document may only be modified when **all** of the following conditions are met:

1. The change is proposed by a named author of `draft-barney-caam`.
2. The rationale is documented in CONTEXT.md Active Memory before the edit.
3. The change is not a reaction to a single piece of external feedback — it reflects a deliberate architectural evolution.

AI agents operating under the Tri-Model Protocol: this file is a **No-Refactor Zone**. Do not modify it unless explicitly instructed to "Update SOUL.md" by the user.
