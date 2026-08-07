///|
pub fn[N, E] Graph::node_count(self : Graph[N, E]) -> Int {
  self.nodes.length()
}

///|
pub fn[N, E] Graph::edge_count(self : Graph[N, E]) -> Int {
  self.edges.length()
}

///|
/// Returns whether this graph treats edges as directed.
pub fn[N, E] Graph::directed(self : Graph[N, E]) -> Bool {
  self.is_directed
}

///|
/// Returns all node indices in ascending insertion order.
pub fn[N, E] Graph::node_indices(self : Graph[N, E]) -> Array[NodeIndex] {
  let result = []
  for i = 0; i < self.nodes.length(); i = i + 1 {
    result.push(NodeIndex::{ val: i })
  }
  result
}

///|
/// Returns whether a node index is valid for this graph.
pub fn[N, E] Graph::contains_node(self : Graph[N, E], idx : NodeIndex) -> Bool {
  idx.val >= 0 && idx.val < self.nodes.length()
}

///|
/// Returns whether an edge index is valid for this graph.
pub fn[N, E] Graph::contains_edge(self : Graph[N, E], idx : EdgeIndex) -> Bool {
  idx.val >= 0 && idx.val < self.edges.length()
}

///|
pub fn[N, E] Graph::node_weight(self : Graph[N, E], idx : NodeIndex) -> N? {
  if idx.val >= 0 && idx.val < self.nodes.length() {
    Some(self.nodes[idx.val].weight)
  } else {
    None
  }
}

///|
pub fn[N, E] Graph::edge_weight(self : Graph[N, E], idx : EdgeIndex) -> E? {
  if idx.val >= 0 && idx.val < self.edges.length() {
    Some(self.edges[idx.val].weight)
  } else {
    None
  }
}

///|
/// Returns the number of outgoing adjacency entries for a node.
pub fn[N, E] Graph::out_degree(self : Graph[N, E], source : NodeIndex) -> Int {
  self.neighbors(source).length()
}

///|
/// Returns the number of incoming adjacency entries for a node.
pub fn[N, E] Graph::in_degree(self : Graph[N, E], target : NodeIndex) -> Int {
  if !self.contains_node(target) {
    return 0
  }
  let mut count = 0
  for i = 0; i < self.nodes.length(); i = i + 1 {
    let nbrs = self.neighbors(NodeIndex::{ val: i })
    for j = 0; j < nbrs.length(); j = j + 1 {
      if nbrs[j].val == target.val {
        count = count + 1
      }
    }
  }
  count
}

///|
/// Returns whether an adjacency edge from `source` to `target` exists.
pub fn[N, E] Graph::has_edge(
  self : Graph[N, E],
  source : NodeIndex,
  target : NodeIndex,
) -> Bool {
  let nbrs = self.neighbors(source)
  for i = 0; i < nbrs.length(); i = i + 1 {
    if nbrs[i].val == target.val {
      return true
    }
  }
  false
}

///|
pub fn[N, E] Graph::neighbors(
  self : Graph[N, E],
  source : NodeIndex,
) -> Array[NodeIndex] {
  let result = []
  if source.val < 0 || source.val >= self.nodes.length() {
    return result
  }
  let mut curr_edge = self.nodes[source.val].first_outgoing_edge
  while true {
    match curr_edge {
      None => break
      Some(edge_idx) => {
        let edge = self.edges[edge_idx.val]
        result.push(edge.target_node)
        curr_edge = edge.next_outgoing_edge
      }
    }
  }
  result
}
