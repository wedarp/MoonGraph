///|
/// Checks if the graph contains any cycle.
/// Works for both directed and undirected graphs.
pub fn[N, E] Graph::has_cycle(self : Graph[N, E]) -> Bool {
  let num_nodes = self.nodes.length()
  if self.is_directed {
    let visited = Array::make(num_nodes, 0) // 0: unvisited, 1: visiting (gray), 2: visited (black)
    for i = 0; i < num_nodes; i = i + 1 {
      if visited[i] == 0 {
        if self.dfs_has_cycle_directed(NodeIndex::{ val: i }, visited) {
          return true
        }
      }
    }
    false
  } else {
    let visited = Array::make(num_nodes, false)
    for i = 0; i < num_nodes; i = i + 1 {
      if !visited[i] {
        if self.dfs_has_cycle_undirected(NodeIndex::{ val: i }, None, visited) {
          return true
        }
      }
    }
    false
  }
}

///|
fn[N, E] Graph::dfs_has_cycle_directed(
  self : Graph[N, E],
  u : NodeIndex,
  visited : Array[Int],
) -> Bool {
  visited[u.val] = 1 // visiting
  let nbrs = self.neighbors(u)
  for i = 0; i < nbrs.length(); i = i + 1 {
    let v = nbrs[i]
    if visited[v.val] == 1 {
      return true
    }
    if visited[v.val] == 0 {
      if self.dfs_has_cycle_directed(v, visited) {
        return true
      }
    }
  }
  visited[u.val] = 2 // visited
  false
}

///|
fn[N, E] Graph::dfs_has_cycle_undirected(
  self : Graph[N, E],
  u : NodeIndex,
  parent : NodeIndex?,
  visited : Array[Bool],
) -> Bool {
  visited[u.val] = true
  let nbrs = self.neighbors(u)
  for i = 0; i < nbrs.length(); i = i + 1 {
    let v = nbrs[i]
    if !visited[v.val] {
      if self.dfs_has_cycle_undirected(v, Some(u), visited) {
        return true
      }
    } else {
      match parent {
        None => ()
        Some(p) => if v.val != p.val { return true }
      }
    }
  }
  false
}
