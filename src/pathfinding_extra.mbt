///|
/// Returns one shortest path from start to goal for non-negative weights.
/// The result includes both endpoints and returns None when unreachable.
pub fn[N] Graph::shortest_path(
  self : Graph[N, Int],
  start : NodeIndex,
  goal : NodeIndex,
) -> Array[NodeIndex]? {
  if !self.contains_node(start) || !self.contains_node(goal) {
    return None
  }
  let distances = Array::make(self.node_count(), 2147483647)
  let previous = Array::make(self.node_count(), None)
  let queue : PriorityQueue[Int, NodeIndex] = PriorityQueue::new()
  distances[start.val] = 0
  queue.push(0, start)
  while !queue.is_empty() {
    let current = queue.pop().unwrap()
    if current.val == goal.val {
      break
    }
    let mut edge = self.nodes[current.val].first_outgoing_edge
    while true {
      match edge {
        None => break
        Some(edge_index) => {
          let data = self.edges[edge_index.val]
          if data.weight < 0 {
            return None
          }
          let candidate = distances[current.val] + data.weight
          if candidate < distances[data.target_node.val] {
            distances[data.target_node.val] = candidate
            previous[data.target_node.val] = Some(current)
            queue.push(candidate, data.target_node)
          }
          edge = data.next_outgoing_edge
        }
      }
    }
  }
  if distances[goal.val] == 2147483647 {
    return None
  }
  let path = []
  let mut current = goal
  while true {
    path.push(current)
    if current.val == start.val {
      break
    }
    match previous[current.val] {
      None => return None
      Some(parent) => current = parent
    }
  }
  reverse_array(path)
  Some(path)
}

///|
/// Groups a DAG into dependency layers, starting with nodes of zero in-degree.
/// Returns None for undirected graphs or graphs containing a cycle.
pub fn[N, E] Graph::topological_layers(
  self : Graph[N, E],
) -> Array[Array[NodeIndex]]? {
  if !self.directed() {
    return None
  }
  let in_degree = Array::make(self.node_count(), 0)
  for node = 0; node < self.node_count(); node = node + 1 {
    let neighbors = self.neighbors(NodeIndex::{ val: node })
    for i = 0; i < neighbors.length(); i = i + 1 {
      in_degree[neighbors[i].val] = in_degree[neighbors[i].val] + 1
    }
  }
  let current = []
  for node = 0; node < self.node_count(); node = node + 1 {
    if in_degree[node] == 0 {
      current.push(NodeIndex::{ val: node })
    }
  }
  let layers = []
  let mut processed = 0
  let mut layer = current
  while layer.length() > 0 {
    layers.push(layer)
    let next = []
    let last = layers[layers.length() - 1]
    processed = processed + last.length()
    for i = 0; i < last.length(); i = i + 1 {
      let neighbors = self.neighbors(last[i])
      for j = 0; j < neighbors.length(); j = j + 1 {
        let neighbor = neighbors[j]
        in_degree[neighbor.val] = in_degree[neighbor.val] - 1
        if in_degree[neighbor.val] == 0 {
          next.push(neighbor)
        }
      }
    }
    layer = next
  }
  if processed == self.node_count() {
    Some(layers)
  } else {
    None
  }
}
