///|
/// A directed acyclic graph obtained by contracting each strongly connected
/// component into one node.
pub struct Condensation {
  graph : Graph[Int, Int]
  components : Array[Array[NodeIndex]]
  component_of : Array[Int]
}

///|
pub fn Condensation::graph(self : Condensation) -> Graph[Int, Int] {
  self.graph
}

///|
pub fn Condensation::components(self : Condensation) -> Array[Array[NodeIndex]] {
  self.components
}

///|
pub fn Condensation::component_count(self : Condensation) -> Int {
  self.components.length()
}

///|
pub fn Condensation::component_of(self : Condensation, node : NodeIndex) -> Int {
  if node.val < 0 || node.val >= self.component_of.length() {
    -1
  } else {
    self.component_of[node.val]
  }
}

///|
/// Contracts SCCs into a DAG while preserving deterministic component members.
pub fn[N, E] Graph::condensation(self : Graph[N, E]) -> Condensation {
  let components = self.tarjan_scc()
  let mapping = Array::make(self.node_count(), -1)
  for component_id = 0
      component_id < components.length()
      component_id = component_id + 1 {
    let component = components[component_id]
    for i = 0; i < component.length(); i = i + 1 {
      mapping[component[i].val] = component_id
    }
  }
  let result : Graph[Int, Int] = Graph::new(directed=true)
  for component_id = 0
      component_id < components.length()
      component_id = component_id + 1 {
    let _ = result.add_node(component_id)
  }
  let edges = self.edge_list()
  for i = 0; i < edges.length(); i = i + 1 {
    let edge = edges[i]
    let source = mapping[edge.0.val]
    let target = mapping[edge.1.val]
    if source >= 0 &&
      target >= 0 &&
      source != target &&
      !result.has_edge(NodeIndex::{ val: source }, NodeIndex::{ val: target }) {
      let _ = result.add_edge(
        NodeIndex::{ val: source },
        NodeIndex::{ val: target },
        1,
      )
    }
  }
  { graph: result, components, component_of: mapping }
}
