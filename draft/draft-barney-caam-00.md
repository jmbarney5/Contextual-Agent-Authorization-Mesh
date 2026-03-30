---
title: "Contextual Agent Authorization Mesh (CAAM)"
abbrev: "CAAM"
docname: draft-barney-caam-00
date: 2026-02-24
category: info
ipr: trust200902
area: Security
workgroup: TBD
keyword:
  - authorization
  - agents
  - context
  - delegation
  - attestation
stand_alone: yes
pi:
  toc: yes
  sortrefs: yes
  symrefs: yes
  compact: yes

author:
  -
    ins: J. M. Barney
    name: Jonathan M. Barney
    organization: Independent
    street: ""
    city: ""
    region: ""
    code: ""
    country: US
    email: jonathan.barney@gmail.com
    uri: https://github.com/jmbarney5/Contextual-Agent-Authorization-Mesh
  -
    ins: R. Pioli
    name: Roberto Pioli
    organization: Independent
    street: ""
    city: ""
    region: ""
    code: ""
    country: IT
    email: roberto.pioli@gmail.com
    uri: https://github.com/roberto-pioli/agent-registration-discovery
  -
    ins: D. Watson
    name: Darron Watson
    organization: Independent
    street: ""
    city: ""
    region: ""
    code: ""
    country: US
    email: drwatson0874@gmail.com
  -
    ins: Y. Porla
    name: Yogi Porla
    organization: Google
    street: ""
    city: ""
    region: ""
    code: ""
    country: US
    email: yogiporla@google.com
  -
    ins: B. Woodward
    name: Brad Woodward
    organization: Google
    street: ""
    city: ""
    region: ""
    code: ""
    country: US
    email: woodwardb@google.com

normative:
  RFC2119:
  RFC7515:
  RFC7519:
  RFC8174:
  RFC8392:
  RFC8693:
  RFC9334:
  RFC9449:
  I-D.pioli-agent-discovery:
    title: "Agent Registration and Discovery Protocol (ARDP)"
    author:
      - ins: R. Pioli
        name: Roberto Pioli
    date: 2026
    target: https://datatracker.ietf.org/doc/draft-pioli-agent-discovery/

informative:
  RFC6749:
  RFC8126:
  RFC9635:
  I-D.usama-seat-intra-vs-post:
    title: "Pre-, Intra- and Post-handshake Attestation"
    author:
      - ins: M. U. Sardar
        name: Muhammad Usama Sardar
    date: 2026
    target: https://datatracker.ietf.org/doc/draft-usama-seat-intra-vs-post/
  SPIFFE:
    title: "Secure Production Identity Framework for Everyone"
    target: https://spiffe.io/
  IPSIE:
    title: "Interoperability Profiling for Secure Identity in the Enterprise"
    author:
      - org: OpenID Foundation
    target: https://openid.net/wg/ipsie/
  HEXA:
    title: "Hexa Policy Orchestrator"
    target: https://github.com/hexa-org/policy-orchestrator
  ZANZIBAR:
    title: "Zanzibar: Google's Consistent, Global Authorization System"
    author:
      - ins: R. Pang
      - ins: R. Lanber
    seriesinfo:
      USENIX: "ATC 2019"
    date: 2019
  OPA:
    title: "Open Policy Agent"
    target: https://www.openpolicyagent.org/
  CEDAR:
    title: "Cedar Policy Language"
    author:
      - org: Amazon Web Services
    target: https://www.cedarpolicy.com/

--- abstract

This document specifies the Contextual Agent
Authorization Mesh (CAAM), an authorization profile composable with
the Agent Registration and Discovery Protocol (ARDP)
and other discovery mechanisms.  CAAM defines the
Post-Discovery Authorization Handshake: an application-layer
post-handshake attestation protocol that governs agent
behavior after an agent has been discovered but before
it is permitted to execute tool calls or delegate
authority.

CAAM provides a sidecar-based authorization mediator
for enforcing Relationship-Based Access Control
(ReBAC), purpose-bound delegation, and
cryptographically verifiable intent propagation in
Human-to-Agent (H2A) and Agent-to-Agent (A2A) flows.
It bridges identity provenance frameworks -- such as the
Interoperability Profiling for Secure Identity in the
Enterprise (IPSIE) -- with discovery control planes,
leveraging OpenID XAA for coarse-grained delegation, a
Knowledge Graph for real-time relationship inference,
and the Provenance-Attenuated Chain Token (PACT) architecture
for tamper-proof, multi-hop intent delegation without the
heavy infrastructure overhead of ubiquitous identity agents.

The Session Context Object (SCO) defined herein serves as
the genesis block of the PACT chain, encoded as a JSON Web
Token (JWT) or a CBOR Web Token (CWT), and carries a new
"ctx" (Contextual Assertion) claim that binds the agent's
delegated authority to a specific purpose, session, and
ephemeral trust chain.

--- middle

# Introduction

The evolution of enterprise infrastructure toward
autonomous and semi-autonomous agentic systems has
introduced a fundamental gap in identity and access
management.  Traditional security architectures,
designed for static workloads and direct
human-to-service interactions, are insufficient for
managing the non-deterministic, ephemeral, and
multi-hop nature of Large Language Model (LLM)
agents.

Current security models address identity at two
distinct layers: the human user (via OpenID Connect
and IPSIE IPSIE) and the machine workload (via
cloud identities or lightweight attestation frameworks).  Autonomous agents occupy a
hybrid space -- a software workload that possesses
its own identity but operates with the delegated
authority of a human user or another agent.  This
hybridity creates a gap where traditional Role-Based
Access Control (RBAC) fails to account for the
ephemeral and purpose-driven nature of agentic
tasks.

| Security Dimension | Workload | Human | Agent |
|-|-|-|-|
| Identity Type | Ephemeral Key | User ID | Composite |
| Lifespan | Transactional | Session | Ephemeral |
| Decision Logic | Deterministic | Human | Probabilistic |
| Trust Anchor | Token Lineage | IdP | Discovery+Ctx |
| Authorization | Static | Role | Contextual |

As agents move from simple request-response patterns
to independent reasoning and tool invocation, the
risk of "identity dilution" and "authorization loops"
grows.  Without a dedicated mesh to manage these
interactions, organizations face a choice between
over-privileging agents -- expanding the blast radius
of potential compromises -- or restricting them to
functional uselessness.  CAAM resolves this tension
by enforcing policy at the most granular level of
the agent's internal reasoning loop via Provenance-Attenuated Chain Tokens.

## Relationship to Existing Standards

CAAM is not intended as a replacement for existing
identity, authorization, or attestation protocols.
It functions as an orchestration profile -- a
connective layer that composes outputs from multiple
mature standards into a single, coherent
authorization decision tailored to autonomous agent
ecosystems.

CAAM occupies three complementary roles:

*  GNAP Extension for Non-Deterministic Clients:
   The Grant Negotiation and Authorization Protocol
   (GNAP) RFC9635 assumes a client capable of
   participating in structured negotiation flows.
   Autonomous agents are non-deterministic clients
   whose resource requirements emerge dynamically
   during multi-step reasoning.  CAAM extends the
   GNAP model by introducing the Session Context
   Object (SCO) as a purpose-bound grant envelope
   that constrains the agent's evolving resource
   requests to the boundaries of the original
   human intent.

*  Policy Enforcement Point for RATS (when
   deployed):  The RATS architecture RFC9334
   defines the roles of Attester, Verifier, and
   Relying Party but does not prescribe where in
   an application's request path the Attestation
   Result SHOULD be consumed or how it SHOULD
   influence fine-grained authorization decisions.
   When RATS is deployed, the CAAM sidecar serves
   as a dedicated Policy Enforcement Point (PEP)
   that ingests RATS Attestation Results and
   combines them with identity provenance and data
   sensitivity signals to produce the Contextual
   Risk Score (CRS) defined in
   contextual-risk-scoring.  When RATS is not
   deployed, the CRS is computed from Provenance
   and DataSensitivity factors alone.

*  Trust Framework for Multi-Hop Delegation:
   OAuth 2.1 and Token Exchange RFC8693 provide
   mechanisms for single-hop delegation and
   impersonation.  They do not natively address the
   compound trust problem arising in N-hop agentic
   chains (User -> Agent A -> Agent B -> Agent C),
   where each intermediate agent introduces a new
   trust boundary.  CAAM provides Scope
   Attenuation, Depth-Limited Tokens, and
   Intent-Binding to ensure that delegated authority
   degrades gracefully rather than accumulating
   across hops.

## The Post-Discovery Authorization Handshake

CAAM provides the Post-Discovery Authorization
Handshake for I-D.pioli-agent-discovery.  The
ARDP control plane enables an orchestrating client
to discover an agent's endpoint, capabilities, and
network address.  However, ARDP does not prescribe
the authorization protocol that governs the agent's
behavior once a session is established.

CAAM fills this gap.  After an ARDP RESOLVE
operation returns an agent's endpoint, the CAAM
sidecar mediates a post-handshake attestation
I-D.usama-seat-intra-vs-post between the client
and the discovered agent before any tool call
is permitted.  This handshake establishes:

1. Mutual identity verification via IdP origination
   and, when available, RATS Attestation Evidence.
2. A purpose-bound Session Context Object (SCO)
   that constrains the agent's authority to the
   specific task.
3. A Sealed Provenance-Attenuated Chain Token (PACT)
   that replaces any long-lived
   credential with a short-lived, nonce-bound,
   single-use token.

Without CAAM, an ARDP-discovered agent could be
invoked with a static bearer token that carries no
purpose binding, no environmental attestation, and
no delegation-depth limit -- the failure mode
observed in real-world incidents where agents used
static bearer tokens without purpose binding.

## The Multi-Hop Intent Binding Problem

The core standardization gap that CAAM addresses is
Multi-Hop Intent Binding: the problem of proving,
at each hop in a delegation chain, that the current
agent's request remains within the semantic bounds
of the original user's intent -- without
over-privileging the entire chain.

Existing standards address adjacent concerns but
leave this problem unresolved:

*  OAuth XAA handles coarse-grained identity
   delegation across application boundaries.  It
   establishes who is delegating what scope to
   which application.  However, XAA does not track
   whether a sub-delegated agent three hops
   downstream is still operating within the purpose
   for which the original grant was issued.

*  RATS RFC9334 provides cryptographic
   assurance of the execution environment's
   integrity.  It establishes where the agent is
   running and whether that environment is
   trustworthy.  However, RATS Evidence contains no
   semantic information about the agent's current
   task or whether that task aligns with the
   original user's intent.

*  CAEP/SSE (Shared Signals and Events) enables
   reactive session-level signals (e.g., "user
   logged out," "device compromised").  These
   signals operate at the granularity of sessions
   and are propagated asynchronously.  They do not
   provide the synchronous, per-request intent
   verification required to gate individual tool
   calls within a multi-hop agentic flow.

CAAM bridges this gap by binding each request in
the delegation chain to a cryptographically signed
Intent-Signature derived from the original SCO,
verified at every hop by the CAAM sidecar using 
ephemeral keys before a Sealed PACT Token is synthesized.

### Standardization Gap Analysis

The following table identifies the authorization
dimensions relevant to autonomous agent ecosystems
and maps the coverage provided by existing standards
against the extensions introduced by CAAM.

| Dimension | OAuth/GNAP | RATS | CAEP | CAAM |
|-|-|-|-|-|
| Delegation | 1-hop | N/A | N/A | N-hop+Scope Attenuation |
| Env Trust | N/A | HW/SW | N/A | CRS input |
| Risk Signals | N/A | N/A | Async | Sync narrowing |
| Intent | Static | Env-only | None | Per-request |
| Credentials | Bearer | N/A | N/A | PACT Ephemeral |
| Inference | N/A | N/A | N/A | Firewall |
| Granularity | Grant | Attestation | Session | Request |
| Decision | Scope | Pass/fail | Event | CRS tiers |

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED",
"SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted
as described in BCP 14 RFC2119 RFC8174 when,
and only when, they appear in all capitals, as
shown here.

Contextual Mesh:
: A decentralized, sidecar-based authorization
  layer that enforces purpose-bound and
  context-aware access controls across a network
  of autonomous agents.

Agent Principal:
: The composite identity of an agent,
  incorporating its ephemeral workload
  identity (PACT block) and its delegated human
  user context (IPSIE claims).

Inference Boundary:
: A documented and machine-enforceable
  specification that defines the permissible and
  prohibited conclusions an agent MAY draw from
  the combination of authorized data sources.

Session Context Object (SCO):
: A cryptographically signed, transient data
  structure encoded as a JWT RFC7519 or CWT
  RFC8392 that encapsulates the intent,
  purpose, and provenance of an agentic
  interaction.

Tool-Call Interception:
: The process by which an authorization sidecar
  monitors and regulates the outbound network/API
  request calls made by an agent.
  steps of an LLM agent to prevent policy
  violations.

Narrowed Persona:
: The reduced capability set advertised by an
  agent after the Resolver applies contextual
  filtering based on participant relationships.

Sealed PACT Token:
: The final state of a Provenance-Attenuated Chain
  Token after the executing agent appends a terminal
  block (containing no next public key) and signs it.
  The sealed token is an immutable, cryptographically
  locked bearer credential scoped to a single tool
  call execution.

Contextual Risk Score (CRS):
: A real-valued score S in the range \[0, 1\]
  assigned to every request within the mesh,
  encoding the combined risk of provenance,
  environment trust, and data sensitivity.

Intent-Signature:
: A cryptographic binding between the original
  user's purpose (as encoded in the SCO) and each
  subsequent request in a delegation chain,
  implemented as a Chained JWS RFC7515.

# Protocol Overview

## Architectural Foundations

CAAM leverages the existing maturity of identity
provenance standards while extending them to meet
agentic requirements.

### Lightweight Ephemeral Identity and Provenance-Attenuated Chains

Traditional nested-token models and strict identity frameworks
(e.g., deploying identity agents on every node) impose a heavy
infrastructure burden and struggle with cross-organizational
boundaries. CAAM replaces the necessity of ubiquitous workload
identity agents with the Provenance-Attenuated Chain Token (PACT)
architecture.

In the PACT model, only the root Identity Provider (IdP) is
required to maintain heavy Public Key Infrastructure (PKI).
The IdP mints the Genesis Block (Block 0) of the intent token,
which includes the original user's intent and an ephemeral
Public Key (PK_1). The user passes Block 0 and the corresponding
ephemeral Private Key (SK_1) to the first agent. This model
secures the chain without requiring a continuous identity framework
for every intermediary agent, enabling lightweight, cross-boundary
federation.

### IPSIE as the Human Provenance Layer

While SPIFFE identifies the workload, the IPSIE
profiles IPSIE identify the delegating human.
When a human user initiates a task requiring agent
assistance, their IPSIE-compliant identity token
serves as the original source of authority.  CAAM
uses this provenance to bind the agent's workload
identity to the human's session identity, creating
a composite principal.

### ARDP and the Discovery-Authorization Nexus

The Agent Registration and Discovery Protocol
(ARDP) I-D.pioli-agent-discovery establishes a
control plane for agents to advertise capabilities
and network endpoints.  CAAM extends ARDP by
introducing "AuthZ-at-Discovery," where the
security capabilities and policy compliance of an
agent are verified before a session is established.

Implementations that support CAAM MUST advertise
the following metadata in the ARDP registry:
Inference Boundary hash and policy manifest URI.
If the deployment uses RATS, the agent SHOULD
additionally advertise supported RATS Evidence
types.  If the deployment uses SPIFFE for
workload identity at the root, the agent MAY
additionally advertise its SPIFFE trust domain.

### RFC 9334 (RATS) Alignment

The CAAM Mesh MAY adopt the RATS architecture
RFC9334 as a defense-in-depth layer alongside
the Provenance-Attenuated Chain Token (PACT).

While PACT provides cryptographic assurance of
intent integrity and scope attenuation across
multi-hop chains, RATS addresses a complementary
concern: the trustworthiness of the physical
execution environment.  PACT cannot detect a
compromised host that executes the attenuated
tool call correctly while simultaneously
exfiltrating the returned data, or a tampered
agent binary that crafts tool calls that are
technically within scope but serve an attacker's
purpose.  RATS Evidence addresses these residual
risks.

RATS integration is tiered by deployment
sensitivity:

*  Minimum Viable Deployments: RATS is OPTIONAL.
   PACT alone provides intent integrity, scope
   attenuation, and tamper resistance.  The CRS
   EnvTrust factor (E) defaults to a neutral
   value when no RATS Evidence is available.

*  Enterprise Standard Deployments: RATS is
   RECOMMENDED.  Agents SHOULD be capable of
   producing RATS Evidence to enable the full
   CRS calculation and detect environmental
   compromise.

*  Regulated / Critical Deployments: RATS is
   REQUIRED.  Agents in environments subject to
   regulatory mandates (financial services,
   healthcare, government) or operating at
   Critical CRS tier (S >= 0.7) MUST produce
   RATS Evidence.

When RATS is deployed, the following roles apply:

*  Attester: The Agent or Sub-Agent providing
   Evidence.  Evidence SHOULD include runtime
   state, TPM 2.0 platform quotes, and signed
   container image digests.

*  Verifier: The component that processes Evidence
   against Endorsements and produces an Attestation
   Result encoding the trustworthiness of the
   agent's current execution environment.  To
   prevent the Self-Attestation Paradox (where a
   compromised host forges its own attestation),
   the Verifier MUST satisfy at least one of the
   following isolation requirements: (a) the
   Verifier runs as a remote, centralized mesh
   service logically separate from the agent host,
   or (b) the Verifier executes within a
   hardware-rooted Trusted Execution Environment
   (TEE) on the same host, ensuring the host OS
   cannot tamper with the verification logic.  A
   sidecar acting as Verifier on the same host
   without TEE isolation MUST NOT be considered
   sufficient for Critical CRS tier assurance
   (S >= 0.7).

*  Relying Party: The Resource Server that
   consumes the Attestation Result to authorize
   the tool call.  The Relying Party MUST NOT
   process raw Evidence; it relies on the
   Verifier's signed Attestation Result.

## The CAAM Sidecar Model

The CAAM sidecar is the core enforcement
mechanism.  It is a lightweight proxy that runs
alongside the agent workload, intercepting all
internal and external communications.

### Intercepting the Outbound Tool Calls

The tool-call loop is the
fundamental interaction cycle of an autonomous agent:

1. Thought: The LLM generates a plan or tool
   call.
2. Action: The agent executes the tool call.
3. Observation: The agent receives results and
   reasons further.

The CAAM sidecar MUST intercept this loop at the
transition between Thought and Action.  By acting
as a semantic gateway, the sidecar analyzes the
intent of the tool call before it reaches the
network.

### Impersonation vs. Delegation

CAAM utilizes Token Exchange RFC8693 to manage
relationships in multi-hop chains.  It
distinguishes between Impersonation (agent acts as
the user) and Delegation (agent acts on behalf of
the user while maintaining its own identity).

In the CAAM delegation model, the resulting access
token MUST include an `act` (actor) claim that
captures the entire lineage:

| Step | Token Components | Identity State |
|-|-|-|
| User starts | IPSIE Token | sub: User |
| A calls B | A Block + Token | sub: User, act: A |
| B calls RS | B Block + Prev | act: B { act: A } |

To maintain least privilege, CAAM mandates Scope
Attenuation: each subsequent token in the chain
MUST have an equal or smaller scope than its
predecessor.  Implementations MUST NOT permit scope
expansion during delegation.

### The Provenance-Attenuated Chain Token (PACT) Pattern

While traditional models rely on continuous Identity Provider (IdP) or SPIRE attestation at every hop, CAAM introduces the Provenance-Attenuated Chain Token (PACT) pattern to establish cryptographically verifiable, multi-hop chains without the infrastructure burden of continuous centralized PKI:

1. Genesis Block: The root IdP mints the Session Context Object (SCO) as the Genesis Block (Block 0). Crucially, the IdP embeds an ephemeral Public Key (PK_1) within this block and signs it. The User passes Block 0 and the corresponding ephemeral Private Key (SK_1) to the first agent.
2. Ephemeral Handover: At each delegation hop, the agent receives the token and the ephemeral private key. If the agent attenuates the intent, it generates a new ephemeral keypair (PK_N+1, SK_N+1), creates a new block containing only the delta (the attenuation) and PK_N+1, signs this new block with the received SK_N, and passes the extended token and SK_N+1 forward.
3. Token Sealing: The final agent in the chain creates a final block with no new public key, signaling the end of the chain, and applies its signature. The sealed token acts as an immutable record of intent and attenuation.

An agent determines that it is the final agent (and therefore seals the token rather than performing an Ephemeral Handover) based on the nature of its outbound action.  If the agent's sidecar detects that the outbound request targets a Resource Server (API endpoint) rather than another CAAM-compliant agent, it MUST seal the PACT token before transmitting the request.  Additionally, if the "max_hops" counter in the SCO has reached 0, the agent MUST seal the token regardless of the target, as further delegation is prohibited.

This pattern fundamentally solves the "unwrapping" vulnerability seen in standard nested tokens. Because each block explicitly contains the public key of the subsequent block, an intermediate agent cannot remove a block from the chain without invalidating the cryptographic signature of the subsequent hop. Furthermore, because intermediaries generate keys ephemerally, they do not need to be mutually identified across organizational boundaries, solving cross-boundary federation naturally.

## The Session Context Object (SCO) {#sco-definition}

The Session Context Object (SCO) serves as the Genesis Block of the PACT chain. It MUST be
encoded as a JWT RFC7519 for HTTP-based
transports or as a CWT RFC8392 for constrained
environments.

### The "ctx" Claim

This document defines a new JWT/CWT claim:

ctx (Contextual Assertion):
: A JSON object (or equivalent CBOR map) that
  carries the contextual metadata required for
  CAAM authorization decisions.  The "ctx" claim
  is registered per iana-considerations.

The "ctx" claim MUST contain the following members:

*  "purpose": A string describing the
   human-readable intent of the agentic task.
   This value is set at origination and MUST NOT
   be modified by intermediate agents.

*  "scope_ceiling": An array of OAuth scope
   strings representing the maximum authority
   derived from the original delegation.

*  "max_hops": An integer indicating the remaining
   delegation depth.  This value MUST be
   decremented by 1 at each delegation hop.  When
   "max_hops" reaches 0, further delegation MUST
   be denied.

*  "next_pk": The ephemeral public key (e.g., ECDSA)
   used to validate the signature of the subsequent block.

*  "crs": The current Contextual Risk Score, a
   decimal value in the range \[0, 1\].

The SCO MUST be signed by the originating Identity
Provider at creation.

The following is a non-normative example of an SCO
JWT payload:

~~~json
{
  "iss": "https://idp.corp.internal",
  "sub": "user:jonathan@corp.com",
  "iat": 1740355200,
  "exp": 1740358800,
  "ctx": {
    "purpose": "Q4 revenue audit",
    "scope_ceiling": [
      "finance:read",
      "crm:read"
    ],
    "max_hops": 3,
    "next_pk": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgA...",
    "crs": 0.22
  }
}
~~~

### Intersection of Permissions

To prevent lateral movement, PACT enforces the Intersection of Permissions. An agent within the chain can ONLY down-scope (attenuate) a token; it can never up-scope it. The final execution context is the strict mathematical intersection of all constraints applied in the chain. Even if a middle agent is compromised, it only possesses the ephemeral private key for that specific transaction and cannot generate a new intent or escalate privileges beyond what the Genesis Block authorized.

## Policy Substrate: Knowledge Graphs and ReBAC

To avoid manual policy sprawl, CAAM mandates a
Policy Inference Plane that treats the enterprise
Knowledge Graph as the source of truth for
relationship-based access decisions.

### Relationship Ingestion

The mesh MUST ingest relationship triples from
existing IAM data (via SCIM) and real-time
collaboration signals.  These relationships form
the edges of the Knowledge Graph and MUST be
updated continuously.

### Common Ancestor Constraint

For multi-participant sessions, the Resolver MUST
satisfy the Common Ancestor Constraint: all
participants in a session MUST share a relationship
path through the Knowledge Graph to the data silo
being accessed.  If any participant lacks this
path, the agent's capability set MUST be narrowed
accordingly.

### Zanzibar Model

Implementation of the Zanzibar model ZANZIBAR
(e.g., SpiceDB) is RECOMMENDED.  This allows the
N-way intersection check to be performed using
consistency tokens (e.g., Zanzibar-style
'zookies') to ensure causal consistency during
policy evaluation.

## Protocol Integration

CAAM operates as a secondary control plane between
the ARDP discovery layer
I-D.pioli-agent-discovery and the execution
protocol (e.g., MCP, HTTP, or gRPC).

### OpenID XAA Binding

The initial delegation between the Human and the
Agent occurs via OpenID XAA:

*  The User grants the agent a scope (e.g.,
   "client_data:read").
*  This XAA grant is treated as a root node in
   the Knowledge Graph, providing the agent the
   potential to access data.  The potential is
   narrowed by real-time context.
*  The raw XAA token MUST be stored in the CAAM
   Vault and MUST NOT be exposed to the agent
   directly.

### OpenID IPSIE Binding and Shared Signals

CAAM utilizes IPSIE IPSIE to manage the
Agentic Session:

*  The session_id in the ARDP RESOLVE call MUST
   map to an IPSIE session identifier.
*  The Resolver MUST act as a Shared Signals
   Framework (SSF) receiver.  If an SSF event
   indicates a change in session risk or
   participant list, the Resolver MUST immediately
   narrow any agent capabilities that no longer
   satisfy the Knowledge Graph intersection.

### Post-Discovery CAAM Handshake

After a client successfully discovers an agent via the
ARDP RESOLVE method, it initiates a separate, subsequent
handshake to establish the cryptographic context required
for contextual authorization.  This is performed via an
HTTP POST to the discovered agent's `/caam/authorize`
endpoint:

~~~json
{
  "method": "POST",
  "endpoint": "/caam/authorize",
  "aid": "agent:finance-bot@corp.internal",
  "context": {
    "session_id": "ipsie-session-2026-v1",
    "xaa_ref": "vault:opaque-ref-001",
    "participants": [
      {
        "format": "email",
        "email": "jonathan@corp.com"
      },
      {
        "format": "email",
        "email": "guest@client2.com"
      }
    ],
    "consistency_token": "zk_v1_998877",
    "rats_evidence": {
      "attester_id":
        "agent:finance-bot@corp.internal",
      "evidence_type": "tpm2.0",
      "manifest_hash": "sha256:ab12cd34"
    }
  }
}
~~~

### Capability Fuzzing (Narrowed Persona)

Upon RESOLVE, the Resolver performs contextual
capability filtering in two phases:

Discovery-Time Narrowing:

1. Execute a Knowledge Graph traversal to
   determine whether all participants share a
   relationship with the target data silos.
2. If a participant lacks access to a data silo,
   the Resolver MUST remove tools associated with
   that silo from the agent's capability
   advertisement.
3. The agent is discovered with a Narrowed
   Persona.

Session-Time Enforcement:

4. The sidecar MUST enforce the same filtering on
   every tool call via outbound request interception.
5. If an SSF event changes the participant list
   mid-session, the sidecar MUST re-execute the
   Knowledge Graph intersection and further
   narrow (MUST NOT expand) the agent's
   capabilities.

### Protocol Phases

The CAAM protocol proceeds through four phases:

1. Discovery Phase: The client searches for an
   agent via ARDP.  The Resolver returns the
   agent's endpoint along with its CAAM
   Capability Block (supported policy
   languages, Inference Boundary hash).

2. Negotiation Phase: The client and the agent's
   sidecar perform mutual attestation.  The
   client provides its identity proof and the
   SCO.  The sidecar verifies the SCO against
   IPSIE risk signals and, when available,
   RATS Evidence.

3. Establishment Phase: Upon successful
   negotiation, a Contextual Session is
   established.  The sidecar validates the 
   PACT token.

4. Enforcement Phase: The sidecar intercepts the
   tool call and performs real-time validation of
   every tool call against the PACT, Inference
   Boundary, and CRS threshold.

## Contextual Risk Scoring (CRS) {#contextual-risk-scoring}

Every request within the mesh MUST be assigned a
Contextual Risk Score (CRS), S in the range
\[0, 1\], calculated by the Verifier (or by the
sidecar when no dedicated Verifier is deployed).

~~~
  S = w_1 * P + w_2 * E + w_3 * D
~~~

Where P is Provenance, E is EnvTrust, D is
DataSensitivity, w_1 + w_2 + w_3 = 1, and weights
are configurable per deployment.  The factors are:

*  Provenance: The strength and freshness of the
   identity chain, hop count from the original
   user, PACT cryptographic integrity, and SCO integrity.
*  EnvTrust: Trustworthiness of the execution
   environment per RATS Attestation Evidence --
   TPM status, manifest integrity, geographic
   compliance.  When RATS Evidence is not
   available (Minimum Viable deployments), E
   SHOULD default to 0.5 (neutral).  Deployments
   MAY configure a higher default to reflect
   elevated risk for unattested environments.
*  DataSensitivity: Classification of the target
   resource (public, internal, confidential,
   regulated PII).

Remediation Tiers:

| CRS Range | Level | Action |
|-|-|-|
| S < 0.3 | Nominal | Sealed PACT execution |
| 0.3 <= S < 0.7 | Elevated | Step-Up (MFA) REQUIRED |
| S >= 0.7 | Critical | HITL REQUIRED |

The CRS MUST be recalculated on every tool call.
A spike in CRS mid-session (e.g., from an SSF risk
event) MUST trigger immediate re-evaluation and
potential session downgrade.

## Policy Orchestration

CAAM translates high-level intent into
machine-enforceable policies via HEXA HEXA and
IDQL:

1. Intent Capture: An administrator defines
   intent in IDQL.
2. Translation: The HEXA orchestrator translates
   IDQL to target-specific format (Rego for OPA
   OPA, Cedar CEDAR).
3. Distribution: Policy bundles are pushed to
   sidecars.
4. Enforcement: The sidecar evaluates tool calls
   against bundles, using SCO metadata for
   context.

Implementations MAY support both OPA and Cedar
simultaneously.

# Security Considerations

This section analyzes the threat landscape
specific to autonomous agent ecosystems and
describes how CAAM mitigates each identified
threat.  The analysis follows a defense-in-depth
model where multiple independent controls
reinforce each other.

## Token Unwrapping and Tampering {#token-unwrapping}

Traditional nested tokens are vulnerable to "unwrapping" attacks, where a malicious downstream agent strips the outer layers of a token to remove constraints applied by intermediate agents.

CAAM mitigates this through the Provenance-Attenuated Chain Token (PACT) architecture. Because the Genesis Block includes an ephemeral public key (`PK_1`), and Block 1 is signed by the corresponding private key (`SK_1`) while embedding `PK_2`, removing any intermediate block mathematically breaks the signature chain. An attacker cannot unwrap a block and pretend it was never there, guaranteeing absolute tamper resistance.

## Lateral Movement and Privilege Escalation {#lateral-movement}

If an agent is compromised in a traditional network-centric model, the attacker inherits the workload's identity and can pivot laterally to any API that agent can reach. 

CAAM neutralizes lateral movement through the Intersection of Permissions.
* An agent can only down-scope (attenuate) a token; it can never up-scope it.
* A compromised intermediary agent only possesses the ephemeral private key for a *specific transaction*.
* It cannot generate a new Genesis Block, cannot alter previous blocks, and cannot use its ephemeral key to access APIs outside the strictly bound intent of the token. The blast radius is limited mathematically to the exact constraints of the active token.

## Context Spoofing {#context-spoofing}

Context spoofing occurs when an agent or its
operator falsifies environmental signals to
obtain a more permissive authorization decision.

CAAM mitigates context spoofing through the
following requirements:

*  Self-Asserted Context Prohibition: The CAAM
   Verifier MUST NOT accept self-asserted
   context claims from the agent.  When RATS is
   deployed, environmental context (location,
   network posture, platform integrity) MUST be
   derived from independently verifiable sources:
   RATS Attestation Evidence RFC9334 from a
   hardware-rooted Attester, or corroborating
   signals from the SSF receiver.  In Minimum
   Viable deployments without RATS, the CRS
   EnvTrust factor defaults to neutral and
   context-dependent authorization decisions
   SHOULD require Step-Up verification.

*  Coarse-Grained Context Defaults: To reduce
   the attack surface for context spoofing,
   context signals MUST be expressed at the
   coarsest granularity sufficient for the
   authorization decision.

## Cross-Boundary Federation Vulnerabilities {#cross-boundary}

Traditional models (like SPIFFE) require identity agents on every node and struggle with cross-organizational federation, demanding that interacting agents explicitly identify each other's "audience". 

By using PACT, intermediaries can remain anonymous and use ephemeral keys. This naturally solves cross-boundary federation because the end-consumer only needs to verify the original IdP's intent and the integrity of the ephemeral chain, without needing to maintain complex trust federations or internal topology maps of external organizations.

## Prompt Injection as Privilege Escalation

Prompt injection attacks are a primary threat to
autonomous systems.  CAAM treats prompt injection
as a Semantic Elevation of Privilege attack.  The
CAAM sidecar MUST remain isolated from the
agent's reasoning space (Out-of-Band Policy
Enforcement).

Even if an agent's internal state is compromised
via prompt injection and it attempts an
unauthorized action, the sidecar intercepts the
resulting tool call.  Because the sidecar's
decision logic is deterministic and based on the
immutable PACT intent chain, it MUST block the action
regardless of the agent's internal belief state.

## Multi-Hop Identity Dilution

In an N-hop chain (User -> Agent A -> Agent B ->
Agent C), each hop introduces a new trust
boundary.  Traditional OAuth 2.0 tokens allow an
agent at the end of the chain to inherit the
full permissions of the original user without
explicit intent.

CAAM mitigates this through PACT's strict Scope Attenuation. The sidecar MUST verify that
each sub-task was authorized in the original
SCO, and subsequent blocks can only attenuate the intent. Authority MUST
degrade gracefully across hops rather than
accumulating.

## The Confused Deputy Prevention {#confused-deputy}

The Confused Deputy attack in agentic systems
occurs when a malicious or compromised Agent A
passes a crafted intent to a higher-privileged
Agent B, tricking B into performing an action
that A is not authorized to request.

CAAM prevents this attack through the cryptographic coupling of the PACT chain:

*  Intent Binding: The sealed token carries the intersection of all "purpose" constraints.
   Agent B's sidecar MUST verify that the
   requested action falls within the stated
   purpose before executing.  A crafted intent
   from Agent A that requests an out-of-scope
   action will fail this check even if Agent B
   has the technical capability to perform it.

*  Environment Binding (when RATS is deployed):
   The PACT token MAY embed a hash of the RATS
   Attestation Result that was current at
   synthesis time.  If present and an attacker
   replays the token from a different
   environment, the Relying Party's Attestation
   Result will not match the embedded hash, and
   the token MUST be rejected.  In deployments
   without RATS, this binding is not available
   and the remaining four bindings provide the
   primary defense.

*  Session Binding: The PACT token includes the
   SCO's "jti" (JWT ID) and "session_id".  A
   token synthesized for Session X MUST NOT be
   accepted in Session Y.  The sidecar MUST
   validate that the presented token's session
   binding matches the active Contextual
   Session.

*  Nonce Binding: Each PACT token is bound to a
   single-use cryptographic nonce.  After the
   first use, the nonce is recorded in a replay
   cache.  Any subsequent presentation of the
   same nonce MUST be rejected.

*  Sender Binding: When the final executing agent
   seals the PACT token (by appending a terminal
   block with no next public key), the sealed token
   MUST embed a "cnf"/"jkt" claim containing the
   JWK Thumbprint of the final agent's DPoP key.
   The Resource Server verifies the DPoP proof
   against this specific key.  Even if an
   intermediary agent intercepts the sealed token,
   it cannot produce a valid DPoP proof because it
   does not possess the final agent's private key.

These five bindings are conjunctive: all MUST
hold for an PACT token to be accepted.  The
failure of any single binding invalidates the
token.

## Relay Attacks and Post-Handshake Attestation

Recent formal analysis has demonstrated that
intra-handshake attestation mechanisms are often
vulnerable to relay attacks due to a failure to
cryptographically bind the attestation evidence
to the application-layer traffic secrets or the
specific request intent I-D.usama-seat-intra-vs-post.

CAAM mitigates these relay attacks by adopting
a post-handshake attestation architecture.
Because the attestation verification and
subsequent authorization decisions occur at the
application layer, over an already established
secure channel, CAAM can natively enforce the
five-way Contextual Binding described above
(including DPoP sender-binding and single-use
nonces). This application-layer approach ensures
that the PACT token synthesized by the mesh is
bound not just to the TLS connection, but to
the specific semantic intent of the multi-hop
agentic request, precluding relay and diversion
attacks.

## Sybil Chain and Phantom Hop Attacks {#sybil-chain}

Because PACT intermediaries can participate anonymously
using ephemeral keys (a feature that enables
cross-boundary federation), the chain does not
inherently prove the physical topology or distinct
identity of intermediate agents.

A malicious Agent A could generate multiple ephemeral
keypairs in memory and append fabricated blocks to the
chain, simulating the participation of phantom agents
that do not exist.  The Relying Party would
successfully validate the mathematical integrity of
the ephemeral key chain but would have no assurance
that distinct agents produced each block.

CAAM acknowledges this as a fundamental trade-off of
the PACT design:

*  Intent Attenuation is Guaranteed: Even in a Sybil
   Chain, the Intersection of Permissions holds.  A
   phantom block can only attenuate (down-scope) the
   token; it cannot expand it.  The blast radius of
   the attack is therefore bounded by the Genesis
   Block's original intent.

*  Proper Channels Require Identified Blocks: If a
   deployment requires proof that a specific
   intermediary (e.g., an auditor agent or compliance
   gateway) participated in the chain, that
   intermediary MUST bind its ephemeral block to a
   verifiable long-lived identity (e.g., by
   co-signing its block with a corporate-issued
   certificate or SPIFFE SVID).  The Relying Party
   can then enforce a "Proper Channels" policy that
   requires identified blocks at specific positions
   in the chain.

*  Hop Count Integrity: The "max_hops" counter in the
   SCO limits the total number of blocks regardless
   of whether they are authentic or fabricated.

Deployments that do not require Proper Channels
enforcement (e.g., cross-boundary fire-and-forget
flows) MAY accept fully anonymous chains and rely
solely on intent attenuation for security.

## Data-in-Use Protection (Future Work) {#data-in-use-protection}

While CAAM provides robust controls for data-at-rest
and data-in-transit via access policies, the next
frontier is protecting data-in-use during processing
by the agent's LLM or inference engine.

As technology matures, agent workloads MAY be
executed within Confidential Computing environments
(e.g., secure enclaves such as Intel SGX or AMD SEV).
Executing the agent within a Trusted Execution
Environment (TEE) protects the "Observation" and
reasoning phases from inspection or tampering by a
compromised host OS or hypervisor. This provides
cryptographic assurance against active data leakage
and some forms of prompt injection at the execution
layer itself.

Because deploying large, GPU-accelerated LLM
workloads within secure enclaves is currently
technically difficult, this is identified as an
optional, future capability rather than a strict
requirement for `-00` implementations.

## Policy and Knowledge Graph Integrity {#policy-integrity}

The security of the CAAM mesh relies entirely on the
correctness of the authorization policy (e.g., OPA
or Cedar) and the accuracy of the Knowledge Graph.
Implementations MUST adopt a Zero Trust approach to
policy lifecycle management.

This approach SHOULD include:

*  Signed Policy Bundles: All policy updates MUST be
   cryptographically signed and verified by the
   sidecar before enforcement.
*  Verifiable Audit Trails: All mutations to the
   Knowledge Graph MUST be appended to a tamper-
   evident log.
*  Policy-as-Code Pipelines: Changes to the ruleset
   MUST pass through automated CI/CD pipelines with
   mandatory security reviews and conflict-detection
   tests to prevent the introduction of overly
   permissive rules.

## Agent Supply Chain Security {#supply-chain-security}

While RATS secures the agent's runtime environment,
a comprehensive Zero Trust model MUST also scrutinize
the agent's software provenance.

The CAAM framework SHOULD be extended to verify the
software supply chain of discovered agents. Before
initiating the Post-Discovery Handshake, the sidecar
MAY require the agent (or the ARDP Registrar) to
provide a signed Software Bill of Materials (SBOM).
The sidecar can then verify that the agent's
components, including the specific LLM model weights
and inference dependencies, contain no known
critical vulnerabilities before allowing execution.

## Threat Analysis {#threat-model}

The following threats are specific to multi-agent
orchestration.  For each threat, the table
identifies the attack vector, the primary CAAM
mitigation, and the relevant section of this
document.

| Threat | Vector | Mitigation | Ref |
|-|-|-|-|
| Token Theft | Runtime exfil | DPoP+Vault+60s | token-theft |
| Context Spoof | Fake env | RATS+coarse ctx | context-spoofing |
| Confused Deputy | Intent A->B | 5-way binding | confused-deputy |
| Signal Spoof | Fake TEE/geo | TPM Evidence | context-spoofing |
| Deleg Loop | Circular chain | max_hops+cycle | sco-definition |
| Token Replay | Captured PACT | Nonce+DPoP | dpop-binding |
| Infer Bypass | Cross-source | Firewall+DP | minimal-disclosure |
| Prompt Inject | Manipulated LLM | OOB enforce | N/A |
| Sybil Chain | Phantom hops | Attenuation+ID | sybil-chain |
| Data-in-Use Exfil | Host OS/Hyper | TEE (Future/Opt) | data-in-use-protection |
| Policy Tampering | Malicious Rules | Signed Bundles | policy-integrity |
| Vulnerable Agent | Compromised Dep | Signed SBOM | supply-chain-security |

# Privacy Considerations

## Inference Isolation

A unique challenge in agentic security is Fuzzy
Search Leakage: an agent with authorized access
to multiple datasets may combine them in its
internal memory to draw unauthorized inferences.

CAAM implements a Contextual Firewall that
enforces isolation within the agent's reasoning
context.  If an agent retrieves data from
Source A, the sidecar MUST restrict access to
Source B for the duration of that sub-task if the
combination is flagged as a high-risk inference
vector in the Inference Boundary.

Because modern agent deployments often run as
stateless, horizontally scaled replicas (e.g.,
multiple Kubernetes pods serving the same agent),
the Inference Firewall state (which sources have
been accessed within a given session) MUST be
maintained in a shared, low-latency state store
keyed by the SCO's "session_id".  Implementations
MUST NOT rely solely on in-memory sidecar state
for inference isolation, as a subsequent request
in the same session may be routed to a different
replica that has no awareness of prior source
access.  Suitable state stores include distributed
caches (e.g., Redis, Memcached) or the Knowledge
Graph itself, provided read latency does not
exceed the tool-call interception budget.

## Minimal Disclosure {#minimal-disclosure}

Context Providers -- entities that supply
environmental, behavioral, or relational signals
to the CAAM mesh -- MUST adhere to the principle
of Minimal Disclosure.

### Coarse-Grained Context by Default

All context signals MUST be expressed at the
coarsest granularity sufficient for the
authorization decision by default.  The following
table illustrates the REQUIRED default
granularities:

| Signal | Coarse (Default) | Fine (Opt-in) |
|-|-|-|
| Location | "corporate" / "public" | Country code |
| Network | "trusted" / "untrusted" | CIDR block |
| Time | "business-hours" / "off" | ISO 8601 |
| Platform | "attested" / "unattested" | PCR values |

A Context Provider MUST NOT disclose fine-grained
context unless both of the following conditions
are met:

1. The requested OAuth scope explicitly requires
   the finer granularity (e.g., a geofencing
   scope that specifies country-level).
2. The current CRS is in the Nominal tier
   (S < 0.3).  At Elevated or Critical CRS, the
   Verifier MUST reject fine-grained context
   requests and fall back to coarse defaults to
   reduce the information surface.

### Additional Disclosure Constraints

*  The SCO's "ctx" claim MUST NOT carry raw
   sensor data, biometric measurements, or
   personally identifiable information (PII)
   unless the requested scope explicitly
   requires it and the CRS permits it.

*  Implementations SHOULD support selective
   disclosure mechanisms (e.g., SD-JWT) to
   enable verifiers to request only the claims
   they require from the SCO.

*  When RATS Evidence is included in the SCO,
   the Verifier SHOULD produce an Attestation
   Result that abstracts the raw Evidence into
   a trust score or categorical assessment,
   ensuring that detailed platform measurements
   are not propagated beyond the Verifier.

*  The CAAM mesh MUST NOT log or persist the
   full contents of the "ctx" claim beyond the
   lifetime of the Contextual Session.
   Implementations SHOULD retain only the CRS
   value and remediation tier for audit
   purposes.

The principle of Minimal Disclosure ensures that
the CAAM mesh does not itself become a vector
for privacy leakage by aggregating and
propagating more context than is necessary for
each authorization decision.

# IANA Considerations {#iana-considerations}

This section requests registration of claims,
parameters, and a new registry with IANA.

## JSON Web Token Claims Registration

This specification defines one new claim for
registration in the "JSON Web Token Claims"
registry established by Section 10.1 of
RFC7519.

### Registry Contents

Claim Name:
: ctx

Claim Description:
: CAAM Contextual Assertion.  A JSON object
  containing purpose, scope ceiling, delegation
  depth, consistency token, attestation result
  reference, and contextual risk score for
  agentic authorization decisions.

Change Controller:
: IETF

Specification Document(s):
: sco-definition of this document

Claim Value Type:
: JSON object

The "ctx" claim is used within the Session
Context Object (SCO) defined in
sco-definition.  Its value is a JSON object
with the following members:

*  "purpose" (string, REQUIRED): Human-readable
   intent of the agentic task.  MUST NOT be
   modified by intermediate agents.
*  "scope_ceiling" (array of strings, REQUIRED):
   Maximum OAuth scope derived from the original
   delegation grant.
*  "max_hops" (integer, REQUIRED): Remaining
   delegation depth.  Decremented by 1 at each
   hop.
*  "zookie" (string, OPTIONAL): Consistency
   token for Knowledge Graph queries.
*  "rats_result" (string, OPTIONAL): URI
   reference to the Verifier's Attestation
   Result per RFC9334.
*  "crs" (number, REQUIRED): Contextual Risk
   Score in the range \[0, 1\].

The following is a non-normative example of the
"ctx" claim value:

~~~json
{
  "purpose": "Q4 revenue audit",
  "scope_ceiling": [
    "finance:read",
    "crm:read"
  ],
  "max_hops": 3,
  "zookie": "zk_v1_998877",
  "rats_result":
    "https://verifier.corp.internal/abc",
  "crs": 0.22
}
~~~

## OAuth Parameters Registration

IANA is requested to register the following
entry in the "OAuth Parameters" registry
established by RFC 6749:

Parameter Name:
: caam

Parameter Usage Location:
: authorization request, token request

Change Controller:
: IETF

Specification Document(s):
: This document

The "caam" parameter carries a reference to the
Session Context Object that MUST be validated by
the authorization server before issuing tokens
in a CAAM-compliant deployment.

## OAuth Token Introspection Response

IANA is requested to register the following
entry in the "OAuth Token Introspection
Response" registry:

Response Parameter:
: ctx

Change Controller:
: IETF

Specification Document(s):
: sco-definition of this document

When a CAAM-compliant authorization server
responds to an introspection request for a Sealed
PACT Token, it SHOULD include the "ctx" claim
to enable the Relying Party to perform
contextual validation.

## CAAM Agent Discovery Metadata Registry

IANA is requested to create a new registry
titled "CAAM Agent Discovery Security Metadata"
under the "CAAM" registry group.

### Registration Policy

New entries require Specification Required per
RFC 8126.

### Initial Registry Contents

| Attribute | Description | Req |
|-|-|-|
| caam_v1_supported | CAAM support | REQUIRED |
| sc_object_hash | SCO hash | OPTIONAL |
| inf_boundary_v1 | Inference limits | RECOMMENDED |
| authz_policy_uri | Policy URI | REQUIRED |
| trust_anchor_domain | Trust domain | OPTIONAL |
| rats_evidence_type | Evidence type | OPTIONAL |
| crs_threshold | Max CRS w/o MFA | OPTIONAL |
| max_delegation_hops | Max depth | RECOMMENDED |
| dpop_jwk_uri | DPoP public key | REQUIRED |

### ARDP Registry Extensions

Additionally, this document requests the
following new attributes for the ARDP registry
defined by I-D.pioli-agent-discovery:

*  Policy Compliance Hash: A cryptographic hash
   of the agent's active policy set, allowing
   clients to verify governance.
*  Inference Boundary Declaration: A formal
   specification of the agent's semantic limits.
*  Trust Anchor Reference: A pointer to the
   authority responsible for the agent's
   identity and behavioral attestation.

--- back

# Appendix A. Mathematical Models for Inference Isolation

Let X be the agent's internal state, S_1 and S_2
be two data sources, and B be the inference
boundary defined by policy.  The sidecar ensures
that for any inference I drawn by the agent:

~~~
  P(I | S_1, S_2, X) = P(I | Auth(S_1, S_2), X)
~~~

Where the Auth function represents the set of
permissible inferences under boundary B.  If the
combination is unauthorized, the sidecar applies
a privacy-preserving transformation T such that
the mutual information within the scratchpad is
minimized:

~~~
  I(T(S_1); T(S_2)) <= epsilon
~~~

Where epsilon is the privacy budget defined by
enterprise policy.

# Acknowledgments

The authors thank the IETF community and the
contributors to the Agent Registration and
Discovery Protocol for foundational work that
informed this specification.

# Document History

## draft-barney-caam-00

*  Initial submission.
