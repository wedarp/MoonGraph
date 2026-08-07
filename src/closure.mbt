///|
/// Returns the reachability matrix using one breadth-first search per node.
/// Every node reaches itself, including isolated nodes.
pub fn[N, E] Graph::transitive_closure(
  self : Graph[N, E],
) -> Array[Array[Bool]] {
  let closure = []
  let node_count = self.node_count()
  for source = 0; source < node_count; source = source + 1 {
    let reachable = Array::make(node_count, false)
    reachable[source] = true
    let queue = [NodeIndex::{ val: source }]
    let mut head = 0
    while head < queue.length() {
      let current = queue[head]
      head = head + 1
      let neighbors = self.neighbors(current)
      for i = 0; i < neighbors.length(); i = i + 1 {
        let neighbor = neighbors[i]
        if !reachable[neighbor.val] {
          reachable[neighbor.val] = true
          queue.push(neighbor)
        }
      }
    }
    closure.push(reachable)
  }
  closure
}
