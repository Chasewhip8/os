# Nix Configuration Agent Instructions

## Core Principle

Optimize for clarity, composability, and reversibility. Every change should be easy to understand, easy to disable, and safe to evolve.

## Architecture Wisdom

### 1. Keep Boundaries Clean

- Separate host-level concerns from user-level concerns.
- Keep platform-specific logic isolated from cross-platform logic.
- Avoid coupling unrelated domains in a single module.

### 2. Compose, Do Not Entangle

- Prefer small modules with one clear responsibility.
- Compose behavior through `imports` and options, not copy-paste.
- Design modules to be independently toggleable.

### 3. Make Data Flow Obvious

- Keep dependencies directional and predictable.
- Avoid circular imports and hidden implicit dependencies.
- Favor explicit options and documented defaults over ad-hoc overrides.

### 4. Prefer Stable Interfaces

- Expose configuration through typed options (`mkOption`) where reuse is expected.
- Use defaults to reduce repetition, but keep override points clear.
- Treat module interfaces as contracts: change them deliberately.

### 5. Localize Change

- Add new behavior in focused modules rather than expanding unrelated files.
- Refactor duplication into shared abstractions only when repetition becomes meaningful.
- Keep each module small enough to reason about quickly.

### 6. Be Explicit About Platform Decisions

- Gate platform behavior clearly and in one place.
- Avoid scattering platform conditionals throughout unrelated logic.
- Keep platform divergence shallow so cross-platform maintenance stays cheap.

### 7. Preserve Idempotence and Safety

- Ensure repeated evaluations and rebuilds produce predictable outcomes.
- Avoid side effects during evaluation.
- Prefer deterministic inputs and pinned dependencies.

## Change Checklist

- [ ] Does this change keep system and user concerns cleanly separated?
- [ ] Is the module responsibility still singular and clear?
- [ ] Can the feature be disabled without collateral breakage?
- [ ] Are defaults and overrides explicit and understandable?
- [ ] Does this reduce long-term complexity instead of shifting it?
