///|
/// Average finite shortest-path distance scaled by one million.
pub fn[N, E] Graph::average_shortest_path_scaled(self : Graph[N, E]) -> Int {
  let mut total = 0
  let mut pairs = 0
  for i = 0; i < self.node_count(); i = i + 1 {
    let distances = self.bfs_distances(NodeIndex::{ val: i })
    for j = 0; j < distances.length(); j = j + 1 {
      if i != j && distances[j] != 2147483647 {
        total = total + distances[j]
        pairs = pairs + 1
      }
    }
  }
  if pairs == 0 {
    0
  } else {
    let whole = total / pairs
    let remainder = total % pairs
    whole * RANK_SCALE + remainder * RANK_SCALE / pairs
  }
}

///|
/// Returns the largest finite BFS distance, or zero when no pair is connected.
pub fn[N, E] Graph::diameter(self : Graph[N, E]) -> Int {
  let mut result = 0
  for i = 0; i < self.node_count(); i = i + 1 {
    let distances = self.bfs_distances(NodeIndex::{ val: i })
    for j = 0; j < distances.length(); j = j + 1 {
      if distances[j] != 2147483647 && distances[j] > result {
        result = distances[j]
      }
    }
  }
  result
}

///|
/// Computes total degree centrality scaled by one million.
pub fn[N, E] Graph::degree_centrality_scaled(self : Graph[N, E]) -> Array[Int] {
  let count = self.node_count()
  let result = Array::make(count, 0)
  if count < 2 {
    return result
  }
  for i = 0; i < count; i = i + 1 {
    let degree = self.underlying_neighbors(NodeIndex::{ val: i }).length()
    result[i] = degree * RANK_SCALE / (count - 1)
  }
  result
}

///|
/// Measures directed reciprocity: mutual adjacency entries divided by all entries.
pub fn[N, E] Graph::reciprocity_scaled(self : Graph[N, E]) -> Int {
  if !self.directed() || self.edge_count() == 0 {
    return 0
  }
  let mut mutual = 0
  let edges = self.edge_list()
  for i = 0; i < edges.length(); i = i + 1 {
    if self.has_edge(edges[i].1, edges[i].0) {
      mutual = mutual + 1
    }
  }
  mutual * RANK_SCALE / edges.length()
}

///|
/// Returns weakly connected component sizes in descending discovery order.
pub fn[N, E] Graph::component_sizes(self : Graph[N, E]) -> Array[Int] {
  let components = self.weakly_connected_components()
  let sizes = []
  for i = 0; i < components.length(); i = i + 1 {
    sizes.push(components[i].length())
  }
  sizes
}
