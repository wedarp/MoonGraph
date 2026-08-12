///|
/// A reusable single-source routing table for weighted integer graphs.
pub struct RouteTable {
  source : NodeIndex
  distances : Array[Int]
  predecessors : Array[Int]
}

///|
pub fn RouteTable::source(self : RouteTable) -> NodeIndex {
  self.source
}

///|
pub fn RouteTable::distances(self : RouteTable) -> Array[Int] {
  self.distances
}

///|
pub fn RouteTable::distance(self : RouteTable, target : NodeIndex) -> Int {
  if target.val < 0 || target.val >= self.distances.length() {
    2147483647
  } else {
    self.distances[target.val]
  }
}

///|
/// Reconstructs a shortest route from the table, or returns an empty array.
pub fn RouteTable::route_to(
  self : RouteTable,
  target : NodeIndex,
) -> Array[NodeIndex] {
  if target.val < 0 ||
    target.val >= self.distances.length() ||
    self.distances[target.val] == 2147483647 {
    return []
  }
  let result = []
  let mut current = target.val
  let mut steps = 0
  while current >= 0 && steps <= self.distances.length() {
    result.push(NodeIndex::{ val: current })
    current = self.predecessors[current]
    steps = steps + 1
  }
  if current >= 0 {
    return []
  }
  reverse_array(result)
  result
}

///|
/// Builds a Dijkstra routing table and records predecessor information.
pub fn[N] build_route_table(
  graph : Graph[N, Int],
  source : NodeIndex,
) -> RouteTable {
  let count = graph.node_count()
  let distances = Array::make(count, 2147483647)
  let predecessors = Array::make(count, -1)
  if !graph.contains_node(source) {
    return { source, distances, predecessors }
  }
  distances[source.val] = 0
  let queue : PriorityQueue[Int, NodeIndex] = PriorityQueue::new()
  queue.push(0, source)
  while !queue.is_empty() {
    let current = queue.pop().unwrap()
    let current_distance = distances[current.val]
    let neighbors = graph.neighbors(current)
    for i = 0; i < neighbors.length(); i = i + 1 {
      let next = neighbors[i]
      let weight = graph.edge_weight_between(current, next).unwrap()
      if weight < 0 {
        continue
      }
      let candidate = current_distance + weight
      if candidate < distances[next.val] {
        distances[next.val] = candidate
        predecessors[next.val] = current.val
        queue.push(candidate, next)
      }
    }
  }
  { source, distances, predecessors }
}

///|
/// Returns the minimum edge capacity along the widest path from a source.
pub fn[N] Graph::widest_path_capacities(
  self : Graph[N, Int],
  source : NodeIndex,
) -> Array[Int] {
  let capacities = Array::make(self.node_count(), 0)
  if !self.contains_node(source) {
    return capacities
  }
  capacities[source.val] = 2147483647
  let queue : PriorityQueue[Int, NodeIndex] = PriorityQueue::new()
  queue.push(-capacities[source.val], source)
  while !queue.is_empty() {
    let current = queue.pop().unwrap()
    let current_capacity = capacities[current.val]
    let neighbors = self.neighbors(current)
    for i = 0; i < neighbors.length(); i = i + 1 {
      let next = neighbors[i]
      let edge_capacity = self.edge_weight_between(current, next).unwrap()
      if edge_capacity < 0 {
        continue
      }
      let candidate = if current_capacity < edge_capacity {
        current_capacity
      } else {
        edge_capacity
      }
      if candidate > capacities[next.val] {
        capacities[next.val] = candidate
        queue.push(-candidate, next)
      }
    }
  }
  capacities
}

///|
/// Computes unweighted distances from several sources in one BFS.
pub fn[N, E] Graph::multi_source_bfs_distances(
  self : Graph[N, E],
  sources : Array[NodeIndex],
) -> Array[Int] {
  let distances = Array::make(self.node_count(), 2147483647)
  let queue = []
  for i = 0; i < sources.length(); i = i + 1 {
    let source = sources[i]
    if self.contains_node(source) && distances[source.val] == 2147483647 {
      distances[source.val] = 0
      queue.push(source)
    }
  }
  let mut head = 0
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    let neighbors = self.neighbors(current)
    for i = 0; i < neighbors.length(); i = i + 1 {
      let next = neighbors[i]
      if distances[next.val] == 2147483647 {
        distances[next.val] = distances[current.val] + 1
        queue.push(next)
      }
    }
  }
  distances
}

///|
/// Returns the source and all nodes at most a given number of hops away.
pub fn[N, E] Graph::k_hop_neighborhood(
  self : Graph[N, E],
  source : NodeIndex,
  hops : Int,
) -> Array[NodeIndex] {
  if hops < 0 {
    return []
  }
  let distances = self.bfs_distances(source)
  let result = []
  for i = 0; i < distances.length(); i = i + 1 {
    if distances[i] <= hops {
      result.push(NodeIndex::{ val: i })
    }
  }
  result
}

///|
fn[N, E] Graph::edge_weight_between(
  self : Graph[N, E],
  source : NodeIndex,
  target : NodeIndex,
) -> E? {
  if !self.contains_node(source) {
    return None
  }
  let mut edge = self.nodes[source.val].first_outgoing_edge
  while true {
    match edge {
      None => return None
      Some(edge_index) => {
        let data = self.edges[edge_index.val]
        if data.target_node.val == target.val {
          return Some(data.weight)
        }
        edge = data.next_outgoing_edge
      }
    }
  }
  None
}
