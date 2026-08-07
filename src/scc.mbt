///|
priv struct TarjanState {
  mut index : Int
  indices : Array[Int]
  lowlink : Array[Int]
  on_stack : Array[Bool]
  stack : Array[NodeIndex]
  sccs : Array[Array[NodeIndex]]
}

///|
/// Tarjan's Strongly Connected Components (SCC) algorithm.
/// Returns an array of SCCs, where each SCC is an array of `NodeIndex`.
pub fn[N, E] Graph::tarjan_scc(self : Graph[N, E]) -> Array[Array[NodeIndex]] {
  let num_nodes = self.nodes.length()
  let state = {
    index: 0,
    indices: Array::make(num_nodes, -1),
    lowlink: Array::make(num_nodes, -1),
    on_stack: Array::make(num_nodes, false),
    stack: [],
    sccs: [],
  }

  for i = 0; i < num_nodes; i = i + 1 {
    if state.indices[i] == -1 {
      self.strongconnect(NodeIndex::{ val: i }, state)
    }
  }

  state.sccs
}

///|
fn[N, E] Graph::strongconnect(
  self : Graph[N, E],
  v : NodeIndex,
  state : TarjanState,
) -> Unit {
  state.indices[v.val] = state.index
  state.lowlink[v.val] = state.index
  state.index = state.index + 1
  state.stack.push(v)
  state.on_stack[v.val] = true

  let nbrs = self.neighbors(v)
  for i = 0; i < nbrs.length(); i = i + 1 {
    let w = nbrs[i]
    if state.indices[w.val] == -1 {
      self.strongconnect(w, state)
      if state.lowlink[w.val] < state.lowlink[v.val] {
        state.lowlink[v.val] = state.lowlink[w.val]
      }
    } else if state.on_stack[w.val] {
      if state.indices[w.val] < state.lowlink[v.val] {
        state.lowlink[v.val] = state.indices[w.val]
      }
    }
  }

  if state.lowlink[v.val] == state.indices[v.val] {
    let scc = []
    while true {
      let w = state.stack.pop().unwrap()
      state.on_stack[w.val] = false
      scc.push(w)
      if w.val == v.val {
        break
      }
    }
    state.sccs.push(scc)
  }
}
