///|
const RANK_SCALE : Int = 1000000

///|
/// Computes deterministic integer PageRank scores scaled to one million.
/// Dangling nodes distribute their score uniformly to all nodes.
pub fn[N, E] Graph::pagerank_scaled(
  self : Graph[N, E],
  iterations? : Int = 20,
  damping_scaled? : Int = 850000,
) -> Array[Int] {
  let count = self.node_count()
  if count == 0 {
    return []
  }
  let rounds = if iterations < 0 { 0 } else { iterations }
  let damping = if damping_scaled < 0 {
    0
  } else if damping_scaled > RANK_SCALE {
    RANK_SCALE
  } else {
    damping_scaled
  }
  let rank = Array::make(count, RANK_SCALE / count)
  rank[0] = rank[0] + RANK_SCALE - RANK_SCALE / count * count
  let mut round = 0
  while round < rounds {
    let next = Array::make(count, (RANK_SCALE - damping) / count)
    let mut dangling = 0
    for i = 0; i < count; i = i + 1 {
      let out = self.out_degree(NodeIndex::{ val: i })
      if out == 0 {
        dangling = dangling + rank[i]
      } else {
        let contribution = rank[i] * damping / out / RANK_SCALE
        let neighbors = self.neighbors(NodeIndex::{ val: i })
        for j = 0; j < neighbors.length(); j = j + 1 {
          next[neighbors[j].val] = next[neighbors[j].val] + contribution
        }
      }
    }
    let dangling_share = dangling * damping / RANK_SCALE / count
    for i = 0; i < count; i = i + 1 {
      next[i] = next[i] + dangling_share
    }
    let mut total = 0
    for i = 0; i < count; i = i + 1 {
      total = total + next[i]
    }
    if total < RANK_SCALE {
      next[0] = next[0] + RANK_SCALE - total
    } else if total > RANK_SCALE {
      next[0] = next[0] - (total - RANK_SCALE)
    }
    for i = 0; i < count; i = i + 1 {
      rank[i] = next[i]
    }
    round = round + 1
  }
  rank
}

///|
/// Returns nodes ordered by PageRank score, breaking ties by node index.
pub fn[N, E] Graph::pagerank_order(
  self : Graph[N, E],
  iterations? : Int = 20,
  damping_scaled? : Int = 850000,
) -> Array[NodeIndex] {
  let scores = self.pagerank_scaled(iterations~, damping_scaled~)
  let result : Array[NodeIndex] = []
  for i = 0; i < scores.length(); i = i + 1 {
    let node = NodeIndex::{ val: i }
    let mut inserted = false
    for j = 0; j < result.length(); j = j + 1 {
      let current = result[j]
      if scores[i] > scores[current.val] {
        result.insert(j, node)
        inserted = true
        break
      }
    }
    if !inserted {
      result.push(node)
    }
  }
  result
}
