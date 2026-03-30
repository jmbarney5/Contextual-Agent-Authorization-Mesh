# ADR 0001: Contextual Agent Authorization Mesh (CAAM) POC Architecture

## Status
Proposed

## Context
The Contextual Agent Authorization Mesh (CAAM), as described in IETF Draft `draft-barney-caam-00`, requires a robust, scalable architecture to govern Human-to-Agent (H2A) and Agent-to-Agent (A2A) flows. The fundamental requirement is to enforce "Least Privilege for Agents" through a sidecar-based authorization mediator utilizing Relationship-Based Access Control (ReBAC) and "Purpose-Bound" delegation.

In an N-hop agent chain, maintaining the integrity of the original user's intent and boundaries is paramount to preventing "Scope Creep." This is achieved through the **Session Context Object (SCO)**, which carries the contextual assertion (`ctx` claim) across all hops. 

For the initial Proof of Concept (POC), we need to select an identity and authorization stack capable of handling these complex requirements, distinguishing clearly between identity posture, policy enforcement, and fine-grained relationship authorization.

## Decision Drivers
*   **Enforcement of the SCO `ctx` Claim:** The architecture must reliably evaluate the `ctx` claim at every hop (sidecar) to prevent scope creep in N-hop A2A delegations.
*   **Discovery & Visibility:** The ability to discover "Shadow Agents" and assess non-human identity (NHI) risks dynamically.
*   **Decoupled Authorization:** Clear separation between the Policy Enforcement Point (PEP), Policy Decision Point (PDP), and the Policy Information Point (PIP) / Policy Store.
*   **ReBAC Support:** The system must natively support Knowledge Graph / ReBAC models to map complex agent-to-resource and agent-to-agent relationships.
*   **Time-to-Market:** Leveraging an existing enterprise-grade identity stack to accelerate MVP development while remaining interoperable (e.g., via IPSIE).

## Considered Options

### 1. Identity & Posture
*   **Okta Workforce Identity Cloud + Okta ISPM:** Okta Identity Security Posture Management (ISPM) provides out-of-the-box discovery of "Shadow Agents" and continuously assesses NHI risks, aligning perfectly with CAAM's need to govern unseen autonomous actors.
*   *Alternative:* Custom-built discovery scripts + generic SIEM. (Rejected due to high maintenance and lack of native NHI focus).

### 2. Policy Engine (PEP/PDP Logic)
*   **Okta OPA (Open Policy Agent):** Deploying OPA within the CAAM sidecar to act as the primary PEP/PDP. OPA provides the management plane and execution environment for Rego policies. It excels at Attribute-Based Access Control (ABAC), allowing it to evaluate the immediate contextual attributes within the SCO `ctx` claim (e.g., JWT signatures, time-of-day, IP addresses, and payload inspection).
*   **Alternative 1: Hexa (IDQL):** Hexa is excellent for multi-cloud policy orchestration and translation. *Rejected* because CAAM requires a highly localized, high-performance execution engine within a sidecar for N-hop A2A flows, whereas Hexa is more focused on translating policies to disparate target systems rather than acting as the micro-level PEP.
*   **Alternative 2: Raw Rego Engine:** Building a custom control plane for the open-source Rego engine. *Rejected* because Okta OPA provides enterprise management, log streaming, and bundle distribution out-of-the-box, saving significant MVP engineering time.
*   **Alternative 3: Zanzibar-only (e.g., FGA without OPA):** Relying entirely on FGA/Zanzibar for all authorization. *Rejected* because while Zanzibar is unparalleled for ReBAC (graph relations), it is fundamentally the wrong tool for evaluating real-time contextual attributes (like validating a cryptographic signature or checking a time-bound `ctx` claim). CAAM requires *both* ABAC (OPA) and ReBAC (FGA).

### 3. Fine-Grained / ReBAC (Policy Store)
*   **Okta FGA (Fine-Grained Authorization):** Based on Zanzibar, FGA offers a robust relationship-based access control engine. It integrates seamlessly with the rest of the Okta ecosystem.
*   **SpiceDB:** An open-source, Zanzibar-inspired database tailored for ReBAC. It offers deep querying capabilities over the knowledge graph and can run highly distributed.

### 4. Open-Source "Glue" Tools (MVP Additions)
*   **SPIFFE / SPIRE:** For workload identity and cryptographic attestation of the agents themselves (the "Who" of the autonomous actor).
*   **Envoy Proxy:** To serve as the foundational data plane for the CAAM sidecar, intercepting traffic and querying the OPA PDP.
*   **Neo4j / Memgraph:** If FGA/SpiceDB is insufficient for visualizing the contextual knowledge graph required by CAAM administrators, a dedicated graph database could act as an auxiliary PIP.

## Decision Outcome

We will proceed with the **Okta Suite (Workforce Identity, ISPM, OPA, and FGA)** as the foundational stack for the CAAM POC, augmented by **SPIFFE/SPIRE** for workload identity and **Envoy** for the sidecar proxy.

1.  **Posture & Discovery:** **Okta ISPM** will be deployed to continuously monitor and discover NHIs, mapping shadow agents before they are brought under CAAM governance.
2.  **Policy Engine vs. Policy Store:** 
    *   **Okta OPA (The Engine):** Will run in the Envoy sidecar. It evaluates the immediate context: verifying the SCO's cryptographic signature, checking token expiration, and enforcing the localized bounds of the `ctx` claim (e.g., "Can this agent make a network call to this specific endpoint right now?"). OPA is the stateless *rules engine*.
    *   **Okta FGA (The Store):** Will act as the centralized relationship and policy store (PIP). OPA will query FGA to answer ReBAC questions (e.g., "Is Agent B authorized to act on behalf of User A for Resource C?"). FGA holds the *stateful knowledge graph*.
3.  **SCO `ctx` Enforcement:** When an agent attempts an action, the sidecar intercepts the request. OPA extracts the SCO, reads the `ctx` claim (which defines the purpose-bound delegation constraints), and queries Okta FGA to confirm the relationship graph permits the action. If the `ctx` parameters are exceeded (e.g., attempting a write when the `ctx` only permits read, or traversing to an unauthorized hop), OPA denies the request, effectively neutralizing scope creep.

While **SpiceDB** is a powerful open-source alternative for the ReBAC layer, **Okta FGA** is selected for the POC to minimize integration friction with Okta ISPM and Workforce Identity, allowing the team to focus purely on implementing the CAAM IETF draft specifications rather than stitching disparate identity providers together.

## Consequences (Pros & Cons)

### Pros
*   **High Integrity Delegation:** The distinct separation between OPA (engine) and FGA (store) ensures the SCO `ctx` claim is evaluated against both real-time request attributes and the historical relationship graph.
*   **NHI Visibility:** Okta ISPM provides immediate ROI by illuminating the shadow agent landscape, a critical prerequisite for a zero-trust mesh.
*   **Standardized Interoperability:** Leveraging OPA and Okta aligns with the IPSIE profile for secure identity.
*   **Implementation Speed:** A unified Okta stack significantly reduces the integration overhead for the MVP.

### Cons
*   **Vendor Lock-in Risk:** Heavy reliance on the Okta ecosystem (ISPM, FGA) could limit portability. We must ensure the sidecar architecture interacts with FGA via standardized API contracts (like OpenFGA) to allow swapping for SpiceDB in the future if needed.
*   **Sidecar Latency (FGA Network Hops):** Introducing OPA and remote calls to FGA in the critical A2A request path will add latency. To avoid or mitigate this latency, the POC architecture will implement:
    *   **Local Caching (Check API):** OPA must cache the FGA `Check` responses locally with a Time-To-Live (TTL), minimizing remote calls for repeated agent actions within the same session.
    *   **Context Enrichment (Macaroon Pattern):** At the first hop (H2A), the gateway resolves the broad FGA permissions and mints them into a deeply scoped, short-lived token (like a Macaroon or an enriched SCO JWT). Downstream A2A sidecars can statelessly validate this token via OPA, completely avoiding FGA network hops for intermediate steps. 
        *   *Security / Red Team Evaluation:* 
            *   **Advantage (Attenuation):** Macaroons cryptographically enforce N-hop attenuation. An agent can append caveats to restrict scope before passing it downstream, but can *never* elevate privileges. This acts as a robust defense-in-depth against lateral movement and scope creep if an intermediate agent is compromised.
            *   **Risk (Revocation):** Because validation is stateless, revoking a compromised token before its expiration is difficult. 
            *   **Risk (Bearer Token Theft):** If the Macaroon is stolen, it can be replayed. *Mitigation:* The Macaroon must be cryptographically bound to the workload's SPIFFE ID (Proof-of-Possession via mTLS) so it cannot be used outside the authorized A2A TLS tunnel.
    *   **Local PDP / Local Tuples:** Synchronizing a relevant subset of the FGA relationship graph directly to the sidecar's memory for critical workloads.
*   **Complexity of State:** Managing the SCO lifecycle and ensuring the `ctx` claim correctly narrows at each hop (attenuation) requires complex custom logic within OPA.