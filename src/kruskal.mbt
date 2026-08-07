///|
struct WeightedEdge {
  idx : EdgeIndex
  source : NodeIndex
  target : NodeIndex
  weight : Int
} derive(Eq, Compare)

///|
/// Kruskal's algorithm for finding the Minimum Spanning Tree (MST).
/// Returns an array of `EdgeIndex` that form the MST.
pub fn[N] Graph::kruskal_mst(self : Graph[N, Int]) -> Array[EdgeIndex] {
  let edges = []
  for i = 0; i < self.nodes.length(); i = i + 1 {
    let mut curr = self.nodes[i].first_outgoing_edge
    while true {
      match curr {
        None => break
        Some(edge_idx) => {
          let edge = self.edges[edge_idx.val]
          // To avoid duplicating edges in an undirected graph, only consider source <= target
          if i <= edge.target_node.val {
            edges.push({
              idx: edge_idx,
              source: NodeIndex::{ val: i },
              target: edge.target_node,
              weight: edge.weight,
            })
          }
          curr = edge.next_outgoing_edge
        }
      }
    }
  }

  // Sort edges by weight in ascending order
  edges.sort_by(fn(a, b) { a.weight.compare(b.weight) })

  let ds = DisjointSet::new(self.nodes.length())
  let mst = []

  for i = 0; i < edges.length(); i = i + 1 {
    let edge = edges[i]
    if ds.union(edge.source.val, edge.target.val) {
      mst.push(edge.idx)
    }
  }
  mst
}
