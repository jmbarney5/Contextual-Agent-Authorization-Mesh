# Architecture Design Document: Provenance-Attenuated Chain Token (PACT)

## 1. Executive Summary
As autonomous agent ecosystems scale, traditional identity frameworks (SPIFFE/SPIRE, standard JWTs, OAuth) face critical breaking points. They suffer from the "confused deputy" problem in multi-hop chains, are vulnerable to "unwrapping" attacks, and require massive, frictionless infrastructure (e.g., ubiquitous SPIRE agents) that is impossible to mandate across organizational boundaries. 

This document outlines the **Provenance-Attenuated Chain Token (PACT)** architecture. By leveraging ephemeral cryptographic key handovers, this architecture securely preserves a user's original intent across an infinite number of agent hops. It guarantees non-repudiation, prevents privilege escalation, naturally crosses organizational boundaries, and shifts enterprise security from reactive infrastructure monitoring to **preemptive, intent-based authorization**.

---

## 2. The Core Problems Solved

### 2.1 The "Unwrapping" Vulnerability of Nested Tokens
Current proposals for multi-hop agent identity (like standard WIMSE nested tokens or ID-Mode LSVIDs) wrap subsequent claims inside new signatures. 
* **The Flaw:** A malicious or compromised agent downstream can simply "unwrap" the token, removing an intermediary's constraints, and pass the original token forward. The end-consumer has no way of knowing a hop was erased.

### 2.2 The Cross-Boundary / Federation Nightmare
SPIFFE and LSVID require "Audience" awareness—Agent A must know exactly who Agent B is. 
* **The Flaw:** When crossing into another company's network (e.g., calling a third-party SaaS agent), you cannot know their internal agent topology. SPIFFE Federation is notoriously difficult to configure and breaks down in heterogeneous environments.

### 2.3 The DevOps Burden
* **The Flaw:** Full attestation models require deploying an identity agent (like SPIRE) on every single node, rotating certificates constantly. For most enterprises, this is a heavy, unadoptable "DevOps nightmare."

---

## 3. Architecture Design: The PACT Flow

The PACT architecture utilizes a modified JWT structure:
`Header . Block_0 (Genesis) . Block_1 . ... . Block_N . Final_Signature`

Instead of relying on a centralized PKI for every hop, trust is chained forward using **ephemeral keys**.

### 3.1 Step-by-Step Flow

1. **The Genesis Block (Block 0):**
   * A User expresses an intent (e.g., "Book travel to Houston under $2,000").
   * The User authenticates with their IDP. The IDP mints **Block 0**.
   * *The Trick:* Block 0 includes an ephemeral Public Key (`PK_1`). 
   * The IDP signs Block 0. The User passes Block 0 *and* the private key (`SK_1`) to the first Agent.
2. **The Ephemeral Handover (Intermediate Blocks):**
   * Agent 1 receives the token and `SK_1`.
   * Agent 1 decides to attenuate the intent (e.g., "Allocate $1,000 specifically for flights").
   * Agent 1 generates a new ephemeral keypair (`PK_2`, `SK_2`).
   * Agent 1 creates **Block 1** (containing only the delta/attenuation and `PK_2`).
   * Agent 1 signs Block 1 using `SK_1`, then passes the token and `SK_2` to Agent 2.
3. **Sealing the Token (Final Block):**
   * The final agent in the chain (Agent N) prepares to call the target API.
   * Agent N creates **Block N** with no new public key, signaling the end of the chain.
   * Agent N signs the complete token. It is now a sealed bearer token.

### 3.2 Validation
The API Resource Server (Consumer) validates the token by:
1. Reaching out to the IDP (once) to verify the signature on Block 0.
2. Verifying Block 1 was signed by `PK_1` (found in Block 0).
3. Verifying Block 2 was signed by `PK_2` (found in Block 1), and so on.
*There are no network calls required to validate the intermediate chain.*

---

## 4. Superiority Matrix (PACT vs. Alternatives)

| Feature | SPIFFE / SPIRE | LSVID (ID-Mode) | PACT |
| :--- | :--- | :--- | :--- |
| **Infrastructure Req.** | Heavy (Agent on every node) | Heavy (Relies on SPIRE) | **Lightweight** (Only IDP needs heavy PKI; agents use standard crypto libs) |
| **Tamper Resistance** | Low (Susceptible to unwrapping) | Low (Susceptible to unwrapping) | **Absolute** (Removing a block breaks the ephemeral key chain signature) |
| **Cross-Boundary** | Hard (Complex SPIRE Federation) | Hard (Requires known Audience) | **Native** (Intermediaries can be completely anonymous to the receiver) |
| **Payload Size** | Large (X.509 certs) | Medium (Full nested tokens) | **Minimal** (Only intent deltas + 64-byte ECDSA keys are added per hop) |

---

## 5. Preventing Lateral Movement & Compromise

Traditional security models focus on securing the *network perimeter* or the *workload identity*. If a workload is compromised, the attacker inherits its identity and moves laterally. The PACT model fundamentally neutralizes this through the **Intersection of Permissions**.

### 5.1 The "Intersection of Permissions" Principle
In the PACT model, an agent can *only* down-scope (attenuate) a token. It can never up-scope it. 
* If the Genesis block says "Read/Write S3 Bucket A", an intermediate agent can attenuate it to "Read-Only S3 Bucket A".
* The final execution context is the strict mathematical intersection of all constraints applied in the chain.

### 5.2 Containment of a Compromised Agent
If an attacker compromises Agent 2 in the chain:
1. The attacker possesses the ephemeral private key for *that specific transaction*.
2. The attacker **cannot** generate a new Genesis Block (they do not have the IDP's keys).
3. The attacker **cannot** alter Block 0 or Block 1 (they do not have the previous ephemeral keys).
4. The attacker **cannot** pivot to a different internal API because the token they hold is cryptographically bound to the original user's intent. 
*Result:* The blast radius of the compromised agent is strictly limited to the exact context and constraints of the active tokens passing through it. Lateral movement is mathematically blocked by the cryptography of the token itself.

---

## 6. Shifting Security: Reactive to Preemptive

Historically, security is **Reactive** (e.g., an observability tool like Splunk sees anomalous API calls and subsequently triggers an IP block or kills a session). 

The PACT architecture shifts this to **Preemptive, Intent-Based Security**:
* Because the intent is cryptographically sealed and immutable, the target API Gateway evaluates the *entire lineage and intent* before a single line of execution occurs.
* If a token arrives asking to delete a database, but the Genesis Block's intent was "Query user status", the transaction fails cryptographic validation instantly. 
* Instead of building internal threat models of malicious actors, the system simply drops any request where the cryptographic intent does not exactly match the requested execution, preventing the attack before it happens.