# BatchConductor – Conventions

This document defines mandatory conventions and recommended patterns for working
with BatchConductor.

These conventions are not enforced by the scheduler itself but are considered
part of a correct, maintainable and operationally sound batch setup.

They describe how BatchConductor is intended to be used in practice, without
expanding the responsibilities of the scheduler.

---

## Logging and Job Output

BatchConductor distinguishes strictly between diagnostic output and data
produced by batch jobs.

### Diagnostic Output

Standard output (stdout) and standard error (stderr) are considered diagnostic
artifacts.

They are intended for:
- debugging
- error analysis
- operational inspection

Diagnostic output:
- is not part of the batch result
- may be transient
- may be redirected, rotated or discarded
- is not interpreted or persisted by the scheduler

### Data Output

All data relevant beyond diagnostics must be written explicitly to files.

Such data:
- is part of the data plane
- must not rely on stdout or stderr
- should be versioned and archived explicitly by jobs

---

## Job Contracts

BatchConductor adopts the concept of explicit job contracts inspired by classic
JCL DD statements.

A job contract defines:
- which input files a job expects
- which output files a job is expected to produce

### Contract Declaration

Contracts may be declared declaratively in job configuration:

```ini
[job:merge_data]
cmd=jobs/merge.sh
after=fetch_a,fetch_b

inputs=data/a.csv,data/b.csv
outputs=data/merged.csv
```

These declarations define an explicit contract between orchestration and
execution.

---

## Contract Validation

Declaring a contract establishes a mandatory obligation.

Jobs that declare inputs or outputs must validate them explicitly.

Validation includes:
- input files exist
- optional: input files are non-empty
- output files are produced
- optional: output files are non-empty

If validation fails, the job must terminate with a non-zero exit code.

The scheduler reacts only to the exit code and does not interpret contract
semantics.

Failure to validate declared contracts is considered a job implementation error.

---

## Data Inventory and Versioning

Maintaining historical versions of batch data is considered essential for
traceability, reproducibility and operational reliability.

BatchConductor does not implement data inventory or version management itself.

Instead:
- the scheduler provides ordering and execution context
- jobs explicitly perform archiving and versioning
- all data movement is visible, reviewable and version-controlled

Data inventory management is therefore an explicit responsibility of jobs and
operators, not an implicit feature of the scheduler.

This avoids hidden behavior while preserving full operational control.

---

## Example Utilities

BatchConductor does not ship with a runtime utility library.

However, the repository contains an `examples/lib/` directory with small,
focused helper scripts that demonstrate common batch patterns.

These utilities:
- are not part of the BatchConductor runtime
- are not required by the scheduler
- exist solely to illustrate recommended practices

Users are expected to copy, adapt or reimplement these utilities explicitly
within their own job repositories as needed.

---

## Utilities Philosophy

BatchConductor intentionally avoids providing shared job utilities as part of
the core system.

In classic batch environments, data handling utilities were explicit programs
(e.g. SORT, ICEMAN, IDCAMS) and not responsibilities of the scheduler.

BatchConductor follows the same principle:

- the scheduler orchestrates execution
- utilities perform data manipulation
- jobs explicitly invoke utilities

Any abstraction that hides data movement or transformation logic is considered
undesirable, as it reduces transparency and operational control.

---

## Reference Implementation Pattern: Fail-Fast Wrapper

BatchConductor does not provide built-in enforcement of job contracts.

The repository includes an example wrapper script that demonstrates a
standardized, fail-fast validation pattern for declared job contracts.

The wrapper:
- validates declared inputs before job execution
- executes the job
- validates declared outputs after job execution
- terminates early on contract violations

The wrapper is provided as an example only and is not part of the
BatchConductor runtime.

Using such a wrapper is optional and explicitly opt-in.

Its purpose is to demonstrate a practical implementation pattern without
introducing implicit behavior or scheduler-side data validation.

---

## Responsibilities

- The scheduler is responsible for orchestration and execution order.
- Jobs are responsible for data correctness and contract validation.
- Operators decide how logs are handled and retained.

This separation preserves transparency and avoids implicit behavior.
