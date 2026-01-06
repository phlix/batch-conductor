# BatchConductor – Examples

This document provides illustrative examples demonstrating how BatchConductor
is intended to be used in practice.

These examples are not part of the scheduler itself and are provided solely
for explanation and reference.

---

## Minimal Job Configuration

```ini
[job:hello]
cmd=jobs/hello.sh
```

```sh
#!/bin/sh
echo "Hello from BatchConductor"
```

---

## Job Dependencies

```ini
[job:fetch_data]
cmd=jobs/fetch.sh

[job:process_data]
cmd=jobs/process.sh
after=fetch_data
```

---

## Fan-Out Example

```ini
[job:normalize]
cmd=jobs/normalize.sh

[job:export_csv]
cmd=jobs/export_csv.sh
after=normalize

[job:export_json]
cmd=jobs/export_json.sh
after=normalize
```

---

## Fan-In Example

```ini
[job:fetch_a]
cmd=jobs/fetch_a.sh

[job:fetch_b]
cmd=jobs/fetch_b.sh

[job:merge]
cmd=jobs/merge.sh
after=fetch_a,fetch_b
```

---

## Job Contract Example

```ini
[job:merge_data]
cmd=jobs/merge.sh
after=fetch_a,fetch_b

inputs=data/a.csv,data/b.csv
outputs=data/merged.csv
```

```sh
#!/bin/sh
[ -f data/a.csv ] || exit 1
[ -f data/b.csv ] || exit 1

# processing

[ -f data/merged.csv ] || exit 1
```

---

## Fail-Fast Wrapper Usage

```ini
[job:merge_data]
cmd=examples/lib/run_with_contract.sh jobs/merge.sh

inputs=data/a.csv,data/b.csv
outputs=data/merged.csv
```

---

These examples illustrate recommended usage patterns while keeping orchestration
logic separate from job implementation.
