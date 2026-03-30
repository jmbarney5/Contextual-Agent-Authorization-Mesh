## Previous Reply (Sent)

Subject: Re: [Rats] Follow-up of draft-sardar-rats-sec-cons: Relay Attacks in Intra-handshake Attestation for Confidential Agentic AI Systems
To: Muhammad Usama Sardar <muhammad_usama.sardar@tu-dresden.de>
Cc: rats@ietf.org

Hi Usama,

Thank you for taking the time to review the CAAM draft and for providing such thoughtful feedback. Your insights, particularly regarding attestation binding mechanisms, are very helpful.

To address your specific questions:

1. Protocol Category
The CAAM draft utilizes **post-handshake attestation**, operating entirely at the application layer over an already established secure channel (e.g., via HTTP POST over TLS). We recognize that the term "protocol" might have been slightly ambiguous in the draft. We are updating the document to explicitly define CAAM as an "application-layer post-handshake attestation protocol" and will include a reference to your excellent taxonomy in `draft-usama-seat-intra-vs-post`.

2. Relay Attacks & Binding
Your findings regarding relay attacks in intra-handshake attestation reinforce our design choice. Because CAAM operates post-handshake, it intentionally sidesteps these vulnerabilities by cryptographically binding the attestation evidence to the current execution context and the specific request using DPoP, single-use nonces, and vault-backed JIT tokens. We are adding a section to our Security Considerations referencing your findings to highlight why a post-handshake approach with explicit application-layer binding was chosen for these multi-hop agentic scenarios.

3. Formal Threat Model Terminology
You are completely correct. Section 4.10 was intended to provide a structured threat analysis, not a mechanized symbolic proof (such as one conducted in ProVerif). To avoid any confusion with formal methods, we are renaming that section from "Formal Threat Model" to "Threat Analysis". 

Thank you again for the pointers to your work. We are incorporating your feedback into the next revision of the draft.

Best regards,

Jonathan Barney

---

## Reply to Usama - Round 2 (Sent)

Subject: Re: [Rats] Follow-up of draft-sardar-rats-sec-cons: Relay Attacks in Intra-handshake Attestation for Confidential Agentic AI Systems
To: Muhammad Usama Sardar <muhammad_usama.sardar@tu-dresden.de>
Cc: rats@ietf.org

Hi Usama,

Thank you for the positive feedback on the proposed changes, and especially for the pointer to `draft-fossati-seat-expat` [0]. I've reviewed it closely and I think there's a very natural alignment here.

Since CAAM operates entirely as a post-handshake protocol over an established TLS channel, EXPAT's use of Exported Authenticators (RFC 9261) with the `cmw_attestation` extension could serve as the concrete attestation transport for CAAM's agent context exchange. Rather than reinventing attestation binding, we would prefer to build on the formally analyzed foundation your team is developing.

That said, CAAM carries additional authorization-layer semantics that go beyond attestation evidence exchange. Specifically:

- **Relationship-Based Access Control (ReBAC) constraints** that must be verified at each hop in a multi-agent delegation chain.
- **Common Ancestor verification**, where an agent must prove that its delegating authority shares a governance root with the target resource.
- **Contextual authorization claims** (task scope, temporal bounds, environmental posture) that are evaluated continuously, not just at session establishment.

These are the "additional properties" that would benefit from formal verification. If your team is willing, I believe a focused exercise mapping CAAM's authorization invariants onto EXPAT's attestation model would be extremely valuable — both for strengthening our `-01` revision and for demonstrating how SEAT's work applies to agentic authorization scenarios.

As a concrete next step, I plan to author a short comparison document mapping CAAM's authorization requirements onto EXPAT's capabilities — essentially identifying where EXPAT covers our needs directly and where CAAM would need supplementary application-layer semantics. I'll share it via the RATS list (or as a GitHub issue on the CAAM repo, whichever you prefer) so you can review and annotate asynchronously. We are targeting the July 6 cutoff for `draft-barney-caam-01` and would like to incorporate any alignment with EXPAT into that revision, so having your input by mid-June would be ideal.

Thank you again for your generosity with both your time and your formal analysis expertise.

Best regards,

Jonathan Barney

[0] https://datatracker.ietf.org/doc/draft-fossati-seat-expat/

---

## Reply to Usama - Round 3 (DRAFT - Not Yet Sent)

Subject: Re: [Rats] Follow-up of draft-sardar-rats-sec-cons: Relay Attacks in Intra-handshake Attestation for Confidential Agentic AI Systems
To: Muhammad Usama Sardar <muhammad_usama.sardar@tu-dresden.de>
Cc: rats@ietf.org, seat@ietf.org

Hi Usama,

Thank you for the detailed inline responses — this is exactly the kind of exchange that sharpens both drafts.

**On attestation transport and avoiding "rolling your own crypto":**

Fully agreed on not reinventing attestation binding. However, I want to be explicit about where CAAM stands architecturally: we have deliberately designed CAAM to be **transport-agnostic** with respect to attestation. While EXPAT is an elegant candidate for that transport layer, we are also heavily tracking the **WIMSE** working group's approach — in particular their work on mTLS and TLS Exporter for transitive workload identity. 

CAAM must remain able to sit on top of either approach. Our goal is to provide the authorization mesh (evaluating ReBAC constraints and Common Ancestor relationships), not to dictate the underlying transport.

**On continuous attestation and the two implementation options:**

Your framing of the Passport vs. Background Check options is helpful. In CAAM's multi-hop A2A flows (Agent A delegates to Agent B, which delegates to Agent C), the **Passport model** seems necessary for latency — a Background Check round-trip at every hop in an N-agent chain would likely be prohibitive. That said, the WIMSE workload identity models we are tracking may end up dictating how this is actually implemented in practice for agentic identity. I plan to map this out in our analysis.

**On formal verification of the CAAM-to-EXPAT binding:**

I appreciate the offer. Because CAAM's transport layer is still undecided (and we are evaluating both EXPAT and WIMSE approaches), formal verification of a specific CAAM-to-EXPAT binding would be premature. We'd prefer to defer that until we have a clearer picture of the transport landscape.

**On the comparison document and co-authorship:**

I am going to keep the idea of a comparison document, but I want to broaden its scope. Rather than an EXPAT-focused mapping, it will be a **CAAM-owned Architectural Decision Record (ADR)** that evaluates multiple attestation transports: EXPAT, WIMSE approaches, and standard OAuth DPoP. 

For that reason, I'll respectfully decline the co-author offer so we can keep it as an independent evaluation for the CAAM repository first. I will, however, be very happy to share it with you and the SEAT list for review once we have a first pass.

**On the SEAT WG meeting next week:**

Thank you for the invitation. Unfortunately I won't be able to attend in person, but I'll follow the proceedings and any recordings closely. If there are specific discussion points from the session that bear on attestation transport choices, I'd appreciate a pointer afterward.

Thank you again for the rigor you bring to this space — it's exactly what the ecosystem needs.

Best regards,

JmB
