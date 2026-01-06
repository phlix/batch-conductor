BatchConductor
--------------
Job orchestration.

BatchConductor is a lightweight, file-based batch job orchestrator inspired by
classic enterprise scheduling systems.

It focuses on explicit control flow, dependency-aware execution and transparent
state handling, rather than feature-rich workflow engines.

## Implementation Language

BatchConductor is intentionally implemented in Perl.

Perl has a long tradition in batch processing, text handling and operational
tooling. Its strengths align well with the explicit, file-oriented nature of
classic batch systems.

Additionally, camels are cool.

## What BatchConductor Is Not

BatchConductor is intentionally minimal.

It is not:
- a workflow engine
- a data processing framework
- a job DSL
- a utility library
- a replacement for Unix tools

BatchConductor focuses exclusively on orchestration and control flow.
All data handling is expected to be implemented explicitly within jobs.

## Project Status

BatchConductor provides a stable and intentionally small core.
Future work focuses on incremental improvements rather than expanding scope.

## License

BatchConductor is released under the MIT License.

