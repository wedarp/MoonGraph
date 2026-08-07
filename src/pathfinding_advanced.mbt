///|
fn[T] reverse_array(arr : Array[T]) -> Unit {
  let len = arr.length()
  for i = 0; i < len / 2; i = i + 1 {
    let temp = arr[i]
    arr[i] = arr[len - 1 - i]
    arr[len - 1 - i] = temp
  }
}

///|
/// A* pathfinding algorithm for finding the shortest path from `start` to `goal`.
/// `heuristic` is a function estimating the cost from a node to the `goal`.
/// Returns an array of `NodeIndex` representing the path from start to goal, or `None` if unreachable.
pub fn[N] Graph::a_star(
  self : Graph[N, Int],
  start : NodeIndex,
  goal : NodeIndex,
  heuristic : (NodeIndex) -> Int,
) -> Array[NodeIndex]? {
  let num_nodes = self.nodes.length()
  if start.val < 0 ||
    start.val >= num_nodes ||
    goal.val < 0 ||
    goal.val >= num_nodes {
    return None
  }

  let g_score = Array::make(num_nodes, 2147483647)
  g_score[start.val] = 0

  let pq : PriorityQueue[Int, NodeIndex] = PriorityQueue::new()
  pq.push(heuristic(start), start)

  let came_from = Array::make(num_nodes, None)

  while !pq.is_empty() {
    match pq.pop() {
      None => break
      Some(current) => {
        if current.val == goal.val {
          let path = []
          let mut curr = current
          while true {
            path.push(curr)
            match came_from[curr.val] {
              None => break
              Some(prev) => curr = prev
            }
          }
          reverse_array(path)
          return Some(path)
        }

        let curr_g = g_score[current.val]
        let mut curr_edge = self.nodes[current.val].first_outgoing_edge
        while true {
          match curr_edge {
            None => break
            Some(edge_idx) => {
              let edge = self.edges[edge_idx.val]
              let neighbor = edge.target_node
              let weight = edge.weight

              let tentative_g = curr_g + weight
              if tentative_g < g_score[neighbor.val] {
                came_from[neighbor.val] = Some(current)
                g_score[neighbor.val] = tentative_g
                let f_score = tentative_g + heuristic(neighbor)
                pq.push(f_score, neighbor)
              }

              curr_edge = edge.next_outgoing_edge
            }
          }
        }
      }
    }
  }
  None
}

///|
/// Bellman-Ford algorithm for finding shortest paths from a single source.
/// Supports negative edge weights.
/// Returns `Ok(dist)` where `dist[i]` is the shortest path distance to node `i`,
/// or `Err("Negative cycle detected")` if a negative-weight cycle is reachable.
pub fn[N] Graph::bellman_ford(
  self : Graph[N, Int],
  start : NodeIndex,
) -> Result[Array[Int], String] {
  let num_nodes = self.nodes.length()
  let dist = Array::make(num_nodes, 2147483647)

  if start.val < 0 || start.val >= num_nodes {
    return Ok(dist)
  }
  dist[start.val] = 0

  // Relax edges |V| - 1 times
  for i = 0; i < num_nodes - 1; i = i + 1 {
    let mut updated = false
    for u = 0; u < num_nodes; u = u + 1 {
      if dist[u] == 2147483647 {
        continue
      }

      let mut curr_edge = self.nodes[u].first_outgoing_edge
      while true {
        match curr_edge {
          None => break
          Some(edge_idx) => {
            let edge = self.edges[edge_idx.val]
            let v = edge.target_node
            let weight = edge.weight

            if dist[u] + weight < dist[v.val] {
              dist[v.val] = dist[u] + weight
              updated = true
            }
            curr_edge = edge.next_outgoing_edge
          }
        }
      }
    }
    if !updated {
      break
    }
  }

  // Check for negative-weight cycles
  for u = 0; u < num_nodes; u = u + 1 {
    if dist[u] == 2147483647 {
      continue
    }

    let mut curr_edge = self.nodes[u].first_outgoing_edge
    while true {
      match curr_edge {
        None => break
        Some(edge_idx) => {
          let edge = self.edges[edge_idx.val]
          let v = edge.target_node
          let weight = edge.weight

          if dist[u] + weight < dist[v.val] {
            return Err("Negative cycle detected")
          }
          curr_edge = edge.next_outgoing_edge
        }
      }
    }
  }

  Ok(dist)
}
