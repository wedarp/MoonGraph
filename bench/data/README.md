# Karate Club data provenance

karate_club_edges.csv is the canonical Zachary Karate Club network used by the reproducible MoonGraph benchmark.

- Dataset: 34 nodes and 78 undirected edges.
- Identifier convention: zero-based node identifiers.
- File format: CSV with source,target header and one canonical edge per row.
- Original reference: Wayne W. Zachary, “An Information Flow Model for Conflict and Fission in Small Groups”, 1977.
- NetworkX reference: https://networkx.org/documentation/latest/reference/generated/networkx.generators.social.karate_club_graph.html

The CSV is a data representation of the public reference graph, not copied program source. It is checked in so that the wasm benchmark does not depend on network access.
