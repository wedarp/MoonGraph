# MoonGraph

MoonGraph 是一个纯 MoonBit 实现的通用图论基础库，面向依赖解析、网络拓扑、路径规划、编译器基础设施和教学实验等场景。项目采用邻接表存储，节点和边都支持泛型权重；算法模块保持零第三方依赖，可作为 MoonBit 模块直接复用。

MoonGraph is a general-purpose graph data-structure and algorithm library written entirely in MoonBit. It provides a generic adjacency-list graph, pathfinding, connectivity analysis, scheduling utilities, network flow, matching, and export to Graphviz DOT without third-party runtime dependencies.

[![CI](https://github.com/wedarp/MoonGraph/actions/workflows/check.yml/badge.svg)](https://github.com/wedarp/MoonGraph/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Features

### Core graph model

- Graph[N, E] stores generic node weights N and edge weights E.
- Directed and undirected graphs are supported.
- Safe node/edge inspection: indices, weights, degrees, adjacency checks, and invalid-index handling.
- Breadth-first search, depth-first search, DOT export, cycle detection, and topological ordering.
- PriorityQueue and DisjointSet are included as reusable supporting structures.

### Algorithms

| Area | APIs | Complexity |
| --- | --- | --- |
| Shortest paths | dijkstra, shortest_path, a_star, bellman_ford | O((V + E) log V) for heap-based non-negative paths; O(VE) for Bellman–Ford |
| All pairs | floyd_warshall | O(V^3) |
| Connectivity | weakly_connected_components, is_weakly_connected, transitive_closure, Tarjan SCC | O(V + E) per traversal; closure uses one BFS per source |
| Scheduling | topological_sort, topological_layers, dag_longest_paths | O(V + E) |
| Undirected analysis | kruskal_mst, prim_mst, articulation_points, bridges, greedy_coloring | O(E log E) for MST; low-link analysis is O(V + E) |
| Network algorithms | max_flow, maximum_bipartite_matching, directed Eulerian trails | Edmonds–Karp O(VE^2); matching uses augmenting paths |
| Visualization | to_dot | O(V + E) plus output size |

The library reports unreachable integer distances as 2147483647, matching the existing single-source shortest-path APIs. Maximum flow accepts non-negative integer capacities, aggregates parallel directed edges, and rejects unsupported input with Result errors.

## Install and import

Install the module from Mooncakes:

    moon add wedarp/moongraph

The source package is imported as wedarp/moongraph/src:

    import {
      "wedarp/moongraph/src" @moongraph,
    }

    fn main {
      let graph : @moongraph.Graph[String, Int] =
        @moongraph.Graph::new(directed=true)
      let source = graph.add_node("source")
      let sink = graph.add_node("sink")
      let _ = graph.add_edge(source, sink, 7)
      println("\{graph.node_count()}")
    }

## Runnable demo

The repository includes a standalone command package that imports the library through its public module path:

    moon run cmd/demo --target wasm-gc

Expected output includes node and edge counts, a BFS summary, a shortest-path result, a topological-order summary, and Graphviz DOT text. Native execution is also supported when a system C compiler is available:

    moon run cmd/demo --target native

## Development and verification

The workflow follows the MoonBit community check template and installs the latest stable MoonBit toolchain on every run. At this acceptance revision, the official toolchain reports MoonBit 0.10.4; the stable documentation site is labeled v0.10.3. Keeping installation on the official latest channel avoids pinning an unavailable archive name.

    moon version --all
    moon update
    moon fmt
    moon check --target all --deny-warn
    moon test --target all --deny-warn
    moon info

On a machine without a native C compiler, the WebAssembly target is sufficient for local validation:

    moon check --target wasm-gc --deny-warn
    moon test --target wasm-gc --deny-warn
    moon run cmd/demo --target wasm-gc

The acceptance revision contains 22 automated tests across the core data structure and algorithm modules. The current checkout measures 23 MoonBit source files and 1,964 lines including tests; generated _build and .mbti files are ignored.

## Repository and provenance

- GitHub: <https://github.com/wedarp/MoonGraph>
- GitLink: <https://www.gitlink.org.cn/Qqwkkr/MoonGraph>
- Mooncakes: <https://mooncakes.io/>
- Competition: <https://moonbitlang.github.io/OSC2026/>
- Algorithm design reference/source: <https://github.com/petgraph/petgraph>
- petgraph upstream license: <https://github.com/petgraph/petgraph/blob/master/LICENSE-MIT> and <https://github.com/petgraph/petgraph/blob/master/LICENSE-APACHE>

MoonGraph is an independent MoonBit implementation. The project references petgraph for ecosystem positioning, common graph-algorithm terminology, and API-scope comparison; it does not copy petgraph source code. MoonGraph itself is released under MIT; petgraph remains under its upstream MIT/Apache-2.0 dual license.

## Contributing

Keep public APIs documented, add a regression test for every behavior change, run the commands above before committing, and keep the public repository history attributable to the project creator. New algorithms should state their input constraints and asymptotic complexity.

## Changelog

### Acceptance revision

- Added cross-platform CI using the official latest stable MoonBit toolchain.
- Migrated project metadata to the current moon.mod and moon.pkg format.
- Added safe graph inspection APIs and invalid-index handling.
- Added connectivity, closure, all-pairs shortest paths, DAG analysis, graph coloring, low-link analysis, max-flow, matching, Eulerian trails, Prim forests, shortest-path reconstruction, and topological layers.
- Added a standalone cmd/demo package and reproducible validation commands.

## License

MoonGraph is released under the MIT License. See [LICENSE](LICENSE).
