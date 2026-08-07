///|
/// Topological sort of a directed acyclic graph (DAG) using Kahn's Algorithm.
/// Returns an array of `NodeIndex` in topological order.
/// Returns `None` if the graph is undirected or if a cycle is detected.
pub fn[N, E] Graph::topological_sort(self : Graph[N, E]) -> Array[NodeIndex]? {
  if !self.is_directed {
    return None // only defined for directed graphs
  }

  let len = self.nodes.length()
  let in_degree = Array::make(len, 0)

  // Compute in-degrees for all nodes
  for i = 0; i < len; i = i + 1 {
    let nbrs = self.neighbors(NodeIndex::{ val: i })
    for j = 0; j < nbrs.length(); j = j + 1 {
      in_degree[nbrs[j].val] = in_degree[nbrs[j].val] + 1
    }
  }

  let queue = []
  for i = 0; i < len; i = i + 1 {
    if in_degree[i] == 0 {
      queue.push(NodeIndex::{ val: i })
    }
  }

  let result = []
  let mut head = 0

  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    result.push(current)

    let nbrs = self.neighbors(current)
    for j = 0; j < nbrs.length(); j = j + 1 {
      let nbr = nbrs[j]
      in_degree[nbr.val] = in_degree[nbr.val] - 1
      if in_degree[nbr.val] == 0 {
        queue.push(nbr)
      }
    }
  }

  if result.length() == len {
    Some(result)
  } else {
    None // cycle detected
  }
}
