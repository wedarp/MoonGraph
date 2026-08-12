///|
/// A deterministic random-walk trace suitable for reproducible graph sampling.
pub struct WalkTrace {
  nodes : Array[NodeIndex]
  node_count : Int
}

///|
pub fn WalkTrace::length(self : WalkTrace) -> Int {
  self.nodes.length()
}

///|
pub fn WalkTrace::nodes(self : WalkTrace) -> Array[NodeIndex] {
  self.nodes
}

///|
pub fn WalkTrace::unique_nodes(self : WalkTrace) -> Array[NodeIndex] {
  let seen = Array::make(self.node_count, false)
  let result = []
  for i = 0; i < self.nodes.length(); i = i + 1 {
    let node = self.nodes[i]
    if !seen[node.val] {
      seen[node.val] = true
      result.push(node)
    }
  }
  result
}

///|
pub fn WalkTrace::visit_counts(self : WalkTrace) -> Array[Int] {
  let counts = Array::make(self.node_count, 0)
  for i = 0; i < self.nodes.length(); i = i + 1 {
    counts[self.nodes[i].val] = counts[self.nodes[i].val] + 1
  }
  counts
}

///|
/// Returns the fraction of post-start visits that return to the start, scaled to one million.
pub fn WalkTrace::return_probability_scaled(self : WalkTrace) -> Int {
  if self.nodes.length() <= 1 {
    return 0
  }
  let start = self.nodes[0].val
  let mut returns = 0
  for i = 1; i < self.nodes.length(); i = i + 1 {
    if self.nodes[i].val == start {
      returns = returns + 1
    }
  }
  returns * 1000000 / (self.nodes.length() - 1)
}

///|
/// Performs a reproducible walk. The seed and a small integer LCG make results portable.
pub fn[N, E] Graph::random_walk(
  self : Graph[N, E],
  start : NodeIndex,
  steps : Int,
  seed : Int,
) -> WalkTrace {
  if !self.contains_node(start) || steps < 0 {
    return { nodes: [], node_count: self.node_count() }
  }
  let nodes = [start]
  let mut state = if seed < 0 { -seed } else { seed }
  let mut current = start
  let mut step = 0
  while step < steps {
    let neighbors = self.neighbors(current)
    if neighbors.length() == 0 {
      break
    }
    state = (state * 110351 + 12345) % 2147483647
    if state < 0 {
      state = -state
    }
    current = neighbors[state % neighbors.length()]
    nodes.push(current)
    step = step + 1
  }
  { nodes, node_count: self.node_count() }
}
