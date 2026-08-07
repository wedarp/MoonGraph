///|
/// Computes a maximum matching between explicit left and right node sets.
/// The graph's outgoing adjacency is used as the allowed relation.
/// Returned entries are [left_node, right_node] pairs.
pub fn[N, E] Graph::maximum_bipartite_matching(
  self : Graph[N, E],
  left : Array[NodeIndex],
  right : Array[NodeIndex],
) -> Array[Array[NodeIndex]] {
  let matched_right = Array::make(right.length(), None)
  for i = 0; i < left.length(); i = i + 1 {
    let seen = Array::make(right.length(), false)
    let _ = self.try_match(left[i], right, matched_right, seen)
  }
  let pairs = []
  for i = 0; i < right.length(); i = i + 1 {
    match matched_right[i] {
      None => ()
      Some(left_node) => pairs.push([left_node, right[i]])
    }
  }
  pairs
}

///|
fn[N, E] Graph::try_match(
  self : Graph[N, E],
  left_node : NodeIndex,
  right : Array[NodeIndex],
  matched_right : Array[NodeIndex?],
  seen : Array[Bool],
) -> Bool {
  let neighbors = self.neighbors(left_node)
  for i = 0; i < neighbors.length(); i = i + 1 {
    let neighbor = neighbors[i]
    let mut right_position = -1
    for j = 0; j < right.length(); j = j + 1 {
      if right[j].val == neighbor.val {
        right_position = j
        break
      }
    }
    if right_position == -1 || seen[right_position] {
      continue
    }
    seen[right_position] = true
    match matched_right[right_position] {
      None => {
        matched_right[right_position] = Some(left_node)
        return true
      }
      Some(previous_left) =>
        if self.try_match(previous_left, right, matched_right, seen) {
          matched_right[right_position] = Some(left_node)
          return true
        }
    }
  }
  false
}
