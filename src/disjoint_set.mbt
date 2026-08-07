///|
/// Disjoint Set (Union-Find) data structure
pub struct DisjointSet {
  parent : Array[Int]
  rank : Array[Int]
}

///|
/// Creates a new DisjointSet with `size` elements (0 to size-1).
pub fn DisjointSet::new(size : Int) -> DisjointSet {
  let parent = Array::make(size, 0)
  let rank = Array::make(size, 0)
  for i = 0; i < size; i = i + 1 {
    parent[i] = i
  }
  { parent, rank }
}

///|
/// Finds the representative of the set that contains `i`.
/// Uses path compression.
pub fn DisjointSet::find(self : DisjointSet, i : Int) -> Int {
  if self.parent[i] == i {
    i
  } else {
    let root = self.find(self.parent[i])
    self.parent[i] = root
    root
  }
}

///|
/// Unions the sets that contain `i` and `j`.
/// Returns `true` if they were in different sets and merged, `false` otherwise.
/// Uses union by rank.
pub fn DisjointSet::union(self : DisjointSet, i : Int, j : Int) -> Bool {
  let root_i = self.find(i)
  let root_j = self.find(j)
  if root_i != root_j {
    if self.rank[root_i] < self.rank[root_j] {
      self.parent[root_i] = root_j
    } else if self.rank[root_i] > self.rank[root_j] {
      self.parent[root_j] = root_i
    } else {
      self.parent[root_j] = root_i
      self.rank[root_i] = self.rank[root_i] + 1
    }
    true
  } else {
    false
  }
}
