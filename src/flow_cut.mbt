///|
/// The result of a minimum s-t cut in a directed capacity graph.
pub struct CutResult {
  value : Int
  source_side : Array[NodeIndex]
  cut_edges : Array[(NodeIndex, NodeIndex, Int)]
}

///|
pub fn CutResult::value(self : CutResult) -> Int {
  self.value
}

///|
pub fn CutResult::source_side(self : CutResult) -> Array[NodeIndex] {
  self.source_side
}

///|
pub fn CutResult::cut_edges(
  self : CutResult,
) -> Array[(NodeIndex, NodeIndex, Int)] {
  self.cut_edges
}

///|
/// Computes a minimum cut and returns the source-side partition and crossing edges.
/// Capacities must be non-negative and the graph must be directed.
pub fn[N] Graph::min_cut(
  self : Graph[N, Int],
  source : NodeIndex,
  sink : NodeIndex,
) -> Result[CutResult, String] {
  if !self.contains_node(source) || !self.contains_node(sink) {
    return Err("source or sink is out of range")
  }
  if !self.directed() {
    return Err("minimum cut requires a directed graph")
  }
  if source.val == sink.val {
    return Ok({ value: 0, source_side: [source], cut_edges: [] })
  }
  let count = self.node_count()
  let residual = []
  for i = 0; i < count; i = i + 1 {
    residual.push(Array::make(count, 0))
  }
  let edges = self.weighted_edge_list()
  for i = 0; i < edges.length(); i = i + 1 {
    let edge = edges[i]
    if edge.2 < 0 {
      return Err("minimum cut capacity cannot be negative")
    }
    residual[edge.0.val][edge.1.val] = residual[edge.0.val][edge.1.val] + edge.2
  }
  let parent = Array::make(count, -1)
  let mut flow = 0
  while find_cut_path(residual, source.val, sink.val, parent) {
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
    flow = flow + bottleneck
  }
  let source_side = residual_reachable(residual, source.val)
  let cut_edges = []
  let mut cut_value = 0
  for i = 0; i < edges.length(); i = i + 1 {
    let edge = edges[i]
    if contains_node_index(source_side, edge.0) &&
      !contains_node_index(source_side, edge.1) {
      cut_edges.push(edge)
      cut_value = cut_value + edge.2
    }
  }
  // `flow` and the capacity sum are equal by max-flow/min-cut; returning the
  // capacity sum makes the result robust when parallel edges are present.
  ignore(flow)
  Ok({ value: cut_value, source_side, cut_edges })
}

///|
fn find_cut_path(
  residual : Array[Array[Int]],
  source : Int,
  sink : Int,
  parent : Array[Int],
) -> Bool {
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

///|
fn residual_reachable(
  residual : Array[Array[Int]],
  source : Int,
) -> Array[NodeIndex] {
  let visited = Array::make(residual.length(), false)
  visited[source] = true
  let queue = [source]
  let mut head = 0
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    for next = 0; next < residual.length(); next = next + 1 {
      if !visited[next] && residual[current][next] > 0 {
        visited[next] = true
        queue.push(next)
      }
    }
  }
  let result = []
  for i = 0; i < visited.length(); i = i + 1 {
    if visited[i] {
      result.push(NodeIndex::{ val: i })
    }
  }
  result
}
