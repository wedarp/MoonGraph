///|
/// Counts undirected triangles. Directed graphs use their underlying adjacency.
pub fn[N, E] Graph::triangle_count(self : Graph[N, E]) -> Int {
  if self.node_count() < 3 {
    return 0
  }
  let mut triangles = 0
  for u = 0; u < self.node_count(); u = u + 1 {
    let neighbors = self.underlying_neighbors(NodeIndex::{ val: u })
    for i = 0; i < neighbors.length(); i = i + 1 {
      for j = i + 1; j < neighbors.length(); j = j + 1 {
        if self.has_edge(neighbors[i], neighbors[j]) ||
          self.has_edge(neighbors[j], neighbors[i]) {
          triangles = triangles + 1
        }
      }
    }
  }
  triangles / 3
}

///|
/// Returns the local clustering coefficient scaled to one million.
pub fn[N, E] Graph::local_clustering_scaled(
  self : Graph[N, E],
  node : NodeIndex,
) -> Int {
  if !self.contains_node(node) {
    return 0
  }
  let neighbors = self.underlying_neighbors(node)
  let degree = neighbors.length()
  if degree < 2 {
    return 0
  }
  let mut links = 0
  for i = 0; i < degree; i = i + 1 {
    for j = i + 1; j < degree; j = j + 1 {
      if self.has_edge(neighbors[i], neighbors[j]) ||
        self.has_edge(neighbors[j], neighbors[i]) {
        links = links + 1
      }
    }
  }
  links * 2 * RANK_SCALE / (degree * (degree - 1))
}

///|
/// Computes the core number of each node by deterministic degree peeling.
pub fn[N, E] Graph::k_core_numbers(self : Graph[N, E]) -> Array[Int] {
  let count = self.node_count()
  let degree = Array::make(count, 0)
  let removed = Array::make(count, false)
  let cores = Array::make(count, 0)
  for i = 0; i < count; i = i + 1 {
    degree[i] = self.underlying_neighbors(NodeIndex::{ val: i }).length()
  }
  let mut round = 0
  while round < count {
    let mut chosen = -1
    let mut minimum = 2147483647
    for i = 0; i < count; i = i + 1 {
      if !removed[i] && degree[i] < minimum {
        chosen = i
        minimum = degree[i]
      }
    }
    if chosen >= 0 {
      removed[chosen] = true
      cores[chosen] = minimum
      let neighbors = self.underlying_neighbors(NodeIndex::{ val: chosen })
      for i = 0; i < neighbors.length(); i = i + 1 {
        if !removed[neighbors[i].val] && degree[neighbors[i].val] > minimum {
          degree[neighbors[i].val] = degree[neighbors[i].val] - 1
        }
      }
    }
    round = round + 1
  }
  cores
}

///|
/// Returns the nodes whose core number is at least `k`.
pub fn[N, E] Graph::k_core(self : Graph[N, E], k : Int) -> Array[NodeIndex] {
  let cores = self.k_core_numbers()
  let result = []
  for i = 0; i < cores.length(); i = i + 1 {
    if cores[i] >= k {
      result.push(NodeIndex::{ val: i })
    }
  }
  result
}
