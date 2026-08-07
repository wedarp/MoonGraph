///|
/// Exports the graph to Graphviz DOT format.
/// Nodes are labeled with their weights converted to string via a custom label function.
/// Edges are labeled with their weights via a custom edge label function.
pub fn[N, E] Graph::to_dot(
  self : Graph[N, E],
  node_label : (N) -> String,
  edge_label : (E) -> String,
) -> String {
  let mut dot = ""
  if self.is_directed {
    dot = dot + "digraph G {\n"
  } else {
    dot = dot + "graph G {\n"
  }

  // Write nodes
  for i = 0; i < self.nodes.length(); i = i + 1 {
    let label = node_label(self.nodes[i].weight)
    dot = dot + "  \{i} [label=\"\{label}\"];\n"
  }

  // Write edges
  for i = 0; i < self.nodes.length(); i = i + 1 {
    let mut curr_edge = self.nodes[i].first_outgoing_edge
    while true {
      match curr_edge {
        None => break
        Some(edge_idx) => {
          let edge = self.edges[edge_idx.val]
          let target = edge.target_node.val

          // For undirected graphs, we only print each undirected edge once
          if self.is_directed || i <= target {
            let label = edge_label(edge.weight)
            let op = if self.is_directed { "->" } else { "--" }
            dot = dot + "  \{i} \{op} \{target} [label=\"\{label}\"];\n"
          }

          curr_edge = edge.next_outgoing_edge
        }
      }
    }
  }

  dot = dot + "}\n"
  dot
}
