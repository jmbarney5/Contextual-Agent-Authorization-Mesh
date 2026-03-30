# Contextual Agent Authorization Mesh (CAAM)

Authors: **Jonathan M. Barney**, **Roberto Pioli**, **Darron Watson**

This repository contains supporting materials for the IETF Internet-Draft:

* draft-barney-caam-00

The authoritative version of the specification is published via the IETF Datatracker. This repository is a collaboration mirror only.

**Datatracker:** <https://datatracker.ietf.org/doc/draft-barney-caam/>

## Status

This is an **Internet-Draft**, a work in progress. It does not represent IETF consensus and may be updated, replaced, or obsoleted at any time.

## Scope

CAAM defines a **contextual authorization mesh** for:

* Relationship-Based Access Control (ReBAC)
* Common Ancestor Constraints in H2A and A2A flows
* Integration with OpenID IPSIE and XAA

CAAM specifies a post-discovery authorization handshake that can be used after ARDP resolution (and is usable with other discovery mechanisms).

## Repository contents

* `draft/draft-barney-caam-00.xml` — xml2rfc v3 source (for IETF submission)
* `draft/draft-barney-caam-00.txt` — text rendering
* `draft/draft-barney-caam-00.md` — Markdown source
* `docs/adr/` — Architecture Decision Records (ADRs) for CAAM implementations (e.g., Okta/SPIFFE POC)
* `docs/` — Other supporting documentation

## How to engage

1. Review the draft on the IETF Datatracker
2. Participate in discussion on the relevant IETF mailing lists
3. Use GitHub issues or pull requests for editorial and technical suggestions

## IETF submission

* Submit updates via the IETF Datatracker: <https://datatracker.ietf.org/submit/>
* This repository is **not** the authoritative change control mechanism

## License

BSD-3-Clause
