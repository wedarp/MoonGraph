///|
const CENTRALITY_INF : Int = 2147483647

///|
fn saturating_path_sum(left : Int, right : Int) -> Int {
  if left >= CENTRALITY_INF ||
    right >= CENTRALITY_INF ||
    left > CENTRALITY_INF - right {
    CENTRALITY_INF
  } else {
    left + right
  }
}

///|
/// Returns the sum of outgoing degrees, including adjacency duplicates.
pub fn[N, E] Graph::degree_sum(self : Graph[N, E]) -> Int {
  let mut total = 0
  for i = 0; i < self.node_count(); i = i + 1 {
    total = total + self.out_degree(NodeIndex::{ val: i })
  }
  total
}

///|
/// Tests whether every node has the same outgoing degree.
pub fn[N, E] Graph::is_regular(self : Graph[N, E]) -> Bool {
  if self.node_count() == 0 {
    return true
  }
  let expected = self.out_degree(NodeIndex::{ val: 0 })
  for i = 1; i < self.node_count(); i = i + 1 {
    if self.out_degree(NodeIndex::{ val: i }) != expected {
      return false
    }
  }
  true
}

///|
/// Returns the number of finite destinations reachable from every node.
pub fn[N, E] Graph::finite_reachability_counts(
  self : Graph[N, E],
) -> Array[Int] {
  let result = Array::make(self.node_count(), 0)
  for i = 0; i < self.node_count(); i = i + 1 {
    let distances = self.bfs_distances(NodeIndex::{ val: i })
    let mut count = 0
    for j = 0; j < distances.length(); j = j + 1 {
      if distances[j] != CENTRALITY_INF {
        count = count + 1
      }
    }
    result[i] = count
  }
  result
}

///|
/// Tests whether at least one edge crosses two node sets.
pub fn[N, E] Graph::has_edge_between_sets(
  self : Graph[N, E],
  left : Array[NodeIndex],
  right : Array[NodeIndex],
) -> Bool {
  self.edge_boundary(left, right).length() > 0
}

///|
/// Counts edges crossing two node sets without exposing edge weights.
pub fn[N, E] Graph::edge_boundary_count(
  self : Graph[N, E],
  left : Array[NodeIndex],
  right : Array[NodeIndex],
) -> Int {
  self.edge_boundary(left, right).length()
}

///|
/// Counts shortest unweighted paths from a source. Counts saturate at Int max.
pub fn[N, E] Graph::shortest_path_counts(
  self : Graph[N, E],
  source : NodeIndex,
) -> Array[Int] {
  let counts = Array::make(self.node_count(), 0)
  if !self.contains_node(source) {
    return counts
  }
  let distances = Array::make(self.node_count(), CENTRALITY_INF)
  distances[source.val] = 0
  counts[source.val] = 1
  let queue = [source]
  let mut head = 0
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    let neighbors = self.neighbors(current)
    for i = 0; i < neighbors.length(); i = i + 1 {
      let next = neighbors[i]
      let candidate = distances[current.val] + 1
      if distances[next.val] == CENTRALITY_INF {
        distances[next.val] = candidate
        counts[next.val] = counts[current.val]
        queue.push(next)
      } else if distances[next.val] == candidate {
        counts[next.val] = saturating_path_sum(
          counts[next.val],
          counts[current.val],
        )
      }
    }
  }
  counts
}

///|
/// Returns the largest finite unweighted distance from each node.
pub fn[N, E] Graph::eccentricities(self : Graph[N, E]) -> Array[Int] {
  let result = Array::make(self.node_count(), 0)
  for i = 0; i < self.node_count(); i = i + 1 {
    let distances = self.bfs_distances(NodeIndex::{ val: i })
    let mut largest = 0
    for j = 0; j < distances.length(); j = j + 1 {
      if distances[j] != CENTRALITY_INF && distances[j] > largest {
        largest = distances[j]
      }
    }
    result[i] = largest
  }
  result
}

///|
/// Returns closeness centrality scaled by one million.
///
/// For a disconnected node, only finite destinations contribute. This makes
/// the result useful for directed dependency graphs as well as connected
/// undirected networks.
pub fn[N, E] Graph::closeness_centrality_scaled(
  self : Graph[N, E],
) -> Array[Int] {
  let result = Array::make(self.node_count(), 0)
  for i = 0; i < self.node_count(); i = i + 1 {
    let distances = self.bfs_distances(NodeIndex::{ val: i })
    let mut sum = 0
    let mut reachable = 0
    for j = 0; j < distances.length(); j = j + 1 {
      if i != j && distances[j] != CENTRALITY_INF {
        sum = sum + distances[j]
        reachable = reachable + 1
      }
    }
    if sum > 0 {
      result[i] = reachable * RANK_SCALE / sum
    }
  }
  result
}

///|
/// Returns one node's closeness centrality, or zero for an invalid index.
pub fn[N, E] Graph::closeness_centrality(
  self : Graph[N, E],
  node : NodeIndex,
) -> Int {
  if !self.contains_node(node) {
    return 0
  }
  self.closeness_centrality_scaled()[node.val]
}

///|
/// Returns directed edges leaving left and entering right.
pub fn[N, E] Graph::edge_boundary(
  self : Graph[N, E],
  left : Array[NodeIndex],
  right : Array[NodeIndex],
) -> Array[(NodeIndex, NodeIndex)] {
  let result = []
  for i = 0; i < left.length(); i = i + 1 {
    let source = left[i]
    if !self.contains_node(source) {
      continue
    }
    let neighbors = self.neighbors(source)
    for j = 0; j < neighbors.length(); j = j + 1 {
      if contains_centrality_node(right, neighbors[j]) {
        result.push((source, neighbors[j]))
      }
    }
  }
  result
}

///|
fn contains_centrality_node(
  nodes : Array[NodeIndex],
  target : NodeIndex,
) -> Bool {
  for i = 0; i < nodes.length(); i = i + 1 {
    if nodes[i].val == target.val {
      return true
    }
  }
  false
}
