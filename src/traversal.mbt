///|
/// Breadth-First Search (BFS) Traversal.
/// Returns an array of node indices in the order they were visited.
pub fn[N, E] Graph::bfs(
  self : Graph[N, E],
  start : NodeIndex,
) -> Array[NodeIndex] {
  let visited = Array::make(self.nodes.length(), false)
  let result = []
  if start.val < 0 || start.val >= self.nodes.length() {
    return result
  }

  let queue = [start]
  visited[start.val] = true
  let mut head = 0

  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    result.push(current)

    let nbrs = self.neighbors(current)
    for i = 0; i < nbrs.length(); i = i + 1 {
      let neighbor = nbrs[i]
      if !visited[neighbor.val] {
        visited[neighbor.val] = true
        queue.push(neighbor)
      }
    }
  }
  result
}

///|
/// Depth-First Search (DFS) Traversal.
/// Returns an array of node indices in the order they were visited.
pub fn[N, E] Graph::dfs(
  self : Graph[N, E],
  start : NodeIndex,
) -> Array[NodeIndex] {
  let visited = Array::make(self.nodes.length(), false)
  let result = []
  if start.val < 0 || start.val >= self.nodes.length() {
    return result
  }

  let stack = [start]
  visited[start.val] = true

  while stack.length() > 0 {
    let current = stack.pop().unwrap()
    result.push(current)

    let nbrs = self.neighbors(current)
    // To match typical DFS behavior, we might push in reverse order, but for a general graph it doesn't matter.
    for i = 0; i < nbrs.length(); i = i + 1 {
      let neighbor = nbrs[i]
      if !visited[neighbor.val] {
        visited[neighbor.val] = true
        stack.push(neighbor)
      }
    }
  }
  result
}
