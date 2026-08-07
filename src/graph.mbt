///|
pub struct NodeIndex {
  val : Int
} derive(Eq, Compare, Debug)

///|
/// Creates a node index value. Index values are validated by graph operations.
pub fn NodeIndex::new(value : Int) -> NodeIndex {
  NodeIndex::{ val: value }
}

///|
/// Returns the zero-based node index value.
pub fn NodeIndex::value(self : NodeIndex) -> Int {
  self.val
}

///|
pub struct EdgeIndex {
  val : Int
} derive(Eq, Compare, Debug)

///|
/// Creates an edge index value. Index values are validated by graph operations.
pub fn EdgeIndex::new(value : Int) -> EdgeIndex {
  EdgeIndex::{ val: value }
}

///|
/// Returns the zero-based edge index value.
pub fn EdgeIndex::value(self : EdgeIndex) -> Int {
  self.val
}

///|
struct NodeData[N] {
  weight : N
  mut first_outgoing_edge : EdgeIndex?
}

///|
struct EdgeData[E] {
  weight : E
  target_node : NodeIndex
  next_outgoing_edge : EdgeIndex?
}

///|
/// A graph data structure using adjacency list.
pub struct Graph[N, E] {
  nodes : Array[NodeData[N]]
  edges : Array[EdgeData[E]]
  is_directed : Bool
}

///|
/// Creates a new empty graph.
pub fn[N, E] Graph::new(directed? : Bool = true) -> Graph[N, E] {
  { nodes: [], edges: [], is_directed: directed }
}

///|
/// Adds a node with the given weight to the graph.
pub fn[N, E] Graph::add_node(self : Graph[N, E], weight : N) -> NodeIndex {
  let idx = self.nodes.length()
  self.nodes.push({ weight, first_outgoing_edge: None })
  NodeIndex::{ val: idx }
}

///|
/// Adds an edge from `source` to `target` with the given `weight`.
pub fn[N, E] Graph::add_edge(
  self : Graph[N, E],
  source : NodeIndex,
  target : NodeIndex,
  weight : E,
) -> EdgeIndex {
  if !self.contains_node(source) || !self.contains_node(target) {
    return EdgeIndex::{ val: -1 }
  }
  let s = source.val
  let edge_idx = self.edges.length()
  let prev_first = self.nodes[s].first_outgoing_edge
  self.edges.push({
    weight,
    target_node: target,
    next_outgoing_edge: prev_first,
  })
  self.nodes[s].first_outgoing_edge = Some(EdgeIndex::{ val: edge_idx })

  if !self.is_directed {
    let t = target.val
    let rev_edge_idx = self.edges.length()
    let t_prev_first = self.nodes[t].first_outgoing_edge
    // NOTE: For undirected graphs, we duplicate the edge in the reverse direction.
    // In a real optimized library, we might share edge data or use different indexing,
    // but this is standard for adjacency lists.
    self.edges.push({
      weight,
      target_node: source,
      next_outgoing_edge: t_prev_first,
    })
    self.nodes[t].first_outgoing_edge = Some(EdgeIndex::{ val: rev_edge_idx })
  }

  EdgeIndex::{ val: edge_idx }
}
