# CAAM Draft Outreach Emails

**To:** WIMSE, OAuth, and RATS Working Group Mailing Lists
**Context:** Introducing the newly submitted `draft-barney-caam-00` (Contextual Agent Authorization Mesh) to gather early feedback from the most relevant IETF working groups.

---

## 1. Draft to WIMSE (Workload Identity in Multi-Service Environments)
*Why: WIMSE focuses on workload identity; CAAM focuses on the authorization mesh and constraints for those agentic workloads.*

**Subject:** New Draft: Contextual Agent Authorization Mesh (CAAM) - Feedback requested

**Body:**
Hello WIMSE WG,

I'd like to share a new Internet-Draft we recently submitted: *Contextual Agent Authorization Mesh (CAAM)*. 

**Draft:** https://datatracker.ietf.org/doc/draft-barney-caam/

As this working group tackles the complexities of workload identity across boundaries, we’ve been looking closely at the authorization handshake that must occur between autonomous agents (A2A) and human-to-agent (H2A) interactions. 

CAAM proposes a post-discovery authorization mesh that relies heavily on Relationship-Based Access Control (ReBAC) and what we call "Common Ancestor Constraints." The goal is to provide a standardized way for agents to dynamically inherit and verify the context of the delegating identity, rather than relying on static, over-privileged service accounts.

Because WIMSE is actively defining how workload identities are structured and exchanged (including recent work on transitive attestation via mTLS and TLS Exporters), we believe the authorization constraints proposed in CAAM are highly complementary. We are evaluating WIMSE's transport mechanisms as the foundation for CAAM's contextual assertions. We would greatly appreciate any feedback from this group on the architectural approach, particularly regarding how these contextual constraints map to your current thinking on workload identity chains.

Thank you,
JmB (along with co-authors Roberto Pioli, Darron Watson)

---

## 2. Draft to OAuth Working Group
*Why: CAAM explicitly integrates with OAuth extensions (like XAA) and addresses token exchange/delegation for agents.*

**Subject:** Feedback requested: Contextual Agent Authorization Mesh (CAAM) & Token Delegation

**Body:**
Hello OAuth WG,

We have recently published a new Internet-Draft detailing the *Contextual Agent Authorization Mesh (CAAM)*, and we would love to get your eyes on it.

**Draft:** https://datatracker.ietf.org/doc/draft-barney-caam/

Our focus with CAAM is securing the authorization handshake for autonomous agents acting on behalf of users. A significant portion of our approach builds upon existing and proposed OAuth patterns, specifically integrating with Cross-App Access (XAA) and OpenID IPSIE. 

We are trying to solve the problem of agents operating outside of their designated scope by enforcing ReBAC and Common Ancestor Constraints during the token exchange process. We want to ensure that temporary, scoped credentials (like the ID-JAG in XAA) are contextualized perfectly for the agent's specific task.

Given this group's deep expertise in token delegation and cross-application access, your feedback would be invaluable. Specifically, we'd appreciate your thoughts on how CAAM interacts with current OAuth extensions and whether the constraint models we've proposed align well with the direction of XAA.

Thank you,
JmB (along with co-authors Roberto Pioli, Darron Watson)

---

## 3. Draft to RATS (Remote ATtestation ProcedureS)
*Why: RATS deals with assessing the trustworthiness of remote peers; CAAM requires trust context (like posture) to make authorization decisions.*

**Subject:** New Draft: CAAM - Utilizing attestation for agent authorization constraints

**Body:**
Hello RATS WG,

We recently submitted a new draft titled *Contextual Agent Authorization Mesh (CAAM)*. 

**Draft:** https://datatracker.ietf.org/doc/draft-barney-caam/

While CAAM is primarily an authorization specification dealing with Human-to-Agent and Agent-to-Agent flows, a core pillar of the architecture relies on understanding the posture and trustworthiness of the agent making the request. 

To enforce what we call "Common Ancestor Constraints" and dynamic ReBAC policies, the authorization mesh must consume verifiable claims about the agent's state, identity, and operating environment. We view the work coming out of RATS as foundational to making these contextual authorization decisions reliable.

We are sharing this draft here to get feedback from the attestation community. We want to ensure that the way CAAM expects to consume and evaluate trust assertions aligns with the architecture and evidence formats being defined in RATS. Any feedback or pointers on bridging our authorization mesh with standard attestation procedures would be highly appreciated.

Thank you,
JmB (along with co-authors Roberto Pioli, Darron Watson)