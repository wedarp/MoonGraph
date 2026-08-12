///|
fn add_karate_edges(
  graph : @moongraph.Graph[String, Int],
  edges : Array[(Int, Int)],
) -> Unit {
  for i = 0; i < 34; i = i + 1 {
    let _ = graph.add_node("member-\{i + 1}")
  }
  for i = 0; i < edges.length(); i = i + 1 {
    let edge = edges[i]
    let _ = graph.add_edge(
      @moongraph.NodeIndex::new(edge.0),
      @moongraph.NodeIndex::new(edge.1),
      1,
    )
  }
}

///|
fn karate_club() -> @moongraph.Graph[String, Int] {
  let graph : @moongraph.Graph[String, Int] = @moongraph.Graph::new(
    directed=false,
  )
  let edges = [
    (0, 1),
    (0, 2),
    (0, 3),
    (0, 4),
    (0, 5),
    (0, 6),
    (0, 7),
    (0, 8),
    (0, 10),
    (0, 11),
    (0, 12),
    (0, 13),
    (0, 17),
    (0, 19),
    (0, 21),
    (0, 31),
    (1, 2),
    (1, 3),
    (1, 7),
    (1, 13),
    (1, 17),
    (1, 19),
    (1, 21),
    (1, 30),
    (2, 3),
    (2, 7),
    (2, 8),
    (2, 9),
    (2, 13),
    (2, 27),
    (2, 28),
    (2, 32),
    (3, 7),
    (3, 12),
    (3, 13),
    (4, 6),
    (4, 10),
    (5, 6),
    (5, 10),
    (5, 16),
    (6, 16),
    (8, 30),
    (8, 32),
    (8, 33),
    (9, 33),
    (13, 33),
    (14, 32),
    (14, 33),
    (15, 32),
    (15, 33),
    (18, 32),
    (18, 33),
    (19, 33),
    (20, 32),
    (20, 33),
    (22, 32),
    (22, 33),
    (23, 25),
    (23, 27),
    (23, 29),
    (23, 32),
    (23, 33),
    (24, 25),
    (24, 27),
    (24, 31),
    (25, 31),
    (26, 29),
    (26, 33),
    (27, 33),
    (28, 31),
    (28, 33),
    (29, 32),
    (29, 33),
    (30, 32),
    (30, 33),
    (31, 32),
    (31, 33),
    (32, 33),
  ]
  add_karate_edges(graph, edges)
  graph
}

///|
fn sparse_network(node_count : Int) -> @moongraph.Graph[Int, Int] {
  let graph : @moongraph.Graph[Int, Int] = @moongraph.Graph::new(directed=true)
  for i = 0; i < node_count; i = i + 1 {
    let _ = graph.add_node(i)
  }
  for i = 0; i < node_count; i = i + 1 {
    let next = (i + 1) % node_count
    let jump = (i + 37) % node_count
    let _ = graph.add_edge(
      @moongraph.NodeIndex::new(i),
      @moongraph.NodeIndex::new(next),
      1,
    )
    if i % 5 == 0 {
      let _ = graph.add_edge(
        @moongraph.NodeIndex::new(i),
        @moongraph.NodeIndex::new(jump),
        2,
      )
    }
  }
  graph
}

///|
fn dependency_benchmark() -> Result[@moongraph.TaskPlan, String] {
  let tasks = [
    @moongraph.Task::new("fetch", 2),
    @moongraph.Task::new("lex", 3),
    @moongraph.Task::new("parse", 5),
    @moongraph.Task::new("typecheck", 8),
    @moongraph.Task::new("lower", 4),
    @moongraph.Task::new("optimize", 6),
    @moongraph.Task::new("codegen", 7),
    @moongraph.Task::new("package", 2),
    @moongraph.Task::new("unit-tests", 5),
    @moongraph.Task::new("integration-tests", 6),
    @moongraph.Task::new("sign", 1),
    @moongraph.Task::new("publish", 1),
  ]
  let deps = [[], [0], [1], [2], [3], [4], [5], [6], [3], [8, 7], [9], [10]]
  @moongraph.build_dependency_graph(tasks, deps).map(fn(graph) {
    @moongraph.schedule_tasks(graph).unwrap()
  })
}

///|
fn print_karate_report() -> Unit {
  let graph = karate_club()
  let stats = graph.stats()
  let scores = graph.pagerank_scaled(iterations=40)
  let ranking = graph.pagerank_order(iterations=40)
  println("dataset,karate_club")
  println("nodes,\{stats.node_count()}")
  println("undirected_edges,\{stats.edge_count() / 2}")
  println("triangles,\{graph.triangle_count()}")
  println("components,\{stats.weak_components()}")
  println("diameter,\{graph.diameter()}")
  println("average_distance_scaled,\{graph.average_shortest_path_scaled()}")
  println("top_pagerank_node,\{ranking[0].value() + 1}")
  println("top_pagerank_score_scaled,\{scores[ranking[0].value()]}")
}

///|
fn print_dependency_report() -> Unit {
  match dependency_benchmark() {
    Err(message) => println("dependency_error,\{message}")
    Ok(plan) => {
      println("dataset,compiler_pipeline")
      println("tasks,\{plan.order().length()}")
      println("makespan,\{plan.makespan()}")
      println("critical_path_length,\{plan.critical_path().length()}")
    }
  }
}

///|
fn print_sparse_report() -> Unit {
  let graph = sparse_network(500)
  let stats = graph.stats()
  let distances = graph.bfs_distances(@moongraph.NodeIndex::new(0))
  let reachable = graph.reachable_from(@moongraph.NodeIndex::new(0))
  println("dataset,sparse_500")
  println("nodes,\{stats.node_count()}")
  println("edges,\{stats.edge_count()}")
  println("reachable_from_zero,\{reachable.length()}")
  println("diameter,\{graph.diameter()}")
  println("distance_to_499,\{distances[499]}")
  println("density_scaled,\{graph.density_scaled()}")
}

///|
fn main {
  println("MoonGraph reproducible benchmark suite")
  print_karate_report()
  print_dependency_report()
  print_sparse_report()
}
