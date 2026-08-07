///|
const INFINITY : Int = 2147483647

///|
/// Computes all-pairs shortest-path distances with Floyd–Warshall.
///
/// The result uses `2147483647` for unreachable pairs, matching `dijkstra`
/// and `bellman_ford`. Negative edge weights are supported as long as the
/// graph has no negative cycle.
pub fn[N] Graph::floyd_warshall(self : Graph[N, Int]) -> Array[Array[Int]] {
  let distances = []
  let node_count = self.node_count()
  for i = 0; i < node_count; i = i + 1 {
    let row = Array::make(node_count, INFINITY)
    row[i] = 0
    distances.push(row)
  }

  for source = 0; source < node_count; source = source + 1 {
    let mut current_edge = self.nodes[source].first_outgoing_edge
    while true {
      match current_edge {
        None => break
        Some(edge_index) => {
          let edge = self.edges[edge_index.val]
          let target = edge.target_node.val
          if edge.weight < distances[source][target] {
            distances[source][target] = edge.weight
          }
          current_edge = edge.next_outgoing_edge
        }
      }
    }
  }

  for intermediate = 0
      intermediate < node_count
      intermediate = intermediate + 1 {
    for source = 0; source < node_count; source = source + 1 {
      if distances[source][intermediate] == INFINITY {
        continue
      }
      for target = 0; target < node_count; target = target + 1 {
        if distances[intermediate][target] == INFINITY {
          continue
        }
        let through_intermediate = distances[source][intermediate] +
          distances[intermediate][target]
        if through_intermediate < distances[source][target] {
          distances[source][target] = through_intermediate
        }
      }
    }
  }
  distances
}
