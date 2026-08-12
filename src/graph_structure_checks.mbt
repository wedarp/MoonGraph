///|
/// Returns whether an undirected graph is a connected tree.
pub fn[N, E] Graph::is_tree(self : Graph[N, E]) -> Bool {
  if self.directed() || self.node_count() == 0 {
    return false
  }
  let unique_edges = self.edge_count() / 2
  unique_edges == self.node_count() - 1 &&
  self.weakly_connected_components().length() == 1
}

///|
/// Returns whether every connected component of an undirected graph is a tree.
pub fn[N, E] Graph::is_forest(self : Graph[N, E]) -> Bool {
  if self.directed() {
    return false
  }
  let components = self.weakly_connected_components()
  let unique_edges = self.edge_count() / 2
  unique_edges == self.node_count() - components.length()
}

///|
/// Counts unordered node pairs that are connected in the underlying graph.
pub fn[N, E] Graph::connected_pair_count(self : Graph[N, E]) -> Int {
  let components = self.weakly_connected_components()
  let mut result = 0
  for i = 0; i < components.length(); i = i + 1 {
    let size = components[i].length()
    result = result + size * (size - 1) / 2
  }
  result
}
