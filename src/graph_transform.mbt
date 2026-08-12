///|
/// A result of extracting an induced subgraph.
pub struct SubgraphResult[N, E] {
  graph : Graph[N, E]
  original_nodes : Array[NodeIndex]
}

///|
pub fn[N, E] SubgraphResult::node_count(self : SubgraphResult[N, E]) -> Int {
  self.graph.node_count()
}

///|
pub fn[N, E] SubgraphResult::edge_count(self : SubgraphResult[N, E]) -> Int {
  self.graph.edge_count()
}

///|
pub fn[N, E] SubgraphResult::graph(self : SubgraphResult[N, E]) -> Graph[N, E] {
  self.graph
}

///|
pub fn[N, E] SubgraphResult::original_nodes(
  self : SubgraphResult[N, E],
) -> Array[NodeIndex] {
  self.original_nodes
}

///|
/// Returns a graph with every directed edge reversed.
pub fn[N, E] Graph::transpose(self : Graph[N, E]) -> Graph[N, E] {
  let result : Graph[N, E] = Graph::new(directed=self.directed())
  for i = 0; i < self.node_count(); i = i + 1 {
    let _ = result.add_node(self.node_weight(NodeIndex::{ val: i }).unwrap())
  }
  if self.directed() {
    let edges = self.weighted_edge_list()
    for i = 0; i < edges.length(); i = i + 1 {
      let edge = edges[i]
      let _ = result.add_edge(edge.1, edge.0, edge.2)
    }
  } else {
    let edges = self.weighted_edge_list()
    for i = 0; i < edges.length(); i = i + 1 {
      let edge = edges[i]
      if edge.0.val <= edge.1.val {
        let _ = result.add_edge(edge.0, edge.1, edge.2)
      }
    }
  }
  result
}

///|
/// Returns all adjacency entries in deterministic node/adjacency order.
pub fn[N, E] Graph::edge_list(
  self : Graph[N, E],
) -> Array[(NodeIndex, NodeIndex)] {
  let result = []
  for i = 0; i < self.node_count(); i = i + 1 {
    let source = NodeIndex::{ val: i }
    let neighbors = self.neighbors(source)
    for j = 0; j < neighbors.length(); j = j + 1 {
      result.push((source, neighbors[j]))
    }
  }
  result
}

///|
/// Returns all adjacency entries together with their edge weights.
pub fn[N, E] Graph::weighted_edge_list(
  self : Graph[N, E],
) -> Array[(NodeIndex, NodeIndex, E)] {
  let result = []
  for i = 0; i < self.node_count(); i = i + 1 {
    let source = NodeIndex::{ val: i }
    let mut edge = self.nodes[i].first_outgoing_edge
    while true {
      match edge {
        None => break
        Some(edge_index) => {
          let data = self.edges[edge_index.val]
          result.push((source, data.target_node, data.weight))
          edge = data.next_outgoing_edge
        }
      }
    }
  }
  result
}

///|
/// Extracts a node-induced subgraph and records the original node indices.
/// Invalid indices are ignored and duplicate indices are kept only once.
pub fn[N, E] Graph::induced_subgraph(
  self : Graph[N, E],
  selected : Array[NodeIndex],
) -> SubgraphResult[N, E] {
  let result : Graph[N, E] = Graph::new(directed=self.directed())
  let original = []
  let mapping = Array::make(self.node_count(), -1)
  for i = 0; i < selected.length(); i = i + 1 {
    let original_index = selected[i]
    if self.contains_node(original_index) && mapping[original_index.val] == -1 {
      mapping[original_index.val] = result.node_count()
      let _ = result.add_node(self.node_weight(original_index).unwrap())
      original.push(original_index)
    }
  }
  let edges = self.weighted_edge_list()
  for i = 0; i < edges.length(); i = i + 1 {
    let edge = edges[i]
    let source_new = mapping[edge.0.val]
    let target_new = mapping[edge.1.val]
    if source_new >= 0 && target_new >= 0 {
      if self.directed() || edge.0.val <= edge.1.val {
        let _ = result.add_edge(
          NodeIndex::{ val: source_new },
          NodeIndex::{ val: target_new },
          edge.2,
        )
      }
    }
  }
  { graph: result, original_nodes: original }
}
