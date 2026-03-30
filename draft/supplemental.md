# Contextual Agent Authorization Mesh (CAAM): An Architectural Framework for Autonomous Identity Provenance and Dynamic Discovery

The evolution of enterprise infrastructure toward autonomous and semi-autonomous agentic systems has introduced a fundamental crisis in identity and access management. Traditional security architectures, designed for static workloads and direct human-to-service interactions, are increasingly insufficient for managing the non-deterministic, ephemeral, and multi-hop nature of Large Language Model (LLM) agents.<sup>1</sup> The Contextual Agent Authorization Mesh (CAAM) is proposed as a comprehensive sidecar-based authorization mediator that provides the necessary "connective tissue" between identity provenance frameworks, such as the Interoperability Profiling for Secure Identity in the Enterprise (IPSIE) and the Secure Production Identity Framework for Everyone (SPIFFE), and the emerging standards for agentic interaction, specifically the Agent Registration and Discovery Protocol (ARDP).<sup>3</sup>


## The Identity Crisis in Autonomous Agentic Ecosystems

Current security models primarily address identity at two distinct layers: the human user (via OpenID Connect and IPSIE) and the machine workload (via SPIFFE/SPIRE).<sup>4</sup> However, autonomous agents occupy a hybrid space. An agent is a software workload that possesses its own identity but often operates with the delegated authority of a human user or another agent.<sup>7</sup> This hybridity creates a gap where traditional Role-Based Access Control (RBAC) fails to account for the ephemeral and purpose-driven nature of agentic tasks.<sup>9</sup>


<table>
  <tr>
   <td><strong>Security Dimension</strong>
   </td>
   <td><strong>Traditional Workload (SPIFFE)</strong>
   </td>
   <td><strong>Human User (IPSIE)</strong>
   </td>
   <td><strong>Autonomous Agent (CAAM)</strong>
   </td>
  </tr>
  <tr>
   <td><strong>Identity Type</strong>
   </td>
   <td>Cryptographic SVID.<sup>4</sup>
   </td>
   <td>Federable User Identity.<sup>5</sup>
   </td>
   <td>Composite Principal.<sup>9</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Lifespan</strong>
   </td>
   <td>Static or long-lived.<sup>1</sup>
   </td>
   <td>Session-based.<sup>10</sup>
   </td>
   <td>Task-ephemeral.<sup>9</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Decision Logic</strong>
   </td>
   <td>Deterministic.<sup>2</sup>
   </td>
   <td>Human-driven.<sup>11</sup>
   </td>
   <td>Probabilistic/Reasoning-based.<sup>2</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Trust Anchor</strong>
   </td>
   <td>Workload Attestor.<sup>6</sup>
   </td>
   <td>Identity Provider (IdP).<sup>10</sup>
   </td>
   <td>Dynamic Discovery + Context.<sup>3</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Authorization</strong>
   </td>
   <td>Static permissions.<sup>12</sup>
   </td>
   <td>Role-based.<sup>13</sup>
   </td>
   <td>Contextual/Purpose-based.<sup>9</sup>
   </td>
  </tr>
</table>


As agents become more agentic—moving from simple request-response patterns to independent reasoning and tool invocation—the risk of "identity dilution" and "authorization loops" grows.<sup>2</sup> Without a dedicated mesh to manage these interactions, organizations face a choice between over-privileging agents, which expands the blast radius of potential compromises, or restricting them to the point of functional uselessness.<sup>7</sup> CAAM is designed to resolve this tension by enforcing policy at the most granular level of the agent's internal reasoning loop.


## Architectural Foundations: SPIFFE, IPSIE, and ARDP Integration

To build a high-fidelity authorization mesh, CAAM must leverage the existing maturity of identity provenance standards while extending them to meet agentic requirements. The foundational pillars of CAAM are built upon the integration of machine-level attestation and enterprise-level user identity.


### PACT and Ephemeral Identity

Traditional identity models require continuous Identity Provider (IdP) attestation at every hop (e.g., ubiquitous SPIFFE/SPIRE deployments). This imposes a heavy infrastructure burden and creates friction across organizational boundaries. CAAM replaces the necessity of ubiquitous workload identity agents with the **Provenance-Attenuated Chain Token (PACT)** architecture.

In the PACT model, only the root IdP is required to maintain heavy Public Key Infrastructure (PKI). The IdP mints the Genesis Block of the intent token, which includes the original user's intent and an ephemeral Public Key. The user passes the block and the corresponding ephemeral Private Key to the first agent. This secures the chain without requiring an identity agent at every intermediary, enabling lightweight, cross-boundary federation.


### IPSIE as the Human Provenance Layer

While SPIFFE identifies the "what" and the "where," the IPSIE profiles from the OpenID Foundation identify the "for whom".<sup>5</sup> IPSIE streamlines the selection of identity providers and the exchange of user-specific attributes, entitlements, and risk signals.<sup>11</sup> When a human user initiates a task that requires an agent's assistance, their IPSIE-compliant identity token serves as the original source of authority.<sup>5</sup> CAAM uses this provenance to bind the agent's workload identity to the human's session identity, creating a composite principal that represents the full context of the request.<sup>8</sup>


### ARDP and the Discovery-Authorization Nexus

The Agent Registration and Discovery Protocol (ARDP), as defined in draft-pioli-agent-discovery, establishes a control plane for agents to advertise their capabilities and network endpoints.<sup>3</sup> However, discovery-time security in ARDP is currently focused on cryptographic proofs of control over an Agent Identifier (AID) and privacy-aware data redaction for authorized queries.<sup>3</sup> CAAM extends this by introducing the concept of "AuthZ-at-Discovery," where the security capabilities and policy compliance of an agent are verified *before* a session is established.<sup>3</sup>


## Critical Pressure Test: Multi-Hop Chains and Identity Dilution

The primary failure mode in multi-agent systems is the "Russian nesting doll" problem, where recursive delegation leads to the loss of original user context.<sup>8</sup> In an N-hop chain (User → Agent A → Agent B → Agent C), each hop introduces a new trust boundary.<sup>14</sup> Traditional OAuth 2.0 tokens, if not properly managed, can allow an agent at the end of the chain to inherit the full permissions of the original user without the user's explicit intent for that specific sub-agent to access sensitive data.<sup>7</sup>


### Addressing the Authorization Loop

An authorization loop occurs when an agent attempts to access a resource that requires a credential it does not possess, leading to a sequence of token requests that may eventually lead to privilege escalation or service degradation.<sup>3</sup> CAAM mitigates this by requiring that every token exchange in the chain include a "Purpose" claim that matches the original intent of the user.<sup>9</sup> If Agent B requests access to a resource on behalf of Agent A, the CAAM sidecar verifies that this specific sub-task was authorized in the original Session Context Object (SCO).<sup>8</sup>


### Metadata Gaps in ARDP Discovery

A critical gap in the current draft-pioli-agent-discovery is the lack of metadata regarding an agent's "Inference Boundary" and "Contextual Policy Adherence".<sup>3</sup> While ARDP provides registry:resolve and registry:query scopes, it does not inform a client whether an agent is capable of enforcing the specific data isolation policies required for a highly sensitive task.<sup>3</sup> CAAM addresses this by proposing new IANA attributes for the ARDP registry, including:



1. **Policy Compliance Hash**: A cryptographic hash of the agent's currently active policy set (e.g., OPA or Cedar bundles), allowing a client to verify that the agent is operating under the expected governance.<sup>19</sup>
2. **Inference Boundary Declaration**: A formal specification of the agent's semantic limits, defining what types of data it is authorized to combine and what inferences it is forbidden from drawing.<sup>2</sup>
3. **Trust Anchor Reference**: A pointer to the authority responsible for the agent's identity and behavioral attestation, linking discovery directly to the SPIFFE/SPIRE infrastructure.<sup>3</sup>


## Architectural Formalization: The CAAM Sidecar Model

The CAAM sidecar is the core enforcement mechanism of the mesh. It is a lightweight, high-performance proxy that runs alongside the agent workload, intercepting all internal and external communications.<sup>22</sup> This model is chosen specifically because it allows for the implementation of security controls without requiring modifications to the underlying agent's code or LLM architecture.<sup>13</sup>


### RFC 9334 (RATS) Alignment

The CAAM Mesh adopts the Remote ATtestation ProcedureS (RATS) architecture (RFC 9334) to ensure that contextual signals are not just present, but cryptographically verifiable. Within the mesh, the following RATS roles are defined:

* **Attester**: The Agent or Sub-Agent providing Evidence. This includes runtime state, hardware TEE (Trusted Execution Environment) status, and software manifest hashes. Every agent in a CAAM-compliant deployment MUST be capable of producing RATS Evidence that can be independently verified.
* **Verifier**: The CAAM Sidecar/Mesh component that processes Evidence against Endorsements (known good states from the SPIRE trust domain). The Verifier produces an Attestation Result that encodes the trustworthiness of the agent's current execution environment.
* **Relying Party**: The Resource Server (RS) that consumes the Attestation Result to authorize the tool call. The RS does not need to understand the raw Evidence; it relies on the Verifier's signed Attestation Result to make its access control decision.

By aligning with RATS, CAAM replaces informal "contextual signals" with formally defined "Attestation Evidence," providing a standards-based mechanism for establishing trust in dynamic, multi-hop agentic environments.


### Intercepting the Thought-Action-Observation (TAO) Loop

The "Thought-Action-Observation" (TAO) loop is the fundamental cycle through which an autonomous agent operates.<sup>22</sup>



1. **Thought**: The LLM processes inputs and internal memory to generate a plan or a specific tool call.<sup>2</sup>
2. **Action**: The agent executes the tool call, sends a message to another agent, or queries a database.<sup>2</sup>
3. **Observation**: The agent receives the results of the action and incorporates them into its next reasoning cycle.<sup>2</sup>

The CAAM sidecar intercepts this loop at the transition between "Thought" and "Action".<sup>22</sup> By acting as a semantic gateway, the sidecar analyzes the *intent* of the tool call before it reaches the network.<sup>2</sup> This is critical because LLM agents fail semantically rather than through binary errors; a tool call may be syntactically valid but functionally hazardous or unauthorized.<sup>2</sup>


### Mechanism for Impersonation vs. Delegation

CAAM utilizes the OAuth 2.0 Token Exchange protocol (RFC 8693) to manage the complex relationships between actors in a multi-hop chain.<sup>7</sup> It distinguishes between "Impersonation," where an agent acts *as* the user, and "Delegation," where an agent acts *on behalf of* the user while maintaining its own identity.<sup>7</sup>

In the CAAM delegation model, the resulting access token includes an act (actor) claim that captures the entire lineage of the request.<sup>8</sup>


<table>
  <tr>
   <td><strong>Request Step</strong>
   </td>
   <td><strong>Token Components</strong>
   </td>
   <td><strong>Resulting Identity State</strong>
   </td>
  </tr>
  <tr>
   <td>User initiates task.
   </td>
   <td>IPSIE User Token.<sup>5</sup>
   </td>
   <td>sub: HumanUser.<sup>8</sup>
   </td>
  </tr>
  <tr>
   <td>Agent A needs to call Agent B.
   </td>
   <td>Agent A SVID + User Token.<sup>7</sup>
   </td>
   <td>sub: HumanUser, act: AgentA.<sup>8</sup>
   </td>
  </tr>
  <tr>
   <td>Agent B needs to call Resource.
   </td>
   <td>Agent B SVID + Previous Token.<sup>8</sup>
   </td>
   <td>sub: HumanUser, act: AgentB { act: AgentA }.<sup>8</sup>
   </td>
  </tr>
</table>


This nested audit trail ensures that the resource server can make an authorization decision based on the entire chain, preventing a malicious or compromised intermediate agent from forging authority.<sup>9</sup> To maintain the principle of least privilege, CAAM mandates "Scope Attenuation," where each subsequent token in the chain must have an equal or smaller scope than its predecessor.<sup>14</sup>


### Provenance-Attenuated Chain Token (PACT)

While traditional token models handle coarse delegation, CAAM introduces the **Provenance-Attenuated Chain Token (PACT)** to establish cryptographically verifiable, multi-hop chains without the infrastructure burden of continuous centralized PKI:

1. **Genesis Block**: The root IdP mints the Session Context Object (SCO) as the Genesis Block (Block 0), embedding an ephemeral Public Key ($PK_1$) and signing it.
2. **Ephemeral Handover**: At each delegation hop, the agent receives the token and the ephemeral private key. If the agent attenuates the intent, it generates a new ephemeral keypair ($PK_{n+1}, SK_{n+1}$), creates a new block containing only the delta (attenuation constraints), signs it with $SK_n$, and passes the token and $SK_{n+1}$ forward.
3. **Intersection of Permissions**: An agent can ONLY down-scope (attenuate) a token. The final execution context is the strict mathematical intersection of all constraints applied in the chain.

This ensures absolute tamper resistance. Because each block signs the public key of the subsequent block, an intermediate agent cannot "unwrap" a block from the chain without invalidating the cryptographic signature of the subsequent hop.


## Solving the Fuzzy Search Leakage Problem

A unique challenge in agentic security is "Fuzzy Search Leakage," which occurs when an agent has authorized access to multiple disparate datasets and combines them in its internal memory (scratchpad) to draw unauthorized inferences.<sup>2</sup> For example, an agent with access to an employee's calendar and a corporate CRM might infer a confidential medical condition based on the combination of a "doctor's appointment" entry and a "disability claim" record, even if it was never explicitly authorized to handle health data.<sup>21</sup>


### Contextual Firewall Logic

CAAM implements a "Contextual Firewall" that enforces isolation within the agent's reasoning context.<sup>21</sup> This firewall is not based on IP addresses or ports, but on "Inference Boundaries".<sup>2</sup> The sidecar maintains a stateful view of the session context and applies "Contextual Redaction" or "Differential Privacy" filters to the information the agent can see.<sup>9</sup>

The logic of the contextual firewall can be expressed as a requirement for "Context Stewardship".<sup>21</sup> If an agent retrieves data from Source A, the CAAM sidecar "mutes" or restricts access to Source B for the duration of that specific sub-task if the combination of Source A and Source B is flagged as a high-risk inference vector.<sup>9</sup>


### Mathematical Foundations of Isolation

To quantify the isolation of information within the agent's context, CAAM can utilize the concept of the Markov membrane from probabilistic reasoning.<sup>27</sup> The sidecar acts as a statistical firewall that ensures the internal state of the agent's reasoning remains conditionally independent of unauthorized data combinations.<sup>27</sup>

Let $X$ be the agent's internal state, $S_1$ and $S_2$ be two data sources, and $B$ be the inference boundary defined by policy. The sidecar ensures that for any inference $I$ drawn by the agent:

$$P(I \mid S_1, S_2, X) = P(I \mid \text{Authorized}(S_1, S_2), X)$$

Where the $\text{Authorized}$ function represents the set of permissible inferences permitted by the boundary $B$.<sup>21</sup> If the combination is unauthorized, the sidecar applies a privacy-preserving transformation $T$ to the data such that the mutual information $I(S_1; S_2)$ within the scratchpad is minimized:

$$I(T(S_1); T(S_2)) \leq \epsilon$$

Where $\epsilon$ is the privacy budget defined by the enterprise security policy.<sup>22</sup> This approach allows the agent to remain useful while mathematically guaranteeing that it cannot synthesize prohibited knowledge.<sup>21</sup>


## IETF Internet-Draft Generation: CAAM Protocol Specifications

This section formalizes the CAAM protocol in the IETF markdown format, suitable for inclusion in an Internet-Draft.


### Terminology



* **Contextual Mesh**: A decentralized, sidecar-based authorization layer that enforces purpose-bound and context-aware access controls across a network of autonomous agents.<sup>23</sup>
* **Agent Principal**: The composite identity of an agent, incorporating its hardware-attested workload identity (SPIFFE ID) and its delegated human user context (IPSIE claims).<sup>4</sup>
* **Inference Boundary**: A documented and machine-enforceable specification that defines the permissible and prohibited conclusions an agent may draw from the combination of authorized data sources.<sup>2</sup>
* **Session Context Object (SCO)**: A cryptographically signed, transient data structure that encapsulates the intent, purpose, and provenance of an agentic interaction.<sup>9</sup>
* **Thought-Action-Observation (TAO) Interception**: The process by which an authorization sidecar monitors and regulates the internal reasoning steps of an LLM agent to prevent policy violations.<sup>22</sup>


### Protocol Overview: Negotiation and Capability Exchange

CAAM operates as a secondary control plane that sits between the Discovery Draft (draft-pioli-agent-discovery) and the Execution Protocol (e.g., MCP, HTTP, or gRPC).<sup>3</sup>



1. **Discovery Phase**: When a client searches for an agent via an ARDP Resolver, the Resolver returns the agent's endpoint along with its "CAAM Capability Block".<sup>3</sup> This block includes the agent's SPIFFE ID, its supported policy languages (e.g., Rego, Cedar), and its current "Inference Boundary" hash.<sup>19</sup>
2. **Negotiation Phase**: The client and the agent's CAAM sidecar perform a mutual attestation. The client provides its own identity proof and the SCO for the task.<sup>4</sup> The sidecar verifies the SCO against the user's IPSIE risk signals.<sup>11</sup>
3. **Establishment Phase**: If the negotiation is successful, a "Contextual Session" is established. The sidecar issues a short-lived, purpose-scoped delegation token that is used for all subsequent tool calls and inter-agent communications.<sup>7</sup>
4. **Enforcement Phase**: Throughout the session, the sidecar intercepts the TAO loop. It performs real-time validation of every tool call against the SCO and the Inference Boundary.<sup>22</sup>


### Security Considerations: Mitigating Prompt Injection

Prompt injection attacks, where a malicious input manipulates the agent's internal instructions, are a primary threat to autonomous systems.<sup>2</sup> CAAM treats prompt injection as a "Semantic Elevation of Privilege" attack.<sup>2</sup> By using an "Out-of-Band Policy Enforcement" model, the CAAM sidecar remains isolated from the agent's reasoning space.<sup>2</sup>

Even if an agent's internal state is compromised via prompt injection and it attempts to execute an unauthorized action (e.g., "Delete all financial records"), the sidecar intercepts the resulting tool call.<sup>2</sup> Because the sidecar's decision logic is deterministic and based on the externally verified SCO, it can block the action regardless of the agent's "belief" that the action is legitimate.<sup>12</sup> This creates a "hard" security boundary that is independent of the agent's probabilistic reasoning.<sup>2</sup>


### Contextual Risk Scoring (CRS)

Every request within the mesh is assigned a Contextual Risk Score (CRS), $S \in [0, 1]$, calculated by the Verifier based on the current Attestation Evidence, session provenance, and data classification.

$$S = w_1 \cdot \text{Provenance} + w_2 \cdot \text{EnvTrust} + w_3 \cdot \text{DataSensitivity}$$

Where $w_1 + w_2 + w_3 = 1$ and the weights are configurable per deployment. The individual factors are defined as:

* **Provenance**: The strength and freshness of the identity chain — how many hops from the original user, whether all intermediate SVIDs are valid, and whether the SCO has been tampered with.
* **EnvTrust**: The trustworthiness of the execution environment as determined by RFC 9334 Attestation Evidence — TEE status, software manifest integrity, and geographic compliance.
* **DataSensitivity**: The classification level of the target resource (e.g., public, internal, confidential, regulated PII).

**Remediation Tiers:**

| CRS Range | Risk Level | Remediation Action |
|-----------|------------|-------------------|
| $S < 0.3$ | Nominal | Seamless execution via JIT Scoped Tokens. No additional friction. |
| $0.3 \le S < 0.7$ | Elevated | Automatic Step-Up authentication (MFA) or Data Masking required before the tool call proceeds. |
| $S \ge 0.7$ | Critical | Human-in-the-Loop (HITL) mandatory. Execution is paused until an OIDC-based "Approval" signal is received from an authorized human supervisor. |

The CRS is recalculated on every tool call within a session, ensuring that risk assessments remain current as context evolves. A spike in CRS mid-session (e.g., due to an SSF risk event or a delegation to an untrusted sub-agent) triggers immediate re-evaluation and potential session downgrade.


### IANA Considerations: Agent Discovery Metadata Registry

This document proposes the creation of a new IANA registry for "Agent Discovery Security Metadata" to support CAAM integration with ARDP.<sup>3</sup>


<table>
  <tr>
   <td><strong>Attribute</strong>
   </td>
   <td><strong>Description</strong>
   </td>
   <td><strong>Policy Requirement</strong>
   </td>
  </tr>
  <tr>
   <td>caam_v1_supported
   </td>
   <td>Indicates support for the CAAM sidecar protocol.<sup>3</sup>
   </td>
   <td>Mandatory for CAAM.<sup>3</sup>
   </td>
  </tr>
  <tr>
   <td>sc_object_hash
   </td>
   <td>Hash of the current Session Context Object requirements.<sup>9</sup>
   </td>
   <td>Optional.<sup>20</sup>
   </td>
  </tr>
  <tr>
   <td>inf_boundary_v1
   </td>
   <td>Formal definition of the agent's inference limits.<sup>21</sup>
   </td>
   <td>Highly Recommended.<sup>2</sup>
   </td>
  </tr>
  <tr>
   <td>authz_policy_uri
   </td>
   <td>Location of the agent's OPA/Cedar policy manifest.<sup>19</sup>
   </td>
   <td>Mandatory for Mesh.<sup>28</sup>
   </td>
  </tr>
  <tr>
   <td>spiffe_trust_domain
   </td>
   <td>The trust domain for the agent's SVID.<sup>4</sup>
   </td>
   <td>Mandatory for ZTA.<sup>1</sup>
   </td>
  </tr>
</table>



## Logical Progression: Translating Intent via HEXA and IDQL

A critical requirement for CAAM is the ability to translate high-level human-readable intent into machine-enforceable policies.<sup>28</sup> This is achieved through the integration of the HEXA policy orchestration framework and the Identity Query Language (IDQL).<sup>13</sup>


### Policy Orchestration Workflow

The CAAM orchestration workflow follows a centralized-definition, localized-enforcement pattern.<sup>28</sup>



1. **Intent Capture**: A security administrator defines a high-level intent in IDQL (e.g., "Agents in the Finance group may only access PII for the purpose of 'Audit Validation'").<sup>13</sup>
2. **Translation**: The HEXA Policy Orchestrator uses its provider framework and policy-mapper SDK to translate this IDQL intent into a target-specific format, such as Rego for OPA-based sidecars or Cedar for AWS-native agents.<sup>12</sup>
3. **Distribution**: The translated policy bundles are pushed to the CAAM sidecars via a secure OPA Bundle Server or a similar mechanism.<sup>19</sup>
4. **Enforcement**: The sidecar evaluates the agent's tool calls in real-time against these bundles, using the metadata in the SCO to provide the necessary context for the decision.<sup>9</sup>


### Comparative Analysis: OPA vs. Cedar for Agentic AuthZ

The choice between Open Policy Agent (OPA) and AWS Cedar depends on the specific requirements of the agent's execution environment.<sup>12</sup>


<table>
  <tr>
   <td><strong>Feature</strong>
   </td>
   <td><strong>Open Policy Agent (OPA/Rego)</strong>
   </td>
   <td><strong>AWS Cedar</strong>
   </td>
  </tr>
  <tr>
   <td><strong>Logic Paradigm</strong>
   </td>
   <td>General-purpose, declarative Datalog.<sup>12</sup>
   </td>
   <td>Security-focused, formally verified.<sup>12</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Verification</strong>
   </td>
   <td>Unit tests and simulation.<sup>12</sup>
   </td>
   <td>Mathematical proof of correctness.<sup>12</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Extensibility</strong>
   </td>
   <td>Highly extensible for complex data.<sup>12</sup>
   </td>
   <td>Restricted to ensure deterministic performance.<sup>12</sup>
   </td>
  </tr>
  <tr>
   <td><strong>CAAM Fit</strong>
   </td>
   <td>Ideal for "Fuzzy Isolation" logic.<sup>12</sup>
   </td>
   <td>Ideal for high-velocity API gating.<sup>29</sup>
   </td>
  </tr>
</table>


For CAAM, OPA's expressiveness is often required to handle the complex state required for "Contextual Redaction" and "Fuzzy Isolation," while Cedar is preferred for environments where performance and formal safety guarantees are paramount.<sup>12</sup>


## Strategic Pillars for IETF Resonance

To ensure the CAAM draft is adopted and implemented by the IETF working groups and the broader industry, it must focus on three technical pillars that distinguish it from traditional IAM solutions.


### Pillar 1: The "Contextual Handover"

Unlike traditional RBAC, where permissions are static and tied to a role, agent authorization must be ephemeral and tied to a task.<sup>9</sup> The "Session Context Object" (SCO) is the vehicle for this "Contextual Handover".<sup>9</sup> It ensures that the "Purpose" of data access is transmitted alongside the identity, allowing the sidecar to make decisions based on *why* the agent is acting, not just *who* the agent is.<sup>9</sup> This aligns with the "Contextual Integrity" requirements for trustworthy AI (XAAS).<sup>22</sup>


### Pillar 2: Fuzzy Isolation and Differential Privacy

CAAM shifts the focus from "blocking access" to "managing inference".<sup>2</sup> Instead of a binary allow/deny, the sidecar can mandate "Contextual Redaction" or "Differential Privacy" filters.<sup>9</sup> If an agent pulls data from a sensitive source, the sidecar "mutes" the visibility of other conflicting data sources for the remainder of that specific sub-task.<sup>9</sup> This effectively creates a dynamic "Chinese Wall" policy within the agent's reasoning window.<sup>21</sup>


### Pillar 3: Interoperability as a Bridge

CAAM is positioned as the bridge between workload identity and user identity.<sup>1</sup> By using SPIFFE IDs to identify the agent instance and IPSIE to verify the human's standing, CAAM creates a universal standard for agentic identity that can span multi-cloud and federated environments.<sup>4</sup> This interoperability ensures that agent governance does not become siloed within individual platforms.<sup>13</sup>


## Advanced Governance: Stability and Alignment Monitoring

Beyond simple authorization, a mature CAAM implementation includes mechanisms for monitoring the "epistemic stability" of the agentic system.<sup>23</sup> Using concepts such as the "Alignment Stability Function" (ASF) and the "Veritas Phase-Coherence Equation" (VPCE), the mesh can detect when an agent's reasoning is beginning to drift from its authorized intent.<sup>23</sup>

These advanced functions serve as a "neurocosmic ethical guardian" for the agentic ecosystem, providing a meta-stability layer that can trigger a "SAFE_MODE" or a state rollback if the agent's internal state becomes incoherent or misaligned with the enterprise's charter.<sup>23</sup> This provides a final layer of defense against sophisticated, multi-turn extraction attacks that attempt to bypass static boundaries through semantic manipulation.<sup>23</sup>


## Summary of Architectural Requirements

The successful deployment of CAAM requires a coordinated effort across identity, discovery, and orchestration layers. The following table summarizes the key requirements for a CAAM-compliant agent environment.


<table>
  <tr>
   <td><strong>Component</strong>
   </td>
   <td><strong>Requirement</strong>
   </td>
   <td><strong>Standard Alignment</strong>
   </td>
  </tr>
  <tr>
   <td><strong>Agent Identity</strong>
   </td>
   <td>Hardware-attested, ephemeral workload identity.<sup>4</sup>
   </td>
   <td>SPIFFE/SPIRE.<sup>1</sup>
   </td>
  </tr>
  <tr>
   <td><strong>User Context</strong>
   </td>
   <td>Provenance-aware human identity with risk signals.<sup>10</sup>
   </td>
   <td>IPSIE / OIDC.<sup>5</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Discovery</strong>
   </td>
   <td>Authorized resolve and query with security metadata.<sup>3</sup>
   </td>
   <td>ARDP / draft-pioli.<sup>3</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Enforcement</strong>
   </td>
   <td>Sidecar-based TAO loop interception.<sup>22</sup>
   </td>
   <td>CAAM Sidecar Profile.<sup>22</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Delegation</strong>
   </td>
   <td>Nested actor claims with scope attenuation.<sup>8</sup>
   </td>
   <td>RFC 8693 (Token Exchange).<sup>7</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Policy</strong>
   </td>
   <td>Declarative, translated from high-level intent.<sup>13</sup>
   </td>
   <td>IDQL / HEXA / OPA.<sup>28</sup>
   </td>
  </tr>
  <tr>
   <td><strong>Isolation</strong>
   </td>
   <td>Inference-boundary aware contextual firewalls.<sup>2</sup>
   </td>
   <td>Context Stewardship.<sup>21</sup>
   </td>
  </tr>
</table>



## Formal Threat Model

The following threat model focuses on attacks specific to multi-agent orchestration environments. Traditional web application threats (XSS, CSRF, etc.) are out of scope; this section addresses threats that emerge from the agentic delegation and reasoning model.

| Threat | Attack Vector | CAAM Mitigation |
|--------|--------------|-----------------|
| **Token Unwrapping** | Downstream agent strips intermediate token layers to remove constraints. | **PACT Ephemeral Chain**: Removing any block mathematically breaks the signature of the subsequent block. Absolute tamper resistance. |
| **Lateral Movement** | Compromised agent attempts to pivot to unauthorized APIs. | **Intersection of Permissions**: An agent only possesses the ephemeral key for a specific transaction and can only *down-scope* the token. Blast radius is mathematically locked to the original intent. |
| **Agentic Confused Deputy** | Malicious intent passed from Agent A to a higher-privileged Agent B. | **Intent-Binding**: Mandatory signing of the `intent_claim`. The CAAM sidecar on Agent B verifies that the intent originated from an authorized SCO. |
| **Signal Spoofing** | Attacker faking a secure environment signal (IP geolocation, network segment). | **RFC 9334 Evidence**: Hardware-backed attestation (TPM/Enclave) of environment signals. |
| **Inference Boundary Bypass** | Agent combines data from multiple authorized sources to draw an unauthorized inference. | **Contextual Firewall**: The sidecar enforces Inference Boundaries via source-pair conflict matrices and Contextual Redaction. |
| **Prompt Injection as Privilege Escalation** | Malicious input manipulates the agent's internal instructions to request unauthorized tool calls. | **Out-of-Band Enforcement**: The CAAM sidecar's decision logic is deterministic and external to the agent's reasoning. |


## Conclusion: The Path Forward for Agentic Governance

The Contextual Agent Authorization Mesh (CAAM) represents a necessary evolution in Zero Trust Architecture for the age of autonomous AI. By formalizing the sidecar model, leveraging the strength of SPIFFE and IPSIE, and integrating deeply with the ARDP discovery plane, CAAM provides a robust framework for managing the unique risks of agentic systems. It solves the problems of multi-hop identity dilution and fuzzy context leakage by moving authorization from the network perimeter to the semantic center of the agent's reasoning process. As agents continue to become more autonomous, the implementation of a purpose-bound, context-aware mesh will be the defining characteristic of a secure and trustworthy AI enterprise. The transition from static roles to dynamic, task-based contextual authorization is not merely a technical upgrade; it is a fundamental requirement for the safe and accountable deployment of autonomous intelligence at scale.


#### Works cited



1. SPIFFE: Securing the identity of agentic AI and non-human actors - HashiCorp, accessed February 23, 2026, [https://www.hashicorp.com/en/blog/spiffe-securing-the-identity-of-agentic-ai-and-non-human-actors](https://www.hashicorp.com/en/blog/spiffe-securing-the-identity-of-agentic-ai-and-non-human-actors)
2. Securing Enterprise AI: Understanding the Security Risk Reality - BairesDev, accessed February 23, 2026, [https://www.bairesdev.com/blog/securing-enterprise-ai/](https://www.bairesdev.com/blog/securing-enterprise-ai/)
3. draft-pioli-agent-discovery-00 - Agent Registration and Discovery Protocol (ARDP), accessed February 23, 2026, [https://datatracker.ietf.org/doc/draft-pioli-agent-discovery/](https://datatracker.ietf.org/doc/draft-pioli-agent-discovery/)
4. Trustworthy AI Agents: Agent Identity & Attestation - Sakura Sky, accessed February 23, 2026, [https://www.sakurasky.com/blog/missing-primitives-for-trustworthy-ai-part-3/](https://www.sakurasky.com/blog/missing-primitives-for-trustworthy-ai-part-3/)
5. IPSIE Working Group - OpenID Foundation, accessed February 23, 2026, [https://openid.net/wg/ipsie/](https://openid.net/wg/ipsie/)
6. SPIRE Concepts - SPIFFE, accessed February 23, 2026, [https://spiffe.io/docs/latest/spire-about/spire-concepts/](https://spiffe.io/docs/latest/spire-about/spire-concepts/)
7. Zero Trust for AI Agents: Delegation, Identity and Access Control ..., accessed February 23, 2026, [https://developer.cyberark.com/blog/zero-trust-for-ai-agents-delegation-identity-and-access-control/](https://developer.cyberark.com/blog/zero-trust-for-ai-agents-delegation-identity-and-access-control/)
8. Identifying Agents with Token Exchange | Identity for AI - Developer, accessed February 23, 2026, [https://developer.pingidentity.com/identity-for-ai/identity/idai-token-exhange.html](https://developer.pingidentity.com/identity-for-ai/identity/idai-token-exhange.html)
9. OAuth and Agentic Identity and Zero Trust - Strata.io, accessed February 23, 2026, [https://www.strata.io/blog/agentic-identity/oauth-agentic-identity-zero-trust-ai-6b/](https://www.strata.io/blog/agentic-identity/oauth-agentic-identity-zero-trust-ai-6b/)
10. IPSIE Common Requirements Profile - OpenID on GitHub, accessed February 23, 2026, [https://openid.github.io/ipsie-common-requirements-profile/draft-ipsie-common-requirements-profile.html](https://openid.github.io/ipsie-common-requirements-profile/draft-ipsie-common-requirements-profile.html)
11. IPSIE – Charter - OpenID Foundation, accessed February 23, 2026, [https://openid.net/wg/ipsie/ipsie-charter/](https://openid.net/wg/ipsie/ipsie-charter/)
12. MCP Access Control: OPA vs Cedar Comparison - Natoma, accessed February 23, 2026, [https://natoma.ai/blog/mcp-access-control-opa-vs-cedar-the-definitive-guide](https://natoma.ai/blog/mcp-access-control-opa-vs-cedar-the-definitive-guide)
13. 2026 Guide to IDQL & Hexa Policy Orchestration - Strata.io, accessed February 23, 2026, [https://www.strata.io/blog/governance-standards/idql-hexa-new-identity-standard-policy-orchestration/](https://www.strata.io/blog/governance-standards/idql-hexa-new-identity-standard-policy-orchestration/)
14. Control the Chain, Secure the System: Fixing AI Agent Delegation - Okta, accessed February 23, 2026, [https://www.okta.com/blog/ai/agent-security-delegation-chain/](https://www.okta.com/blog/ai/agent-security-delegation-chain/)
15. What are SPIFFE and SPIRE? - Red Hat, accessed February 23, 2026, [https://www.redhat.com/en/topics/security/spiffe-and-spire](https://www.redhat.com/en/topics/security/spiffe-and-spire)
16. How to Set Up SPIFFE and SPIRE for Workload Identity in Kubernetes - OneUptime, accessed February 23, 2026, [https://oneuptime.com/blog/post/2026-02-09-spiffe-spire-workload-identity-kubernetes/view](https://oneuptime.com/blog/post/2026-02-09-spiffe-spire-workload-identity-kubernetes/view)
17. Beyond Identity's Investment in Identity Standards: IPSIE, accessed February 23, 2026, [https://www.beyondidentity.com/resource/beyond-identitys-investment-in-identity-standards-ipsie](https://www.beyondidentity.com/resource/beyond-identitys-investment-in-identity-standards-ipsie)
18. agent-discovery-exchange/draft-agent-discovery-00.md at main - GitHub, accessed February 23, 2026, [https://github.com/sempfa/agent-discovery-exchange/blob/main/draft-agent-discovery-00.md](https://github.com/sempfa/agent-discovery-exchange/blob/main/draft-agent-discovery-00.md)
19. Hexa Policy Orchestrator enables you to manage all of your access policies consistently across software providers. - GitHub, accessed February 23, 2026, [https://github.com/hexa-org/policy-orchestrator](https://github.com/hexa-org/policy-orchestrator)
20. agent-discovery-exchange/draft-agent-discovery-01.md at main - GitHub, accessed February 23, 2026, [https://github.com/sempfa/agent-discovery-exchange/blob/main/draft-agent-discovery-01.md](https://github.com/sempfa/agent-discovery-exchange/blob/main/draft-agent-discovery-01.md)
21. Context Stewardship: What Source-by-Source Authorization Misses | Stanford Law School, accessed February 23, 2026, [https://law.stanford.edu/2026/02/11/context-stewardship-what-source-by-source-authorization-misses/](https://law.stanford.edu/2026/02/11/context-stewardship-what-source-by-source-authorization-misses/)
22. Reducing Privacy leaks in AI: Two approaches to contextual integrity ..., accessed February 23, 2026, [https://www.microsoft.com/en-us/research/blog/reducing-privacy-leaks-in-ai-two-approaches-to-contextual-integrity/](https://www.microsoft.com/en-us/research/blog/reducing-privacy-leaks-in-ai-two-approaches-to-contextual-integrity/)
23. NuralNexus/NeuralBlitz · Datasets at Hugging Face, accessed February 23, 2026, [https://huggingface.co/datasets/NuralNexus/NeuralBlitz](https://huggingface.co/datasets/NuralNexus/NeuralBlitz)
24. AgentLeak: A Full-Stack Benchmark for Privacy Leakage in Multi-Agent LLM Systems - arXiv, accessed February 23, 2026, [https://arxiv.org/html/2602.11510v1](https://arxiv.org/html/2602.11510v1)
25. Inworld AI Business Breakdown & Founding Story - Contrary Research, accessed February 23, 2026, [https://research.contrary.com/company/inworld-ai](https://research.contrary.com/company/inworld-ai)
26. Multi-Tenant Isolation Challenges in Enterprise LLM Agent Platforms - ResearchGate, accessed February 23, 2026, [https://www.researchgate.net/publication/399564099_Multi-Tenant_Isolation_Challenges_in_Enterprise_LLM_Agent_Platforms](https://www.researchgate.net/publication/399564099_Multi-Tenant_Isolation_Challenges_in_Enterprise_LLM_Agent_Platforms)
27. Membranes of Truth: Using Markov Interfaces to Purify the Wikipedia Graph - ResearchGate, accessed February 23, 2026, [https://www.researchgate.net/publication/397273469_Membranes_of_Truth_Using_Markov_Interfaces_to_Purify_the_Wikipedia_Graph](https://www.researchgate.net/publication/397273469_Membranes_of_Truth_Using_Markov_Interfaces_to_Purify_the_Wikipedia_Graph)
28. Agent Governance at Scale: Policy-as-Code Approaches in Action, accessed February 23, 2026, [https://www.nexastack.ai/blog/agent-governance-at-scale](https://www.nexastack.ai/blog/agent-governance-at-scale)
29. OPA vs Cedar (Amazon Verified Permissions) - Styra, accessed February 23, 2026, [https://www.styra.com/knowledge-center/opa-vs-cedar-aws-verified-permissions/](https://www.styra.com/knowledge-center/opa-vs-cedar-aws-verified-permissions/)
30. Searching for Privacy Risks in LLM Agents via Simulation - arXiv, accessed February 23, 2026, [https://arxiv.org/html/2508.10880v2](https://arxiv.org/html/2508.10880v2)
