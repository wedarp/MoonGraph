///|
test "graph creation and node/edge addition" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")

  assert_eq(g.node_count(), 3)
  assert_true(g.node_weight(n0) == Some("A"))

  let e0 = g.add_edge(n0, n1, 10)
  let _ = g.add_edge(n1, n2, 20)

  assert_eq(g.edge_count(), 2)
  assert_true(g.edge_weight(e0) == Some(10))

  let nbrs = g.neighbors(n1)
  assert_eq(nbrs.length(), 1)
  assert_eq(nbrs[0].val, n2.val)
}

///|
test "bfs and dfs traversal" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")
  let n3 = g.add_node("D")

  let _ = g.add_edge(n0, n1, 1)
  let _ = g.add_edge(n0, n2, 1)
  let _ = g.add_edge(n1, n3, 1)

  let bfs_res = g.bfs(n0)
  assert_eq(bfs_res.length(), 4)
  assert_eq(bfs_res[0].val, n0.val)
  assert_eq(bfs_res[1].val, n2.val)
  assert_eq(bfs_res[2].val, n1.val)
  assert_eq(bfs_res[3].val, n3.val)

  let dfs_res = g.dfs(n0)
  assert_eq(dfs_res.length(), 4)
  assert_eq(dfs_res[0].val, n0.val)
}

///|
test "dijkstra shortest path" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")
  let n3 = g.add_node("D")

  let _ = g.add_edge(n0, n1, 1)
  let _ = g.add_edge(n0, n2, 4)
  let _ = g.add_edge(n1, n2, 2)
  let _ = g.add_edge(n1, n3, 6)
  let _ = g.add_edge(n2, n3, 3)

  let dists = g.dijkstra(n0)
  assert_eq(dists[n0.val], 0)
  assert_eq(dists[n1.val], 1)
  assert_eq(dists[n2.val], 3) // A -> B -> C = 1 + 2 = 3 (better than A -> C = 4)
  assert_eq(dists[n3.val], 6) // A -> B -> C -> D = 1 + 2 + 3 = 6
}

///|
test "a_star pathfinding" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")
  let n3 = g.add_node("D")

  let _ = g.add_edge(n0, n1, 2)
  let _ = g.add_edge(n1, n3, 5)
  let _ = g.add_edge(n0, n2, 1)
  let _ = g.add_edge(n2, n3, 3)

  // Heuristic: estimated cost to D
  let heuristic = fn(node : NodeIndex) -> Int {
    if node.val == n0.val {
      4
    } else if node.val == n1.val {
      3
    } else if node.val == n2.val {
      2
    } else {
      0
    }
  }

  let path_opt = g.a_star(n0, n3, heuristic)
  assert_true(path_opt is Some(_))
  let path = path_opt.unwrap()
  assert_eq(path.length(), 3)
  assert_eq(path[0].val, n0.val)
  assert_eq(path[1].val, n2.val)
  assert_eq(path[2].val, n3.val)
}

///|
test "bellman_ford negative weights" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")

  let _ = g.add_edge(n0, n1, 4)
  let _ = g.add_edge(n0, n2, 5)
  let _ = g.add_edge(n2, n1, -2) // Negative edge weight

  let res = g.bellman_ford(n0)
  assert_true(res is Ok(_))
  let dists = res.unwrap()
  assert_eq(dists[n0.val], 0)
  assert_eq(dists[n2.val], 5)
  assert_eq(dists[n1.val], 3) // A -> C -> B = 5 - 2 = 3

  // Add negative cycle
  let _ = g.add_edge(n1, n2, -1) // Cycle C -> B -> C weight is -2 + -1 = -3
  let res_cycle = g.bellman_ford(n0)
  assert_true(res_cycle is Err(_))
}

///|
test "kruskal minimum spanning tree" {
  let g : Graph[String, Int] = Graph::new(directed=false)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")

  let _ = g.add_edge(n0, n1, 10)
  let _ = g.add_edge(n1, n2, 5)
  let _ = g.add_edge(n0, n2, 15)

  let mst = g.kruskal_mst()
  assert_eq(mst.length(), 2) // For 3 nodes, MST has 2 edges
}

///|
test "topological sort" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")

  let _ = g.add_edge(n0, n1, 1)
  let _ = g.add_edge(n1, n2, 1)

  let sort_opt = g.topological_sort()
  assert_true(sort_opt is Some(_))
  let sorted = sort_opt.unwrap()
  assert_eq(sorted[0].val, n0.val)
  assert_eq(sorted[1].val, n1.val)
  assert_eq(sorted[2].val, n2.val)

  // Add a cycle to make topological sort fail
  let _ = g.add_edge(n2, n0, 1)
  let sort_cycle = g.topological_sort()
  assert_true(sort_cycle is None)
}

///|
test "tarjan strongly connected components" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let n2 = g.add_node("C")
  let n3 = g.add_node("D")

  let _ = g.add_edge(n0, n1, 1)
  let _ = g.add_edge(n1, n2, 1)
  let _ = g.add_edge(n2, n0, 1) // SCC: {A, B, C}
  let _ = g.add_edge(n2, n3, 1) // D is outside

  let sccs = g.tarjan_scc()
  assert_eq(sccs.length(), 2)
}

///|
test "cycle detection" {
  let gd : Graph[String, Int] = Graph::new(directed=true)
  let n0 = gd.add_node("A")
  let n1 = gd.add_node("B")
  let _ = gd.add_edge(n0, n1, 1)
  assert_eq(gd.has_cycle(), false)

  let _ = gd.add_edge(n1, n0, 1)
  assert_eq(gd.has_cycle(), true)

  let gu : Graph[String, Int] = Graph::new(directed=false)
  let u0 = gu.add_node("A")
  let u1 = gu.add_node("B")
  let u2 = gu.add_node("C")
  let _ = gu.add_edge(u0, u1, 1)
  let _ = gu.add_edge(u1, u2, 1)
  assert_eq(gu.has_cycle(), false)

  let _ = gu.add_edge(u2, u0, 1)
  assert_eq(gu.has_cycle(), true)
}

///|
test "export graphviz dot" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let _ = g.add_edge(n0, n1, 10)

  let dot = g.to_dot(fn(n) { n }, fn(e) { e.to_string() })
  assert_eq(dot.contains("digraph G"), true)
  assert_eq(dot.contains("0 -> 1"), true)
}

///|
test "public graph inspection and invalid edges are safe" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let n0 = g.add_node("A")
  let n1 = g.add_node("B")
  let e0 = g.add_edge(n0, n1, 3)

  assert_eq(n0.value(), 0)
  assert_eq(e0.value(), 0)
  assert_eq(g.directed(), true)
  assert_eq(g.node_indices().length(), 2)
  assert_eq(g.out_degree(n0), 1)
  assert_eq(g.in_degree(n1), 1)
  assert_eq(g.has_edge(n0, n1), true)
  assert_eq(g.has_edge(n1, n0), false)
  assert_eq(g.contains_node(n1), true)
  assert_eq(g.contains_edge(e0), true)
  let invalid_node = NodeIndex::new(99)
  let invalid_edge = EdgeIndex::new(99)
  assert_true(g.node_weight(invalid_node) is None)
  assert_true(g.edge_weight(invalid_edge) is None)
  assert_eq(g.add_edge(n0, invalid_node, 1).value(), -1)
}

///|
test "weak components and transitive closure" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let d = g.add_node("D")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(c, b, 1)

  let components = g.weakly_connected_components()
  assert_eq(components.length(), 2)
  let closure = g.transitive_closure()
  assert_eq(closure[a.value()][a.value()], true)
  assert_eq(closure[a.value()][b.value()], true)
  assert_eq(closure[b.value()][a.value()], false)
  assert_eq(closure[d.value()][d.value()], true)
}

///|
test "floyd warshall preserves shortest paths and infinity" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let d = g.add_node("D")
  let _ = g.add_edge(a, b, 9)
  let _ = g.add_edge(a, b, 2)
  let _ = g.add_edge(b, c, 4)

  let distances = g.floyd_warshall()
  assert_eq(distances[a.value()][a.value()], 0)
  assert_eq(distances[a.value()][b.value()], 2)
  assert_eq(distances[a.value()][c.value()], 6)
  assert_eq(distances[a.value()][d.value()], 2147483647)
}

///|
test "greedy coloring and low link analysis" {
  let g : Graph[String, Int] = Graph::new(directed=false)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let d = g.add_node("D")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, a, 1)
  let _ = g.add_edge(b, d, 1)

  let colors = g.greedy_coloring()
  assert_true(colors[a.value()] != colors[b.value()])
  assert_true(colors[b.value()] != colors[c.value()])
  assert_true(colors[c.value()] != colors[a.value()])
  let points = g.articulation_points()
  assert_eq(points.length(), 1)
  assert_eq(points[0].value(), b.value())
  let bridges = g.bridges()
  assert_eq(bridges.length(), 1)
  assert_eq(bridges[0][0].value(), b.value())
  assert_eq(bridges[0][1].value(), d.value())
}

///|
test "dag longest paths reject cycles" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let _ = g.add_edge(a, b, 3)
  let _ = g.add_edge(a, c, 2)
  let _ = g.add_edge(b, c, 4)
  let distances = g.dag_longest_paths(a).unwrap()
  assert_eq(distances[a.value()], 0)
  assert_eq(distances[b.value()], 3)
  assert_eq(distances[c.value()], 7)
  let _ = g.add_edge(c, a, 1)
  assert_true(g.dag_longest_paths(a) is None)
}

///|
test "edmonds karp max flow aggregates capacities" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let s = g.add_node("s")
  let a = g.add_node("a")
  let b = g.add_node("b")
  let t = g.add_node("t")
  let _ = g.add_edge(s, a, 10)
  let _ = g.add_edge(s, a, 3)
  let _ = g.add_edge(s, b, 10)
  let _ = g.add_edge(a, b, 4)
  let _ = g.add_edge(a, t, 13)
  let _ = g.add_edge(b, t, 10)

  match g.max_flow(s, t) {
    Ok(value) => assert_eq(value, 23)
    Err(_) => assert_true(false)
  }
}

///|
test "max flow reports unsupported input" {
  let g : Graph[String, Int] = Graph::new(directed=false)
  let s = g.add_node("s")
  let t = g.add_node("t")
  let _ = g.add_edge(s, t, 1)
  assert_true(g.max_flow(s, t) is Err(_))
  match g.max_flow(NodeIndex::new(99), t) {
    Err(message) => assert_eq(message, "source or sink is out of range")
    Ok(_) => assert_true(false)
  }
}

///|
test "shortest path reconstructs node sequence" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let d = g.add_node("D")
  let _ = g.add_edge(a, b, 2)
  let _ = g.add_edge(b, c, 2)
  let _ = g.add_edge(a, d, 1)
  let _ = g.add_edge(d, c, 8)
  let path = g.shortest_path(a, c).unwrap()
  assert_eq(path.length(), 3)
  assert_eq(path[0].value(), a.value())
  assert_eq(path[1].value(), b.value())
  assert_eq(path[2].value(), c.value())
  assert_true(g.shortest_path(c, NodeIndex::new(99)) is None)
}

///|
test "topological layers group independent work" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let fetch = g.add_node("fetch")
  let parse = g.add_node("parse")
  let compile = g.add_node("compile")
  let link = g.add_node("link")
  let _ = g.add_edge(fetch, parse, 1)
  let _ = g.add_edge(parse, compile, 1)
  let _ = g.add_edge(compile, link, 1)
  let layers = g.topological_layers().unwrap()
  assert_eq(layers.length(), 4)
  assert_eq(layers[0].length(), 1)
  assert_eq(layers[0][0].value(), fetch.value())
  assert_eq(layers[3][0].value(), link.value())
}

///|
test "bipartite matching returns maximum pairs" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let l0 = g.add_node("l0")
  let l1 = g.add_node("l1")
  let r0 = g.add_node("r0")
  let r1 = g.add_node("r1")
  let _ = g.add_edge(l0, r0, 1)
  let _ = g.add_edge(l0, r1, 1)
  let _ = g.add_edge(l1, r0, 1)
  let pairs = g.maximum_bipartite_matching([l0, l1], [r0, r1])
  assert_eq(pairs.length(), 2)
}

///|
test "eulerian trail uses every directed edge exactly once" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, a, 1)
  let trail = g.eulerian_trail().unwrap()
  assert_eq(trail.length(), 4)
  assert_eq(trail[0].value(), trail[3].value())
  assert_true(g.eulerian_trail_for(NodeIndex::new(99)) is None)
}

///|
test "prim returns a minimum spanning forest" {
  let g : Graph[String, Int] = Graph::new(directed=false)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let d = g.add_node("D")
  let e0 = g.add_edge(a, b, 4)
  let _ = g.add_edge(a, c, 1)
  let e2 = g.add_edge(c, b, 2)
  let e3 = g.add_edge(b, d, 3)
  let _ = g.add_edge(c, d, 8)
  let forest = g.prim_mst()
  assert_eq(forest.length(), 3)
  let mut total = 0
  for i = 0; i < forest.length(); i = i + 1 {
    total = total + g.edge_weight(forest[i]).unwrap()
  }
  assert_eq(total, 6)
  assert_true(g.contains_edge(e0))
  assert_true(g.contains_edge(e2))
  assert_true(g.contains_edge(e3))
}

///|
test "graph statistics distances and bipartite boundaries" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let d = g.add_node("D")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, c, 1)
  let stats = g.stats()
  assert_eq(stats.node_count(), 4)
  assert_eq(stats.edge_count(), 3)
  assert_eq(stats.self_loops(), 1)
  assert_eq(stats.isolated_nodes(), 1)
  assert_eq(g.bfs_distances(a)[c.value()], 2)
  assert_eq(g.bfs_distances(a)[d.value()], 2147483647)
  assert_eq(g.density_scaled(), 250000)
  assert_eq(g.is_bipartite(), false)
  assert_eq(g.has_self_loop(), true)
}

///|
test "undirected graph statistics and degree histogram" {
  let g : Graph[Int, Int] = Graph::new(directed=false)
  let a = g.add_node(0)
  let b = g.add_node(1)
  let c = g.add_node(2)
  let d = g.add_node(3)
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, d, 1)
  let histogram = g.degree_histogram()
  assert_eq(histogram[1], 2)
  assert_eq(histogram[2], 2)
  assert_eq(g.is_bipartite(), true)
  assert_eq(g.density_scaled(), 500000)
}

///|
test "transpose induced subgraph and edge list preserve weights" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let _ = g.add_edge(a, b, 7)
  let _ = g.add_edge(b, c, 9)
  let reversed = g.transpose()
  assert_eq(reversed.has_edge(b, a), true)
  assert_eq(reversed.has_edge(c, b), true)
  let sub = g.induced_subgraph([a, b])
  assert_eq(sub.node_count(), 2)
  assert_eq(sub.edge_count(), 1)
  assert_eq(sub.original_nodes().length(), 2)
  let edges = g.edge_list()
  assert_eq(edges.length(), 2)
  let weighted = g.weighted_edge_list()
  assert_eq(weighted[0].2, 7)
  assert_eq(weighted[1].2, 9)
}

///|
test "pagerank and ranking are deterministic" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("hub")
  let b = g.add_node("left")
  let c = g.add_node("right")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(a, c, 1)
  let _ = g.add_edge(b, c, 1)
  let scores = g.pagerank_scaled(iterations=30)
  let total = scores[0] + scores[1] + scores[2]
  assert_true(total >= 999990 && total <= 1000010)
  let order = g.pagerank_order(iterations=30)
  assert_eq(order[2].value(), c.value())
}

///|
test "triangle and k core analysis handles sparse boundaries" {
  let g : Graph[Int, Int] = Graph::new(directed=false)
  let a = g.add_node(0)
  let b = g.add_node(1)
  let c = g.add_node(2)
  let d = g.add_node(3)
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, a, 1)
  let _ = g.add_edge(c, d, 1)
  assert_eq(g.triangle_count(), 1)
  assert_eq(g.local_clustering_scaled(a), 1000000)
  let cores = g.k_core_numbers()
  assert_eq(cores[a.value()], 2)
  assert_eq(cores[d.value()], 1)
  assert_eq(g.k_core(2).length(), 3)
  assert_eq(g.k_core(0).length(), 4)
}

///|
test "dependency planner produces critical path and rejects invalid plans" {
  let tasks = [
    Task::new("fetch", 2),
    Task::new("parse", 3),
    Task::new("compile", 5),
    Task::new("package", 2),
  ]
  let deps = [[], [0], [1], [2]]
  let graph = build_dependency_graph(tasks, deps).unwrap()
  let plan = schedule_tasks(graph).unwrap()
  assert_eq(plan.makespan(), 12)
  assert_eq(plan.finish_times()[3], 12)
  assert_eq(plan.order().length(), 4)
  let cyclic = build_dependency_graph([Task::new("a", 1), Task::new("b", 1)], [
    [1],
    [0],
  ]).unwrap()
  match schedule_tasks(cyclic) {
    Err(message) => assert_eq(message, "dependency graph contains a cycle")
    Ok(_) => assert_true(false)
  }
  match build_dependency_graph([Task::new("bad", -1)], [[]]) {
    Err(message) => assert_eq(message, "task duration cannot be negative")
    Ok(_) => assert_true(false)
  }
}

///|
test "dependency planner schedules parallel branches" {
  let tasks = [
    Task::new("root", 2),
    Task::new("lint", 3),
    Task::new("tests", 5),
    Task::new("release", 1),
  ]
  let graph = build_dependency_graph(tasks, [[], [0], [0], [1, 2]]).unwrap()
  let plan = schedule_tasks(graph).unwrap()
  assert_eq(plan.makespan(), 8)
  assert_eq(plan.start_times()[1], 2)
  assert_eq(plan.start_times()[2], 2)
  assert_eq(plan.start_times()[3], 7)
}

///|
test "condensation graph contracts strongly connected components" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("a")
  let b = g.add_node("b")
  let c = g.add_node("c")
  let d = g.add_node("d")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, a, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, d, 1)
  let _ = g.add_edge(d, c, 1)
  let condensation = g.condensation()
  assert_eq(condensation.component_count(), 2)
  assert_eq(condensation.graph().edge_count(), 1)
  assert_eq(condensation.component_of(a), condensation.component_of(b))
  assert_eq(condensation.component_of(a) != condensation.component_of(c), true)
  assert_eq(condensation.components().length(), 2)
}

///|
test "minimum cut reports reachable side and capacity" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let s = g.add_node("s")
  let a = g.add_node("a")
  let b = g.add_node("b")
  let t = g.add_node("t")
  let _ = g.add_edge(s, a, 3)
  let _ = g.add_edge(s, b, 2)
  let _ = g.add_edge(a, t, 2)
  let _ = g.add_edge(b, t, 2)
  let _ = g.add_edge(a, b, 1)
  let cut = g.min_cut(s, t).unwrap()
  assert_eq(cut.value(), 4)
  assert_true(cut.source_side().contains(s))
  assert_true(!cut.source_side().contains(t))
  assert_eq(cut.cut_edges().length(), 2)
}

///|
test "network metrics handle paths, isolated nodes, and reciprocity" {
  let g : Graph[Int, Int] = Graph::new(directed=true)
  let a = g.add_node(0)
  let b = g.add_node(1)
  let c = g.add_node(2)
  let d = g.add_node(3)
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, b, 1)
  let distances = g.average_shortest_path_scaled()
  assert_true(distances > 1200000 && distances < 1400000)
  assert_eq(g.diameter(), 2)
  let centrality = g.degree_centrality_scaled()
  assert_eq(centrality[b.value()], 666666)
  assert_eq(g.bfs_distances(d)[d.value()], 0)
  assert_eq(g.reciprocity_scaled(), 666666)
  assert_eq(g.component_sizes().length(), 2)
  assert_eq(g.component_sizes()[0], 3)
  assert_eq(g.component_sizes()[1], 1)
}

///|
test "transitive reduction keeps only necessary dependency edges" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("a")
  let b = g.add_node("b")
  let c = g.add_node("c")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(a, c, 1)
  let reduced = g.transitive_reduction().unwrap()
  assert_eq(reduced.edge_count(), 2)
  assert_eq(reduced.has_edge(a, b), true)
  assert_eq(reduced.has_edge(b, c), true)
  assert_eq(reduced.has_edge(a, c), false)
  match g.count_paths(a, c) {
    Ok(value) => assert_eq(value, 2)
    Err(_) => assert_true(false)
  }
  let _ = g.add_edge(c, a, 1)
  assert_true(g.transitive_reduction() is Err(_))
  assert_true(g.count_paths(a, c) is Err(_))
}

///|
test "simple graph constraints detect parallel edges and loops" {
  let g : Graph[Int, Int] = Graph::new(directed=true)
  let a = g.add_node(0)
  let b = g.add_node(1)
  let _ = g.add_edge(a, b, 1)
  assert_eq(g.edge_multiplicity(a, b), 1)
  assert_eq(g.is_simple(), true)
  let _ = g.add_edge(a, b, 2)
  assert_eq(g.edge_multiplicity(a, b), 2)
  assert_eq(g.has_parallel_edges(), true)
  assert_eq(g.is_simple(), false)
  let _ = g.add_edge(b, b, 3)
  assert_eq(g.has_self_loop(), true)
  assert_eq(g.is_simple(), false)
  match g.validate() {
    Ok(_) => assert_true(true)
    Err(_) => assert_true(false)
  }
}

///|
test "tree and forest predicates support disconnected graphs" {
  let tree : Graph[Int, Int] = Graph::new(directed=false)
  let a = tree.add_node(0)
  let b = tree.add_node(1)
  let c = tree.add_node(2)
  let d = tree.add_node(3)
  let _ = tree.add_edge(a, b, 1)
  let _ = tree.add_edge(b, c, 1)
  let _ = tree.add_edge(c, d, 1)
  assert_eq(tree.is_tree(), true)
  assert_eq(tree.is_forest(), true)
  assert_eq(tree.connected_pair_count(), 6)
  let _ = tree.add_node(4)
  assert_eq(tree.is_tree(), false)
  assert_eq(tree.is_forest(), true)

  let cycle : Graph[Int, Int] = Graph::new(directed=false)
  let x = cycle.add_node(0)
  let y = cycle.add_node(1)
  let z = cycle.add_node(2)
  let _ = cycle.add_edge(x, y, 1)
  let _ = cycle.add_edge(y, z, 1)
  let _ = cycle.add_edge(z, x, 1)
  assert_eq(cycle.is_forest(), false)
}

///|
test "routing table reconstructs shortest routes and handles unreachable nodes" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("a")
  let b = g.add_node("b")
  let c = g.add_node("c")
  let d = g.add_node("d")
  let _ = g.add_edge(a, b, 2)
  let _ = g.add_edge(b, c, 3)
  let _ = g.add_edge(a, c, 9)
  let table = build_route_table(g, a)
  assert_eq(table.distance(c), 5)
  assert_eq(table.route_to(c).length(), 3)
  assert_eq(table.route_to(c)[1].value(), b.value())
  assert_true(table.route_to(d).length() == 0)
}

///|
test "widest path and multi-source distances support network failover" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("a")
  let b = g.add_node("b")
  let c = g.add_node("c")
  let d = g.add_node("d")
  let _ = g.add_edge(a, b, 4)
  let _ = g.add_edge(a, c, 7)
  let _ = g.add_edge(b, d, 5)
  let _ = g.add_edge(c, d, 3)
  let capacity = g.widest_path_capacities(a)
  assert_eq(capacity[d.value()], 4)
  let distances = g.multi_source_bfs_distances([b, c])
  assert_eq(distances[a.value()], 2147483647)
  assert_eq(distances[d.value()], 1)
  assert_eq(g.k_hop_neighborhood(a, 1).length(), 3)
}

///|
test "deterministic walk sampling stays within graph and counts visits" {
  let g : Graph[Int, Int] = Graph::new(directed=false)
  let a = g.add_node(0)
  let b = g.add_node(1)
  let c = g.add_node(2)
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let trace = g.random_walk(a, 20, 17)
  assert_eq(trace.length(), 21)
  assert_true(trace.unique_nodes().length() >= 2)
  assert_true(trace.unique_nodes().length() <= 3)
  assert_eq(trace.visit_counts().length(), 3)
  assert_eq(trace.return_probability_scaled() >= 0, true)
  assert_eq(g.random_walk(NodeIndex::new(99), 5, 1).length(), 0)
}

///|
test "adjacency matrix and csr compression preserve topology" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("a")
  let b = g.add_node("b")
  let c = g.add_node("c")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(a, c, 2)
  let _ = g.add_edge(c, b, 3)
  let matrix = g.adjacency_matrix()
  assert_eq(matrix.length(), 9)
  assert_eq(matrix[a.value() * 3 + b.value()], 1)
  assert_eq(matrix[b.value() * 3 + a.value()], 0)
  let csr = g.to_csr()
  assert_eq(csr.row_count(), 3)
  assert_eq(csr.edge_count(), 3)
  assert_eq(csr.row_degree(a.value()), 2)
  assert_eq(csr.max_row_degree(), 2)
  assert_eq(csr.contains_edge(a.value(), b.value()), true)
  assert_eq(csr.contains_edge(99, b.value()), false)
  assert_eq(csr.neighbors(a.value()).length(), 2)
  assert_eq(csr.neighbors(99).length(), 0)
  assert_eq(g.adjacency_matrix_size(), 9)
}

///|
test "shortest path counts and eccentricities handle a diamond" {
  let g : Graph[Int, Int] = Graph::new(directed=true)
  let s = g.add_node(0)
  let a = g.add_node(1)
  let b = g.add_node(2)
  let t = g.add_node(3)
  let _ = g.add_edge(s, a, 1)
  let _ = g.add_edge(s, b, 1)
  let _ = g.add_edge(a, t, 1)
  let _ = g.add_edge(b, t, 1)
  let counts = g.shortest_path_counts(s)
  assert_eq(counts[s.value()], 1)
  assert_eq(counts[a.value()], 1)
  assert_eq(counts[b.value()], 1)
  assert_eq(counts[t.value()], 2)
  let eccentricities = g.eccentricities()
  assert_eq(eccentricities[s.value()], 2)
  assert_eq(eccentricities[t.value()], 0)
  assert_eq(g.shortest_path_counts(NodeIndex::new(99)).length(), 4)
}

///|
test "centrality and degree sequence expose useful graph summaries" {
  let g : Graph[Int, Int] = Graph::new(directed=false)
  let a = g.add_node(0)
  let b = g.add_node(1)
  let c = g.add_node(2)
  let d = g.add_node(3)
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(a, c, 1)
  let _ = g.add_edge(a, d, 1)
  let degrees = g.degree_sequence()
  assert_eq(degrees[0], 3)
  assert_eq(degrees[3], 1)
  let closeness = g.closeness_centrality_scaled()
  assert_true(closeness[a.value()] > closeness[b.value()])
  assert_eq(g.closeness_centrality(NodeIndex::new(99)), 0)
  assert_eq(g.degree_sum(), 6)
  assert_eq(g.is_regular(), false)
  assert_eq(g.finite_reachability_counts()[a.value()], 4)
  assert_eq(g.has_edge_between_sets([a], [b]), true)
  assert_eq(g.edge_boundary_count([b], [a]), 1)
}

///|
test "edge boundary filters direction and reports invalid masks" {
  let g : Graph[String, Int] = Graph::new(directed=true)
  let a = g.add_node("a")
  let b = g.add_node("b")
  let c = g.add_node("c")
  let _ = g.add_edge(a, b, 1)
  let _ = g.add_edge(b, c, 1)
  let _ = g.add_edge(c, a, 1)
  let boundary = g.edge_boundary([a], [b, c])
  assert_eq(boundary.length(), 1)
  assert_eq(boundary[0].0.value(), a.value())
  assert_eq(boundary[0].1.value(), b.value())
  assert_true(g.edge_boundary([a], [a]).length() == 0)
  match g.adjacency_matrix_checked([true, false]) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}
