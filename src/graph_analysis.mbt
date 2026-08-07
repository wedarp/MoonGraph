///|
/// Assigns a deterministic greedy color to every node.
///
/// The returned array stores a non-negative color number at each node index.
/// Adjacent nodes always receive different colors. This is a fast heuristic,
/// not an exact chromatic-number solver.
pub fn[N, E] Graph::greedy_coloring(self : Graph[N, E]) -> Array[Int] {
  let colors = Array::make(self.node_count(), -1)
  for node = 0; node < self.node_count(); node = node + 1 {
    let used = Array::make(self.node_count() + 1, false)
    let neighbors = self.neighbors(NodeIndex::{ val: node })
    for i = 0; i < neighbors.length(); i = i + 1 {
      let neighbor_color = colors[neighbors[i].val]
      if neighbor_color >= 0 {
        used[neighbor_color] = true
      }
    }
    let mut color = 0
    while color < used.length() && used[color] {
      color = color + 1
    }
    colors[node] = color
  }
  colors
}

///|
priv struct LowLinkState {
  mut time : Int
  discovery : Array[Int]
  low : Array[Int]
  articulation : Array[Bool]
  bridges : Array[Array[NodeIndex]]
}

///|
/// Returns articulation points of an undirected graph using low-link values.
/// Returns an empty array for directed graphs.
pub fn[N, E] Graph::articulation_points(self : Graph[N, E]) -> Array[NodeIndex] {
  let result = []
  if self.directed() {
    return result
  }
  let state = {
    time: 0,
    discovery: Array::make(self.node_count(), -1),
    low: Array::make(self.node_count(), -1),
    articulation: Array::make(self.node_count(), false),
    bridges: [],
  }
  for node = 0; node < self.node_count(); node = node + 1 {
    if state.discovery[node] == -1 {
      self.low_link_dfs(NodeIndex::{ val: node }, NodeIndex::new(-1), state)
    }
  }
  for node = 0; node < self.node_count(); node = node + 1 {
    if state.articulation[node] {
      result.push(NodeIndex::{ val: node })
    }
  }
  result
}

///|
/// Returns bridge edges of an undirected graph as `[source, target]` pairs.
/// Returns an empty array for directed graphs.
pub fn[N, E] Graph::bridges(self : Graph[N, E]) -> Array[Array[NodeIndex]] {
  if self.directed() {
    return []
  }
  let state = {
    time: 0,
    discovery: Array::make(self.node_count(), -1),
    low: Array::make(self.node_count(), -1),
    articulation: Array::make(self.node_count(), false),
    bridges: [],
  }
  for node = 0; node < self.node_count(); node = node + 1 {
    if state.discovery[node] == -1 {
      self.low_link_dfs(NodeIndex::{ val: node }, NodeIndex::new(-1), state)
    }
  }
  state.bridges
}

///|
fn[N, E] Graph::low_link_dfs(
  self : Graph[N, E],
  current : NodeIndex,
  parent : NodeIndex,
  state : LowLinkState,
) -> Unit {
  state.discovery[current.val] = state.time
  state.low[current.val] = state.time
  state.time = state.time + 1
  let mut children = 0
  let neighbors = self.neighbors(current)
  for i = 0; i < neighbors.length(); i = i + 1 {
    let neighbor = neighbors[i]
    if neighbor.val == parent.val {
      continue
    }
    if state.discovery[neighbor.val] == -1 {
      children = children + 1
      self.low_link_dfs(neighbor, current, state)
      if state.low[neighbor.val] < state.low[current.val] {
        state.low[current.val] = state.low[neighbor.val]
      }
      if parent.val == -1 && children > 1 {
        state.articulation[current.val] = true
      }
      if parent.val != -1 &&
        state.low[neighbor.val] >= state.discovery[current.val] {
        state.articulation[current.val] = true
      }
      if state.low[neighbor.val] > state.discovery[current.val] {
        state.bridges.push([current, neighbor])
      }
    } else if state.discovery[neighbor.val] < state.low[current.val] {
      state.low[current.val] = state.discovery[neighbor.val]
    }
  }
}

///|
/// Computes longest distances from `start` in a weighted DAG.
/// Returns `None` for invalid starts, undirected graphs, or cyclic graphs.
pub fn[N] Graph::dag_longest_paths(
  self : Graph[N, Int],
  start : NodeIndex,
) -> Array[Int]? {
  if !self.directed() || !self.contains_node(start) {
    return None
  }
  let order = self.topological_sort()
  if order is None {
    return None
  }
  let distances = Array::make(self.node_count(), -2147483647)
  distances[start.val] = 0
  let nodes = order.unwrap()
  for i = 0; i < nodes.length(); i = i + 1 {
    let current = nodes[i]
    if distances[current.val] == -2147483647 {
      continue
    }
    let mut edge = self.nodes[current.val].first_outgoing_edge
    while true {
      match edge {
        None => break
        Some(edge_index) => {
          let data = self.edges[edge_index.val]
          let candidate = distances[current.val] + data.weight
          if candidate > distances[data.target_node.val] {
            distances[data.target_node.val] = candidate
          }
          edge = data.next_outgoing_edge
        }
      }
    }
  }
  Some(distances)
}
