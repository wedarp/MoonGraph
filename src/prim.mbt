///|
priv struct PrimCandidate {
  to : NodeIndex
  edge : EdgeIndex
}

///|
/// Computes a minimum spanning forest for an undirected weighted graph.
/// Disconnected inputs produce one tree per connected component.
pub fn[N] Graph::prim_mst(self : Graph[N, Int]) -> Array[EdgeIndex] {
  let result = []
  if self.directed() {
    return result
  }
  let visited = Array::make(self.node_count(), false)
  for root = 0; root < self.node_count(); root = root + 1 {
    if visited[root] {
      continue
    }
    visited[root] = true
    let queue : PriorityQueue[Int, PrimCandidate] = PriorityQueue::new()
    self.push_prim_edges(NodeIndex::{ val: root }, visited, queue)
    while !queue.is_empty() {
      let candidate = queue.pop().unwrap()
      if visited[candidate.to.val] {
        continue
      }
      visited[candidate.to.val] = true
      result.push(candidate.edge)
      self.push_prim_edges(candidate.to, visited, queue)
    }
  }
  result
}

///|
fn[N] Graph::push_prim_edges(
  self : Graph[N, Int],
  source : NodeIndex,
  visited : Array[Bool],
  queue : PriorityQueue[Int, PrimCandidate],
) -> Unit {
  let mut edge = self.nodes[source.val].first_outgoing_edge
  while true {
    match edge {
      None => break
      Some(edge_index) => {
        let data = self.edges[edge_index.val]
        if !visited[data.target_node.val] {
          queue.push(data.weight, { to: data.target_node, edge: edge_index })
        }
        edge = data.next_outgoing_edge
      }
    }
  }
}
