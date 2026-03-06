# EXECUTION_PROTOCOL.md

This document enforces anti-loop execution discipline.

## Core Principle
Reasoning does not equal execution.
Execution requires state mutation via tools.

## Hard Rules

1. If execution intent is detected, tool invocation is mandatory in the next response.
2. Large migrations must start with atomic confirmation step.
3. No reporting of completion without verification step.
4. Heartbeat stall triggers forced tool action.
5. Conversational reassurance cannot substitute state mutation.

## Goal
Prevent narrative execution loops.
Ensure deterministic state mutation and verification.
