///|
/// Counts directed paths in a DAG, saturating at the largest Int value.
pub fn[N, E] Graph::count_paths(
  self : Graph[N, E],
  start : NodeIndex,
  goal : NodeIndex,
) -> Result[Int, String] {
  if !self.contains_node(start) || !self.contains_node(goal) {
    return Err("source or target is out of range")
  }
  let order = match self.topological_sort() {
    None => return Err("path counting requires a directed acyclic graph")
    Some(value) => value
  }
  let counts = Array::make(self.node_count(), 0)
  counts[start.val] = 1
  for i = 0; i < order.length(); i = i + 1 {
    let current = order[i]
    if counts[current.val] == 0 {
      continue
    }
    let neighbors = self.neighbors(current)
    for j = 0; j < neighbors.length(); j = j + 1 {
      let next = neighbors[j]
      if counts[next.val] > 2147483647 - counts[current.val] {
        counts[next.val] = 2147483647
      } else {
        counts[next.val] = counts[next.val] + counts[current.val]
      }
    }
  }
  Ok(counts[goal.val])
}

///|
/// Produces the transitive reduction of a DAG while preserving node and edge weights.
/// Parallel edges are retained because they represent independent relationships.
pub fn[N, E] Graph::transitive_reduction(
  self : Graph[N, E],
) -> Result[Graph[N, E], String] {
  if !self.directed() {
    return Err("transitive reduction requires a directed graph")
  }
  match self.topological_sort() {
    None => return Err("transitive reduction requires a directed acyclic graph")
    Some(_) => ()
  }
  let result : Graph[N, E] = Graph::new(directed=true)
  for i = 0; i < self.node_count(); i = i + 1 {
    let _ = result.add_node(self.node_weight(NodeIndex::{ val: i }).unwrap())
  }
  let edges = self.weighted_edge_list()
  for i = 0; i < edges.length(); i = i + 1 {
    let edge = edges[i]
    if !self.has_alternate_path(edge.0, edge.1) {
      let _ = result.add_edge(edge.0, edge.1, edge.2)
    }
  }
  Ok(result)
}

///|
fn[N, E] Graph::has_alternate_path(
  self : Graph[N, E],
  source : NodeIndex,
  target : NodeIndex,
) -> Bool {
  let visited = Array::make(self.node_count(), false)
  visited[source.val] = true
  let queue = [source]
  let mut head = 0
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    let neighbors = self.neighbors(current)
    for i = 0; i < neighbors.length(); i = i + 1 {
      let next = neighbors[i]
      if current.val == source.val && next.val == target.val {
        continue
      }
      if next.val == target.val {
        return true
      }
      if !visited[next.val] {
        visited[next.val] = true
        queue.push(next)
      }
    }
  }
  false
}

///|
/// Counts adjacency entries from a source node to a target node.
pub fn[N, E] Graph::edge_multiplicity(
  self : Graph[N, E],
  source : NodeIndex,
  target : NodeIndex,
) -> Int {
  let mut count = 0
  let neighbors = self.neighbors(source)
  for i = 0; i < neighbors.length(); i = i + 1 {
    if neighbors[i].val == target.val {
      count = count + 1
    }
  }
  count
}

///|
/// Returns whether any ordered node pair has more than one adjacency entry.
pub fn[N, E] Graph::has_parallel_edges(self : Graph[N, E]) -> Bool {
  for source = 0; source < self.node_count(); source = source + 1 {
    let neighbors = self.neighbors(NodeIndex::{ val: source })
    for i = 0; i < neighbors.length(); i = i + 1 {
      if self.edge_multiplicity(NodeIndex::{ val: source }, neighbors[i]) > 1 {
        return true
      }
    }
  }
  false
}

///|
/// Returns whether the graph has no self-loops and no parallel adjacency entries.
pub fn[N, E] Graph::is_simple(self : Graph[N, E]) -> Bool {
  !self.has_self_loop() && !self.has_parallel_edges()
}

///|
/// Validates internal adjacency references and returns a descriptive error on corruption.
pub fn[N, E] Graph::validate(self : Graph[N, E]) -> Result[Unit, String] {
  for source = 0; source < self.node_count(); source = source + 1 {
    let mut edge = self.nodes[source].first_outgoing_edge
    while true {
      match edge {
        None => break
        Some(edge_index) => {
          if !self.contains_edge(edge_index) {
            return Err("adjacency references an invalid edge")
          }
          let data = self.edges[edge_index.val]
          if !self.contains_node(data.target_node) {
            return Err("edge references an invalid target node")
          }
          edge = data.next_outgoing_edge
        }
      }
    }
  }
  Ok(())
}
