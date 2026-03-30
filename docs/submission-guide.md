# CAAM: Submission and Engagement Guide

## Problem Statement

Modern agentic systems require fine-grained, context-aware authorization that goes beyond
static role-based policies. When agents operate in multi-participant sessions — spanning
organizational boundaries — the authorization surface must reflect real-time relationships
between users, agents, and data silos.

The **Contextual Agent Authorization Mesh (CAAM)** addresses this gap as a normative
extension to the **Agent Registration and Discovery Protocol (ARDP)**
([draft-pioli-agent-discovery](https://datatracker.ietf.org/doc/draft-pioli-agent-discovery/)).

## Relationship to ARDP

CAAM acts as a **sidecar** to ARDP, extending the `RESOLVE` method with contextual
authorization semantics. It does not replace ARDP but augments it with:

- Relationship-Based Access Control (ReBAC) via Knowledge Graph inference
- Common Ancestor Constraints for multi-participant sessions
- OpenID IPSIE session binding and Shared Signals integration
- OpenID XAA coarse-grained delegation as a graph root node

## IETF Submission

- Target working group: TBD (candidates: OAUTH, GNAP, or a new BOF)
- Submission via IETF Datatracker: https://datatracker.ietf.org/submit/
- This repository is a **collaboration mirror**; the Datatracker is authoritative

## How to Engage

1. Review the draft in `draft/draft-barney-caam-00.md`
2. Open GitHub issues for editorial or technical feedback
3. Participate in relevant IETF mailing list discussions once a working group is identified
