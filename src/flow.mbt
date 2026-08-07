///|
/// Computes the maximum flow from `source` to `sink` with Edmonds–Karp.
///
/// Edge weights are non-negative capacities. Parallel edges are aggregated,
/// undirected graphs are rejected, and invalid inputs return a descriptive
/// error. The algorithm runs in `O(V * E^2)` time.
pub fn[N] Graph::max_flow(
  self : Graph[N, Int],
  source : NodeIndex,
  sink : NodeIndex,
) -> Result[Int, String] {
  if !self.contains_node(source) || !self.contains_node(sink) {
    return Err("source or sink is out of range")
  }
  if !self.directed() {
    return Err("maximum flow requires a directed graph")
  }
  if source.val == sink.val {
    return Ok(0)
  }
  let node_count = self.node_count()
  let residual = []
  for i = 0; i < node_count; i = i + 1 {
    residual.push(Array::make(node_count, 0))
  }
  for u = 0; u < node_count; u = u + 1 {
    let mut edge = self.nodes[u].first_outgoing_edge
    while true {
      match edge {
        None => break
        Some(edge_index) => {
          let data = self.edges[edge_index.val]
          if data.weight < 0 {
            return Err("maximum flow capacity cannot be negative")
          }
          residual[u][data.target_node.val] = residual[u][data.target_node.val] +
            data.weight
          edge = data.next_outgoing_edge
        }
      }
    }
  }

  let mut total = 0
  let parent = Array::make(node_count, -1)
  while self.find_augmenting_path(residual, source.val, sink.val, parent) {
    let mut bottleneck = 2147483647
    let mut current = sink.val
    while current != source.val {
      let previous = parent[current]
      if residual[previous][current] < bottleneck {
        bottleneck = residual[previous][current]
      }
      current = previous
    }
    current = sink.val
    while current != source.val {
      let previous = parent[current]
      residual[previous][current] = residual[previous][current] - bottleneck
      residual[current][previous] = residual[current][previous] + bottleneck
      current = previous
    }
    total = total + bottleneck
  }
  Ok(total)
}

///|
fn[N] Graph::find_augmenting_path(
  self : Graph[N, Int],
  residual : Array[Array[Int]],
  source : Int,
  sink : Int,
  parent : Array[Int],
) -> Bool {
  ignore(self)
  for i = 0; i < parent.length(); i = i + 1 {
    parent[i] = -1
  }
  let visited = Array::make(parent.length(), false)
  visited[source] = true
  let queue = [source]
  let mut head = 0
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    for next = 0; next < parent.length(); next = next + 1 {
      if !visited[next] && residual[current][next] > 0 {
        visited[next] = true
        parent[next] = current
        queue.push(next)
        if next == sink {
          return true
        }
      }
    }
  }
  false
}
