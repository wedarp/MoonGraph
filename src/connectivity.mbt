///|
/// Returns weakly connected components.
///
/// For directed graphs, an edge is treated as undirected for this analysis;
/// for undirected graphs, the result is the ordinary connected components.
pub fn[N, E] Graph::weakly_connected_components(
  self : Graph[N, E],
) -> Array[Array[NodeIndex]] {
  let visited = Array::make(self.node_count(), false)
  let components = []
  for start = 0; start < self.node_count(); start = start + 1 {
    if visited[start] {
      continue
    }
    let component = []
    let queue = [NodeIndex::{ val: start }]
    visited[start] = true
    let mut head = 0
    while head < queue.length() {
      let current = queue[head]
      head = head + 1
      component.push(current)
      let outgoing = self.neighbors(current)
      for i = 0; i < outgoing.length(); i = i + 1 {
        let neighbor = outgoing[i]
        if !visited[neighbor.val] {
          visited[neighbor.val] = true
          queue.push(neighbor)
        }
      }
      if self.directed() {
        for candidate = 0
            candidate < self.node_count()
            candidate = candidate + 1 {
          let candidate_index = NodeIndex::{ val: candidate }
          if !visited[candidate] && self.has_edge(candidate_index, current) {
            visited[candidate] = true
            queue.push(candidate_index)
          }
        }
      }
    }
    components.push(component)
  }
  components
}

///|
/// Returns whether every node belongs to one weakly connected component.
pub fn[N, E] Graph::is_weakly_connected(self : Graph[N, E]) -> Bool {
  self.node_count() == 0 || self.weakly_connected_components().length() == 1
}
