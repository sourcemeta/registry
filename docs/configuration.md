---
hide:
  - navigation
---

# Configuration Reference

The Sourcemeta Registry is designed around a GitOps workflow: all of its
behavior is determined by the configuration file documented here, and runtime
changes are not permitted. *This ensures that your Registry instance is fully
reproducible, auditable, and version-controlled, just like any other part of
your infrastructure.*

!!! success

    Because the Registry is entirely configured at build time (with changes
    applied only via a redeployment), it achieves significant performance
    advantages. Schemas are pre-optimized at build time, and the service itself
    is fully stateless, enabling effortless horizontal scaling and predictable
    performance under load.

This configuration file is designed to give you complete freedom to structure
your Registry instance in a way that best suits your organization. Compared to
many other schema registry solutions, it imposes no artificial constraints on
hierarchy, versioning, or schema organization. You can version and arrange your
schemas however you like: by department, by function, in a flat structure, or
in any other way you can think of. This allows your instance to reflect your
company's needs rather than a pre-defined model.

!!! note

    By convention, the name of the configuration file is `registry.json`.

## `registry.json`

## Collections

## Pages

## Includes
