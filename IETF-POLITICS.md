# CAAM — IETF Political Dynamics & Skepticism Guide

> **Status:** Active Reference
> **Purpose:** To guide AI assistants and authors in analyzing the strategic intent behind IETF mailing list feedback. IETF participation is a mix of technical rigor and strategic positioning. Feedback is rarely neutral.

When analyzing incoming feedback or drafting replies, you must apply **Strategic Skepticism**. Do not take collaboration offers, "free" work, or technical suggestions purely at face value. Evaluate the underlying Working Group (WG) dynamics and the sender's incentives.

---

## 1. The Core WGs and Their Strategic Posture

### WIMSE (Workload Identity in Multi-Service Environments)
- **Status:** High clout, enterprise-backed (Okta, Google, Microsoft).
- **Focus:** Transitive workload identity, mTLS, TLS Exporters, SPIFFE/SPIRE boundaries.
- **CAAM's Stance:** **Primary orbit.** CAAM aims to sit naturally on top of WIMSE's transport mechanisms. WIMSE solves the enterprise identity chaining problem; CAAM provides the authorization mesh (ReBAC, Common Ancestor). We want to maintain strong alignment here.

### SEAT (Secure End-to-End Attestation)
- **Status:** Niche, newer WG. Spun out to handle TLS-specific attestation transport (Exported Authenticators).
- **Focus:** Binding attestation evidence to a TLS session (e.g., EXPAT draft).
- **CAAM's Stance:** **Secondary option / Evaluate.** EXPAT is an elegant transport candidate, but SEAT is struggling for broad adoption. Aligning too closely with SEAT risks pigeonholing CAAM as "the SEAT use case" and inheriting their adoption delays. We remain transport-agnostic.

### RATS (Remote Attestation Procedures)
- **Status:** Stable, foundational.
- **Focus:** Evidence formats, appraisal architectures.
- **CAAM's Stance:** **Consumer.** CAAM consumes RATS assertions but does not dictate how they are generated. 

---

## 2. Analyzing Senders & Intent

When reading feedback, ask:
1. **What is the sender's WG affiliation?** Are they an author of a draft they are promoting?
2. **Are they trying to build a coalition?** If a draft (like EXPAT) lacks momentum, its authors will aggressively recruit new use cases (like CAAM) to justify WG adoption.
3. **What is the cost of "free" help?** Offers for "free formal verification" or "co-authorship" are strategic moves to lock CAAM into their ecosystem, gain normative leverage, and build academic/WG prestige. 

---

## 3. Rules of Engagement (The Skeptical Reply)

When drafting replies to IETF feedback:
- **Maintain Architectural Distance:** If someone proposes their protocol as *the* solution, reframe it as a *candidate*. Explicitly state that CAAM is transport-agnostic.
- **Pivot to Power:** If a niche WG tries to pull CAAM into their orbit, politely pivot by mentioning that we are also tracking the more dominant WG (e.g., WIMSE) and must remain compatible with both.
- **Control the Narrative:** Do not let other authors co-opt CAAM documents to push their drafts. Frame shared evaluations as "CAAM-owned Architectural Decision Records (ADRs)".
- **Decline Premature Lock-in:** Politely defer formal verification or binding commitments until the architectural landscape is settled.
- **Be Polite but Firm:** The tone should always be collaborative and thankful for the rigor, but architecturally cautious and independent.