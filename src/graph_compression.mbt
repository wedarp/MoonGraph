///|
/// A compact compressed-sparse-row view of a graph's adjacency relation.
///
/// The representation is backend-independent and keeps the node identifiers
/// stable. For an undirected graph, each direction present in the adjacency
/// list is retained, which makes row traversal O(1) to locate and O(degree)
/// to scan.
pub struct CsrGraph {
  offsets : Array[Int]
  targets : Array[Int]
}

///|
pub fn CsrGraph::row_count(self : CsrGraph) -> Int {
  self.offsets.length() - 1
}

///|
pub fn CsrGraph::edge_count(self : CsrGraph) -> Int {
  self.targets.length()
}

///|
pub fn CsrGraph::offsets(self : CsrGraph) -> Array[Int] {
  self.offsets
}

///|
pub fn CsrGraph::targets(self : CsrGraph) -> Array[Int] {
  self.targets
}

///|
/// Returns a row's target identifiers, or an empty array for an invalid row.
pub fn CsrGraph::neighbors(self : CsrGraph, row : Int) -> Array[Int] {
  if row < 0 || row >= self.row_count() {
    return []
  }
  let start = self.offsets[row]
  let stop = self.offsets[row + 1]
  let result = []
  for i = start; i < stop; i = i + 1 {
    result.push(self.targets[i])
  }
  result
}

///|
/// Returns the number of targets in a row, or zero for an invalid row.
pub fn CsrGraph::row_degree(self : CsrGraph, row : Int) -> Int {
  if row < 0 || row >= self.row_count() {
    return 0
  }
  self.offsets[row + 1] - self.offsets[row]
}

///|
/// Tests whether a compressed row contains a target identifier.
pub fn CsrGraph::contains_edge(
  self : CsrGraph,
  row : Int,
  target : Int,
) -> Bool {
  if row < 0 || row >= self.row_count() {
    return false
  }
  let start = self.offsets[row]
  let stop = self.offsets[row + 1]
  for i = start; i < stop; i = i + 1 {
    if self.targets[i] == target {
      return true
    }
  }
  false
}

///|
/// Returns the maximum row degree, useful for sizing sparse kernels.
pub fn CsrGraph::max_row_degree(self : CsrGraph) -> Int {
  let mut result = 0
  for row = 0; row < self.row_count(); row = row + 1 {
    let degree = self.row_degree(row)
    if degree > result {
      result = degree
    }
  }
  result
}

///|
/// Builds a compressed sparse row representation without changing the graph.
pub fn[N, E] Graph::to_csr(self : Graph[N, E]) -> CsrGraph {
  let offsets = [0]
  let targets = []
  for i = 0; i < self.node_count(); i = i + 1 {
    let neighbors = self.neighbors(NodeIndex::{ val: i })
    for j = 0; j < neighbors.length(); j = j + 1 {
      targets.push(neighbors[j].val)
    }
    offsets.push(targets.length())
  }
  { offsets, targets }
}

///|
/// Returns the dimension of the square adjacency matrix.
pub fn[N, E] Graph::adjacency_matrix_size(self : Graph[N, E]) -> Int {
  self.node_count() * self.node_count()
}

///|
/// Returns a dense 0/1 adjacency matrix in row-major order.
pub fn[N, E] Graph::adjacency_matrix(self : Graph[N, E]) -> Array[Int] {
  let n = self.node_count()
  let matrix = Array::make(n * n, 0)
  for i = 0; i < n; i = i + 1 {
    let neighbors = self.neighbors(NodeIndex::{ val: i })
    for j = 0; j < neighbors.length(); j = j + 1 {
      matrix[i * n + neighbors[j].val] = 1
    }
  }
  matrix
}

///|
/// Builds an adjacency matrix after masking inactive nodes.
pub fn[N, E] Graph::adjacency_matrix_checked(
  self : Graph[N, E],
  active : Array[Bool],
) -> Result[Array[Int], String] {
  if active.length() != self.node_count() {
    return Err("active mask length must equal node count")
  }
  let n = self.node_count()
  let matrix = self.adjacency_matrix()
  for i = 0; i < n; i = i + 1 {
    if !active[i] {
      for j = 0; j < n; j = j + 1 {
        matrix[i * n + j] = 0
        matrix[j * n + i] = 0
      }
    }
  }
  Ok(matrix)
}

///|
/// Returns outgoing degree for directed graphs and adjacency degree otherwise.
pub fn[N, E] Graph::degree_sequence(self : Graph[N, E]) -> Array[Int] {
  let result = []
  for i = 0; i < self.node_count(); i = i + 1 {
    result.push(self.out_degree(NodeIndex::{ val: i }))
  }
  for i = 0; i < result.length(); i = i + 1 {
    let mut best = i
    for j = i + 1; j < result.length(); j = j + 1 {
      if result[j] > result[best] {
        best = j
      }
    }
    if best != i {
      let value = result[i]
      result[i] = result[best]
      result[best] = value
    }
  }
  result
}
