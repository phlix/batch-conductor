# BatchConductor – Design

## Purpose

BatchConductor is a lightweight batch job orchestrator inspired by classic
enterprise scheduling systems.

Its goal is to provide deterministic, dependency-aware batch execution using
simple, transparent mechanisms instead of complex workflow engines or
long-running daemons.

BatchConductor deliberately focuses on orchestration and control flow, not on
data processing or transformation.

---

## Scheduling Model

BatchConductor separates concerns strictly:

- Cron provides the time-based trigger
- The scheduler evaluates job state and dependencies
- Jobs perform work and return exit codes

Cron is intentionally not used as a scheduler. It merely invokes the
BatchConductor entry point at regular intervals.

The scheduler itself is short-lived and stateless between invocations, with all
state persisted explicitly in files.

---

## Job Semantics

Each job is defined declaratively and executed as an external process.

A job:
- has a unique name
- has a command to execute
- may declare dependencies on other jobs
- produces an exit code

Exit codes are the only mechanism used to determine success or failure.

A job is considered complete for the current batch day once it exits
successfully.

Jobs must not:
- query scheduler state
- decide whether they should run
- modify scheduler metadata

---

## Dependencies

Job dependencies are expressed declaratively using `after=` relationships.

A job is eligible for execution if:
- it has not yet completed successfully for the current batch day
- all dependency jobs have completed successfully

Failures block dependent jobs.

Dependency evaluation is deterministic and does not rely on implicit ordering or
timing.

---

## Daily Batch Cycle

BatchConductor operates on an explicit daily batch cycle.

A new batch day is initiated by running a dedicated reset job.

During this reset:
- the previous batch status is archived
- a new, empty status file is created

The scheduler itself does not determine day boundaries.

This mirrors the "New Day" concept of classic enterprise batch systems, where the
batch date is advanced explicitly rather than implicitly.

Without running the reset job, all scheduler state remains associated with the
current batch day.

---

## Control Plane vs. Data Plane

BatchConductor strictly separates control responsibilities from data handling.

The scheduler (control plane) is responsible for:
- determining batch cycles
- evaluating job dependencies
- tracking execution state

The scheduler must never modify user data implicitly.

All data movement, versioning, archiving or retention is part of the data plane
and must be implemented as explicit jobs.

---

## Configuration Philosophy (JCL Replacement)

BatchConductor uses a simple, declarative configuration format as a modern
replacement for classic JCL.

Configuration is:
- static
- declarative
- version-controlled

No logic, conditionals or expressions are permitted in configuration files.

All execution semantics are implemented in the scheduler, not in configuration.

---

## Implementation Language

BatchConductor is implemented in Perl by design.

Perl is well suited for batch-style processing due to its strengths in text
processing, file-based workflows and scripting of operational tasks.

The choice of Perl is intentional and pragmatic, not incidental.

Also, camels are cool.

---

## Non-Goals

BatchConductor explicitly does not aim to be:

- a workflow engine
- a daemon-based system
- a cloud-native orchestrator
- a data processing framework
- a replacement for cron
- a job DSL or plugin platform

Any feature that would blur the separation between orchestration and execution
is considered out of scope.
