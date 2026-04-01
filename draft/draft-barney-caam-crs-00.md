---
title: "Contextual Risk Scoring for Agentic Authorization"
abbrev: "CAAM-CRS"
docname: draft-barney-caam-crs-00
date: 2026-04-01
category: info
ipr: trust200902
area: Security
workgroup: TBD
keyword:
  - authorization
  - agents
  - risk scoring
  - context
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
    ins: Y. Porla
    name: Yogi Porla
    organization: Google
    street: ""
    city: ""
    region: ""
    code: ""
    country: US
    email: yogiporla@google.com

normative:
  RFC2119:
  RFC8174:
  RFC9334:
  I-D.barney-caam:
    title: "Contextual Agent Authorization Mesh (CAAM)"
    author:
      - ins: J. M. Barney
        name: Jonathan M. Barney
      - ins: R. Pioli
        name: Roberto Pioli
      - ins: D. Watson
        name: Darron Watson
      - ins: Y. Porla
        name: Yogi Porla
      - ins: B. Woodward
        name: Brad Woodward
    date: 2026
    target: https://datatracker.ietf.org/doc/draft-barney-caam/

informative:
  SPIFFE:
    title: "Secure Production Identity Framework for Everyone"
    target: https://spiffe.io/
  IPSIE:
    title: "Interoperability Profiling for Secure Identity in the Enterprise"
    author:
      - org: OpenID Foundation
    target: https://openid.net/wg/ipsie/

--- abstract

This document defines the Contextual Risk Scoring
(CRS) model for use with the Contextual Agent
Authorization Mesh (CAAM) I-D.barney-caam.
CRS provides a deployment-configurable method for
calculating a composite risk score that combines
identity provenance, execution environment trust,
and data sensitivity signals into a single
real-valued score.  This score drives tiered
remediation actions (autonomous execution,
step-up authentication, or human-in-the-loop
approval) at the CAAM sidecar.

This specification is separated from the core
CAAM document to allow deployments to adopt
alternative risk scoring models while maintaining
interoperability with the CAAM authorization
framework.

--- middle

# Introduction

The Contextual Agent Authorization Mesh (CAAM)
I-D.barney-caam defines a sidecar-based
authorization framework for autonomous agent
ecosystems.  CAAM specifies the Provenance-
Attenuated Chain Token (PACT) architecture, the
Session Context Object (SCO), and the post-discovery
authorization handshake.

A key component of CAAM's enforcement model is
the Contextual Risk Score (CRS): a real-valued
score that determines the remediation tier
applied to each tool call within the mesh.
However, the weights and factors used to compute
the CRS are inherently deployment-specific.
Different organizations will assign different
importance to identity provenance versus
environmental attestation versus data
classification based on their threat model,
regulatory requirements, and infrastructure
maturity.

This document separates the CRS computation
model from the core CAAM specification to
preserve CAAM's architectural neutrality.
Deployments MAY adopt the scoring model defined
herein, or MAY substitute an alternative model
provided it produces a score in the range
\[0, 1\] and maps to the remediation tiers
defined in this document.

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED",
"SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted
as described in BCP 14 RFC2119 RFC8174 when,
and only when, they appear in all capitals, as
shown here.

Contextual Risk Score (CRS):
: A real-valued score S in the range \[0, 1\]
  assigned to every request within the CAAM mesh,
  encoding the combined risk of provenance,
  environment trust, and data sensitivity.

# Contextual Risk Scoring Model {#crs-model}

## Score Computation

Every request within the CAAM mesh MUST be
assigned a Contextual Risk Score (CRS), S in the
range \[0, 1\], calculated by the Verifier (or
by the sidecar when no dedicated Verifier is
deployed).

~~~
  S = w_1 * P + w_2 * E + w_3 * D
~~~

Where P is Provenance, E is EnvTrust, D is
DataSensitivity, w_1 + w_2 + w_3 = 1, and
weights are configurable per deployment.

## Scoring Factors

### Provenance (P)

The Provenance factor encodes the strength and
freshness of the identity chain:

*  Hop count from the original human user.
*  PACT cryptographic integrity (all ephemeral
   key signatures verified).
*  SCO integrity (the Genesis Block signature
   from the originating IdP is valid and
   unexpired).
*  Token age relative to the SCO's "exp" claim.

A shorter chain with a fresh, cryptographically
valid PACT yields a lower (less risky) Provenance
score.  A long chain with near-expiry tokens
yields a higher score.

### Environment Trust (E)

The EnvTrust factor encodes the trustworthiness
of the execution environment per RATS Attestation
Evidence RFC9334:

*  TPM status and platform integrity.
*  Container manifest integrity (signed image
   digests).
*  Geographic compliance (execution region
   matches policy).

When RATS Evidence is not available (Minimum
Viable deployments), E SHOULD default to 0.5
(neutral).  Deployments MAY configure a higher
default to reflect elevated risk for unattested
environments.

### Data Sensitivity (D)

The DataSensitivity factor encodes the
classification of the target resource:

*  Public data: lowest sensitivity.
*  Internal data: moderate sensitivity.
*  Confidential data: high sensitivity.
*  Regulated PII: highest sensitivity.

## Weight Configuration

The weights w_1, w_2, and w_3 MUST sum to 1.
Deployments SHOULD configure weights based on
their threat model and regulatory posture.

The following are non-normative example
configurations:

| Deployment Type | w_1 (Provenance) | w_2 (EnvTrust) | w_3 (DataSensitivity) |
|-|-|-|-|
| Cloud-Native SaaS | 0.4 | 0.2 | 0.4 |
| Regulated Financial | 0.3 | 0.3 | 0.4 |
| Air-Gapped / Defense | 0.2 | 0.5 | 0.3 |
| Minimum Viable | 0.5 | 0.0 | 0.5 |

# Remediation Tiers {#remediation-tiers}

The CRS value determines the remediation tier
applied to each tool call:

| CRS Range | Level | Action |
|-|-|-|
| S < 0.3 | Nominal | Sealed PACT execution permitted |
| 0.3 <= S < 0.7 | Elevated | Step-Up authentication (MFA) REQUIRED |
| S >= 0.7 | Critical | Human-in-the-Loop (HITL) approval REQUIRED |

The CRS MUST be recalculated on every tool call.
A spike in CRS mid-session (e.g., from a Shared
Signals Framework risk event) MUST trigger
immediate re-evaluation and potential session
downgrade.

# Integration with CAAM

## The "crs" Claim

The CAAM Session Context Object (SCO) defined in
I-D.barney-caam includes a "crs" member within
the "ctx" claim.  The value of this member MUST
be populated according to the scoring model
adopted by the deployment.

When this specification is adopted, the "crs"
value is computed as defined in crs-model.

## Sidecar Enforcement

The CAAM sidecar MUST consume the CRS value and
enforce the remediation tier defined in
remediation-tiers before permitting any tool
call to proceed.

## Alternative Scoring Models

Deployments that adopt an alternative scoring
model MUST ensure:

1. The alternative model produces a score in the
   range \[0, 1\].
2. The score maps to the remediation tiers
   defined in remediation-tiers (or to a
   superset of those tiers with stricter
   thresholds).
3. The scoring model is documented and
   discoverable via the CAAM Agent Discovery
   Metadata (e.g., via a new
   "crs_model_uri" attribute).

# Security Considerations

## Weight Manipulation

If an attacker can influence the weight
configuration (w_1, w_2, w_3), they can
systematically lower the CRS for malicious
requests.  Weight configurations MUST be
treated as security-sensitive policy and
MUST be protected with the same controls
applied to authorization policies (signed
bundles, audit trails, CI/CD review gates).

## Factor Spoofing

Each scoring factor is susceptible to spoofing
if its input signals are not independently
verified.  Implementations MUST NOT accept
self-asserted values for any CRS factor.
Provenance is verified via PACT chain
validation, EnvTrust via RATS Evidence, and
DataSensitivity via the resource server's
classification metadata.

# IANA Considerations

This document has no IANA actions.  The "crs"
member of the "ctx" claim is registered by
I-D.barney-caam.

--- back

# Acknowledgments

The separation of Contextual Risk Scoring into a
companion specification was motivated by feedback
from Yogi Porla (Google), who identified that
embedding deployment-specific scoring weights
into the core CAAM architecture would add an
opinionated approach that could hinder adoption
across diverse deployment environments.

The authors also thank the IETF community and the
contributors to the CAAM specification for
ongoing review and feedback.

# Document History

## draft-barney-caam-crs-00

*  Initial submission.  Extracted from
   draft-barney-caam-00, Section 4.5.
