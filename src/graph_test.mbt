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
  assert_eq(g.node_weight(invalid_node), None)
  assert_eq(g.edge_weight(invalid_edge), None)
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
  assert_eq(g.dag_longest_paths(a), None)
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

  assert_eq(g.max_flow(s, t), Ok(23))
}

///|
test "max flow reports unsupported input" {
  let g : Graph[String, Int] = Graph::new(directed=false)
  let s = g.add_node("s")
  let t = g.add_node("t")
  let _ = g.add_edge(s, t, 1)
  assert_true(g.max_flow(s, t) is Err(_))
  assert_eq(
    g.max_flow(NodeIndex::new(99), t),
    Err("source or sink is out of range"),
  )
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
  assert_eq(g.shortest_path(c, NodeIndex::new(99)), None)
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
  assert_eq(g.eulerian_trail_for(NodeIndex::new(99)), None)
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
