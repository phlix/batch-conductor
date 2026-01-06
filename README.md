# BatchConductor

BatchConductor is a minimal, explicit batch job scheduler inspired by
classic enterprise batch systems (e.g. Control-M, JCL-based environments).

It is intentionally simple:
- no daemon
- no database
- no implicit magic
- file-based state
- deterministic behavior

And yes: it is written in **Perl** — because camels are cool 🐪

---

## Design Philosophy

BatchConductor separates concerns strictly:

- **Scheduler** decides *what may run*
- **Jobs** decide *what happens*
- **Status** represents *batch truth*
- **Logs** explain *scheduler decisions*

There is no hidden behavior.
If something happens, it is visible in a file.

---

## Repository Structure

```
bin/
  scheduler.pl      # batch scheduler core
  bc-status         # read-only status viewer

config/
  jobs/             # user-specific job definitions (not versioned)

examples/
  jobs/             # example job definitions

run/
  status.dat        # batch state (runtime, not versioned)
  run.log           # scheduler event log (runtime, not versioned)
```

### Important Notes

- `config/` belongs to the **user / deployment**
- `examples/` belongs to the **project**
- `run/` is **runtime state only** and must never be committed

---

## Quick Start

### 1. Create job configuration directory

```
mkdir -p config/jobs
```

### 2. Copy example jobs

```
cp examples/jobs/*.conf config/jobs/
```

### 3. Run the scheduler

```
./bin/scheduler.pl
```

You should see output similar to:

```
[2026-01-06 23:34:49] running job hello
hello world
```

---

## Viewing Batch Status

Use the read-only status tool:

```
./bin/bc-status
```

Example output:

```
BatchConductor Status
=====================

JOB                  STATE    LAST RUN             LAST EVENT
--------------------------------------------------------------------------------
hello                OK       2026-01-06 23:34:49  SKIPPED (already completed)
```

### Field Semantics

- **STATE**
  - current batch state (`OK` / `ERROR`)
- **LAST RUN**
  - timestamp of the last *actual execution*
  - skipped runs do not count
- **LAST EVENT**
  - last scheduler decision (`OK`, `ERROR`, `SKIPPED`, …)

---

## Job Definitions

Jobs are defined in simple `.conf` files:

```ini
[job:hello]
cmd=echo "hello world"
```

Dependencies are expressed explicitly:

```ini
[job:merge]
cmd=./merge.sh
after=fetch_a,fetch_b
```

This allows Fan-In and Fan-Out patterns without special syntax.

---

## What BatchConductor Is Not

- not a workflow engine
- not a data pipeline framework
- not a monitoring system
- not a replacement for cron

It is a **batch coordination tool**.

---

## License

MIT License.

See `LICENSE` for details.
