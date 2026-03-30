# Contextual Agent Authorization Mesh (CAAM)

## Current Goal
Push the PACT-integrated version of the CAAM draft to a public repository to share with Brad Woodward and Yogi Porla. Continue collecting WG feedback through June 2026.

## Status
Active -- Draft 00 submitted. Feedback incorporation in progress. Targeting `draft-barney-caam-01` submission by July 6, 2026.

## Active Memory
- **[Completed]** Draft 00 was submitted and is active on the IETF Datatracker (`draft-barney-caam-00`).
- **[Completed]** Local repository structure (markdown, XML, and txt renderings) is set up under `projects/ietf-caam/`.
- **[Completed]** Emails sent to WIMSE, OAuth, and RATS mailing lists introducing the draft.
- **[Completed]** Received feedback from Muhammad Usama Sardar (RATS WG) on protocol categorization and threat model terminology.
- **[Completed]** Updated `draft-barney-caam-00.md` to clarify post-handshake attestation categorization, cite `I-D.usama-seat-intra-vs-post`, rename "Formal Threat Model" to "Threat Analysis", and add relay attack mitigation section.
- **[Completed]** Drafted and sent first reply email to Usama (`usama-reply-draft.md` — "Previous Reply" section).
- **[Completed]** Received second round of feedback from Usama (Mar 13, 2026): confirmed proposed changes look good; suggested CAAM reuse `draft-fossati-seat-expat` (EXPAT) for post-handshake attestation; offered to formally verify additional properties CAAM requires.
- **[Completed]** Drafted second reply to Usama (`usama-reply-draft.md` — "Round 2" section) proposing async collaboration via comparison document.
- **[Completed]** Received third round of feedback from Usama (Mar 13, 2026): confirmed alignment on avoiding custom crypto; flagged Passport vs. Background Check model choice for continuous attestation; offered to co-author the comparison document; invited to SEAT WG meeting at IETF 125; recommended CC'ing SEAT list.
- **[Completed]** Drafted third reply to Usama (`usama-reply-draft.md` — "Round 3" section): articulated CAAM's transport-agnostic stance, pivoted to highlight WIMSE (mTLS + TLS Exporter) as a co-equal transport candidate, politely deferred the formal verification offer, and declined EXPAT co-authorship in favor of a CAAM-owned ADR exploring multiple transports.
- **[Completed]** Send Round 3 reply to Usama (CC SEAT list).
- **[Deprecated]** Author the CAAM Attestation Transport ADR. Scope: evaluate EXPAT, WIMSE (mTLS+Exporter), and OAuth DPoP. *(Deprecated: WIMSE is obsolete given the superiority of PACT; CAAM will align with PACT instead of legacy WIMSE flows).*
- **[In Progress]** Collect additional feedback from WG mailing lists through June 2026.
- **[Pending]** Finalize `draft-barney-caam-01` incorporating all collected feedback and EXPAT alignment.
- **[Pending]** Submit `draft-barney-caam-01` to IETF Datatracker before July 6, 2026 cutoff.

## IETF 2026 Milestones & Deadlines
*Draft version update schedule aligned with IETF meeting cycles.*

| Meeting | Location | Dates | Draft Cutoff | Target |
|---------|----------|-------|--------------|--------|
| IETF 125 | Shenzhen, China | Mar 14-20, 2026 | Mar 2, 2026 (passed) | `draft-barney-caam-00` submitted |
| IETF 126 | Vienna, Austria | Jul 18-24, 2026 | **Jul 6, 2026** | `draft-barney-caam-01` |
| IETF 127 | San Francisco, USA | Nov 14-20, 2026 | **Nov 2, 2026** | `draft-barney-caam-02` (if needed) |

### Version Update Strategy
1. **Now - June 2026:** Collect and incorporate mailing list feedback. Key changes to address: EXPAT alignment for attestation transport, protocol categorization clarity, relay attack mitigations (post-handshake attestation), threat analysis terminology, and any additional WG input.
2. **Early June 2026:** Feature-freeze `draft-barney-caam-01`. Final review with co-authors (Roberto Pioli, Darron Watson).
3. **By July 6, 2026:** Submit `draft-barney-caam-01` to the IETF Datatracker via the I-D Submission Tool.
4. **July 18-24, 2026 (IETF 126):** Present updates at relevant WG sessions (RATS, WIMSE) if agenda slots are available.
5. **Post-IETF 126:** Evaluate whether a `-02` revision is needed for IETF 127 (Nov 2 cutoff).

## Deliverables
1. `draft-barney-caam-00` -- Submitted to IETF Datatracker (complete).
2. `draft-barney-caam-01` -- Incorporating feedback, targeting July 6, 2026 submission.
3. CAAM Attestation Transport ADR -- Evaluating EXPAT, WIMSE, OAuth DPoP (in progress).
4. `usama-reply-draft.md` -- Correspondence with Muhammad Usama Sardar (3 rounds complete).
5. `draft-barney-caam-02` -- If needed for IETF 127 (Nov 2, 2026 cutoff).

## Key Insights & Context
- **The Draft:** CAAM specifies a post-discovery authorization handshake focusing on Relationship-Based Access Control (ReBAC), Common Ancestor Constraints in H2A/A2A flows, and integration with OpenID IPSIE and XAA.
- **EXPAT Dependency (NEW):** `draft-fossati-seat-expat-02` defines post-handshake attestation using TLS Exported Authenticators (RFC 9261) with a `cmw_attestation` extension. Authored by Usama Sardar, Thomas Fossati, et al. Undergoing formal analysis. CAAM may adopt EXPAT as the attestation transport, keeping CAAM's authorization semantics (ReBAC, Common Ancestor, contextual claims) as application-layer payload. See: https://datatracker.ietf.org/doc/draft-fossati-seat-expat/
- **Key Contact:** Muhammad Usama Sardar (TU Dresden, RATS/SEAT WG) — active collaborator, has offered formal verification support.
- **Mailing Lists:** 
  - `wimse@ietf.org`: Relevant because CAAM deals heavily with workload/agent identities and cross-domain authorization.
  - `oauth@ietf.org`: Relevant because CAAM extends/integrates with OAuth patterns (like XAA).
  - `rats@ietf.org`: Relevant because agent context and constraints often rely on assertions of trust/attestation.
- **Tone:** IETF mailing list emails should be highly technical, humble (seeking feedback, not dictating standard), and directly highlight *why* the draft is relevant to that specific working group's charter.

## Technical/Domain Rules
*Are there specific constraints for this project?*
- Ensure cross-posting is handled carefully (usually better to send targeted emails to each list or clearly state cross-posting to avoid spam).
- Link directly to the Datatracker URL in all communications.

### Design Constraints
- **Architectural invariants are codified in [`SOUL.md`](SOUL.md).** This is the authoritative source of CAAM's non-negotiable design commitments (ReBAC, Common Ancestor Constraints, post-handshake operation, contextual dynamic authorization, H2A+A2A support, integration posture).
- **All proposed draft changes must be evaluated against `SOUL.md` before incorporation.** Use the Design Acceptance Criteria (ACCEPT / EVALUATE / DECLINE) defined there.
- **`SOUL.md` is a No-Refactor Zone.** Per the Tri-Model Protocol, AI agents must not modify this file unless the user explicitly instructs "Update SOUL.md." Treat it as Level 2 (Constitutional) governance for this project.
- **Incoming IETF feedback must pass the alignment gate** defined in [`ietf-feedback-template.md`](ietf-feedback-template.md) Step 0 before a reply is drafted or draft changes are proposed.