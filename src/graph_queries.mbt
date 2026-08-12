///|
/// A compact, deterministic summary of a graph for diagnostics and benchmarks.
pub struct GraphStats {
  node_count : Int
  edge_count : Int
  isolated_nodes : Int
  self_loops : Int
  max_out_degree : Int
  max_in_degree : Int
  weak_components : Int
}

///|
pub fn GraphStats::node_count(self : GraphStats) -> Int {
  self.node_count
}

///|
pub fn GraphStats::edge_count(self : GraphStats) -> Int {
  self.edge_count
}

///|
pub fn GraphStats::isolated_nodes(self : GraphStats) -> Int {
  self.isolated_nodes
}

///|
pub fn GraphStats::self_loops(self : GraphStats) -> Int {
  self.self_loops
}

///|
pub fn GraphStats::max_out_degree(self : GraphStats) -> Int {
  self.max_out_degree
}

///|
pub fn GraphStats::max_in_degree(self : GraphStats) -> Int {
  self.max_in_degree
}

///|
pub fn GraphStats::weak_components(self : GraphStats) -> Int {
  self.weak_components
}

///|
/// Returns a graph summary without allocating a copy of the graph.
pub fn[N, E] Graph::stats(self : Graph[N, E]) -> GraphStats {
  let mut isolated = 0
  let mut self_loops = 0
  let mut max_out = 0
  let mut max_in = 0
  for i = 0; i < self.node_count(); i = i + 1 {
    let node = NodeIndex::{ val: i }
    let out = self.out_degree(node)
    let incoming = self.in_degree(node)
    if out == 0 && incoming == 0 {
      isolated = isolated + 1
    }
    if out > max_out {
      max_out = out
    }
    if incoming > max_in {
      max_in = incoming
    }
    let neighbors = self.neighbors(node)
    for j = 0; j < neighbors.length(); j = j + 1 {
      if neighbors[j].val == i {
        self_loops = self_loops + 1
      }
    }
  }
  {
    node_count: self.node_count(),
    edge_count: self.edge_count(),
    isolated_nodes: isolated,
    self_loops,
    max_out_degree: max_out,
    max_in_degree: max_in,
    weak_components: self.weakly_connected_components().length(),
  }
}

///|
/// Computes unweighted shortest hop distances from a source node.
/// Unreachable nodes are reported as `2147483647`.
pub fn[N, E] Graph::bfs_distances(
  self : Graph[N, E],
  start : NodeIndex,
) -> Array[Int] {
  let distances = Array::make(self.node_count(), 2147483647)
  if !self.contains_node(start) {
    return distances
  }
  distances[start.val] = 0
  let queue = [start]
  let mut head = 0
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    let neighbors = self.neighbors(current)
    for i = 0; i < neighbors.length(); i = i + 1 {
      let next = neighbors[i]
      if distances[next.val] == 2147483647 {
        distances[next.val] = distances[current.val] + 1
        queue.push(next)
      }
    }
  }
  distances
}

///|
/// Returns the nodes reachable from `start` in BFS order.
pub fn[N, E] Graph::reachable_from(
  self : Graph[N, E],
  start : NodeIndex,
) -> Array[NodeIndex] {
  if !self.contains_node(start) {
    return []
  }
  let distances = self.bfs_distances(start)
  let result = []
  for i = 0; i < distances.length(); i = i + 1 {
    if distances[i] != 2147483647 {
      result.push(NodeIndex::{ val: i })
    }
  }
  result
}

///|
/// Returns whether the graph has at least one self-loop.
pub fn[N, E] Graph::has_self_loop(self : Graph[N, E]) -> Bool {
  for i = 0; i < self.node_count(); i = i + 1 {
    if self.has_edge(NodeIndex::{ val: i }, NodeIndex::{ val: i }) {
      return true
    }
  }
  false
}

///|
/// Returns density scaled by one million to keep the API backend independent.
/// For undirected graphs the duplicated adjacency entries are normalized.
pub fn[N, E] Graph::density_scaled(self : Graph[N, E]) -> Int {
  let n = self.node_count()
  if n < 2 {
    return 0
  }
  let possible = if self.directed() { n * (n - 1) } else { n * (n - 1) / 2 }
  let actual = if self.directed() {
    self.edge_count()
  } else {
    self.edge_count() / 2
  }
  actual * 1000000 / possible
}

///|
/// Returns a histogram where index `d` stores the number of nodes of degree `d`.
/// Degree means outgoing degree for directed graphs and adjacency degree otherwise.
pub fn[N, E] Graph::degree_histogram(self : Graph[N, E]) -> Array[Int] {
  let mut max_degree = 0
  for i = 0; i < self.node_count(); i = i + 1 {
    let degree = self.out_degree(NodeIndex::{ val: i })
    if degree > max_degree {
      max_degree = degree
    }
  }
  let histogram = Array::make(max_degree + 1, 0)
  for i = 0; i < self.node_count(); i = i + 1 {
    let degree = self.out_degree(NodeIndex::{ val: i })
    histogram[degree] = histogram[degree] + 1
  }
  histogram
}

///|
/// Tests bipartiteness using the underlying undirected adjacency relation.
pub fn[N, E] Graph::is_bipartite(self : Graph[N, E]) -> Bool {
  let colors = Array::make(self.node_count(), -1)
  for root = 0; root < self.node_count(); root = root + 1 {
    if colors[root] != -1 {
      continue
    }
    colors[root] = 0
    let queue = [NodeIndex::{ val: root }]
    let mut head = 0
    while head < queue.length() {
      let current = queue[head]
      head = head + 1
      let neighbors = self.underlying_neighbors(current)
      for i = 0; i < neighbors.length(); i = i + 1 {
        let next = neighbors[i]
        if next.val == current.val {
          return false
        }
        if colors[next.val] == -1 {
          colors[next.val] = 1 - colors[current.val]
          queue.push(next)
        } else if colors[next.val] == colors[current.val] {
          return false
        }
      }
    }
  }
  true
}

///|
fn[N, E] Graph::underlying_neighbors(
  self : Graph[N, E],
  node : NodeIndex,
) -> Array[NodeIndex] {
  let result = self.neighbors(node)
  if self.directed() {
    for i = 0; i < self.node_count(); i = i + 1 {
      let candidate = NodeIndex::{ val: i }
      let outgoing = self.neighbors(candidate)
      for j = 0; j < outgoing.length(); j = j + 1 {
        if outgoing[j].val == node.val &&
          !contains_node_index(result, candidate) {
          result.push(candidate)
        }
      }
    }
  }
  result
}

///|
fn contains_node_index(nodes : Array[NodeIndex], target : NodeIndex) -> Bool {
  for i = 0; i < nodes.length(); i = i + 1 {
    if nodes[i].val == target.val {
      return true
    }
  }
  false
}
