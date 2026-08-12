# Benchmark data

This directory contains small, auditable inputs for the reproducible benchmark command:

    moon run cmd/benchmark --target wasm-gc

## Workloads

- data/karate_club_edges.csv is the standard Zachary Karate Club network: 34 nodes and 78 undirected edges. Node identifiers are zero-based and the file contains one canonical edge per row.
- cmd/benchmark also constructs a 12-task compiler dependency pipeline. It exercises dependency validation, topological scheduling, earliest start and finish times, makespan, and critical-path reporting.
- The sparse-network baseline constructs 500 nodes and 600 directed edges deterministically in MoonBit. It exercises traversal, diameter, distance, and density metrics without downloading external data.

The benchmark prints CSV-like key/value rows. Its expected regression anchors are recorded in the repository README. These values are intended to detect algorithm or serialization regressions; they are not hardware performance claims.

## Provenance

The Karate Club graph is the canonical dataset described by Wayne W. Zachary, “An Information Flow Model for Conflict and Fission in Small Groups” (1977), and is available through the NetworkX karate_club_graph generator:

https://networkx.org/documentation/latest/reference/generated/networkx.generators.social.karate_club_graph.html

The checked-in CSV is a data representation of that public reference graph, converted to zero-based node identifiers for the MoonBit benchmark. No third-party source code is included. The project source remains MIT licensed; the dataset reference and citation are retained here for reproducibility.
