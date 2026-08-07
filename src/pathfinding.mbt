///|
/// Dijkstra's algorithm for finding the shortest path from a start node.
/// This implementation assumes edge weights are `Int`.
/// Returns an array where the value at index `i` is the shortest distance from `start` to node `i`.
/// Unreachable nodes will have distance `2147483647` (max int).
pub fn[N] Graph::dijkstra(
  self : Graph[N, Int],
  start : NodeIndex,
) -> Array[Int] {
  let num_nodes = self.nodes.length()
  let dist = Array::make(num_nodes, 2147483647)

  if start.val < 0 || start.val >= num_nodes {
    return dist
  }

  dist[start.val] = 0
  let pq : PriorityQueue[Int, NodeIndex] = PriorityQueue::new()
  pq.push(0, start)

  while !pq.is_empty() {
    match pq.pop() {
      None => break
      Some(u) => {
        let u_dist = dist[u.val]

        let mut curr_edge = self.nodes[u.val].first_outgoing_edge
        while true {
          match curr_edge {
            None => break
            Some(edge_idx) => {
              let edge = self.edges[edge_idx.val]
              let v = edge.target_node
              let weight = edge.weight

              let alt = u_dist + weight
              if alt < dist[v.val] {
                dist[v.val] = alt
                pq.push(alt, v)
              }

              curr_edge = edge.next_outgoing_edge
            }
          }
        }
      }
    }
  }
  dist
}
