///|
/// Returns a directed Eulerian trail when one exists.
/// The trail contains every stored edge exactly once.
pub fn[N, E] Graph::eulerian_trail(self : Graph[N, E]) -> Array[NodeIndex]? {
  if self.node_count() == 0 {
    return Some([])
  }
  let mut start = NodeIndex::{ val: 0 }
  let mut fallback = NodeIndex::{ val: 0 }
  let mut has_fallback = false
  for node = 0; node < self.node_count(); node = node + 1 {
    let index = NodeIndex::{ val: node }
    let out_degree = self.out_degree(index)
    let in_degree = self.in_degree(index)
    if out_degree == in_degree + 1 {
      start = index
      return self.eulerian_trail_for(start)
    }
    if !has_fallback && out_degree > 0 {
      fallback = index
      has_fallback = true
    }
  }
  if has_fallback {
    start = fallback
  } else {
    return self.eulerian_trail_for(start)
  }
  self.eulerian_trail_for(start)
}

///|
/// Returns a directed Eulerian trail beginning at start, if possible.
pub fn[N, E] Graph::eulerian_trail_for(
  self : Graph[N, E],
  start : NodeIndex,
) -> Array[NodeIndex]? {
  if !self.directed() || !self.contains_node(start) {
    return None
  }
  let mut start_count = 0
  let mut end_count = 0
  for node = 0; node < self.node_count(); node = node + 1 {
    let index = NodeIndex::{ val: node }
    let out_degree = self.out_degree(index)
    let in_degree = self.in_degree(index)
    if out_degree == in_degree + 1 {
      start_count = start_count + 1
      if node != start.val {
        return None
      }
    } else if in_degree == out_degree + 1 {
      end_count = end_count + 1
    } else if in_degree != out_degree {
      return None
    }
  }
  if start_count > 1 || end_count > 1 || start_count != end_count {
    return None
  }
  if self.edge_count() == 0 {
    return Some([start])
  }
  if self.out_degree(start) == 0 {
    return None
  }
  let used = Array::make(self.edge_count(), false)
  let stack = [start]
  let trail = []
  while stack.length() > 0 {
    let current = stack[stack.length() - 1]
    let mut selected : EdgeIndex? = None
    let mut edge = self.nodes[current.val].first_outgoing_edge
    while true {
      match edge {
        None => break
        Some(edge_index) => {
          if !used[edge_index.val] {
            selected = Some(edge_index)
            break
          }
          let data = self.edges[edge_index.val]
          edge = data.next_outgoing_edge
        }
      }
    }
    match selected {
      None => trail.push(stack.pop().unwrap())
      Some(edge_index) => {
        used[edge_index.val] = true
        stack.push(self.edges[edge_index.val].target_node)
      }
    }
  }
  reverse_array(trail)
  if trail.length() == self.edge_count() + 1 {
    Some(trail)
  } else {
    None
  }
}
