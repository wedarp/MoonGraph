///|
/// A build, deployment, or data-processing task represented in a dependency DAG.
pub struct Task {
  name : String
  duration : Int
}

///|
pub fn Task::new(name : String, duration : Int) -> Task {
  { name, duration }
}

///|
pub fn Task::name(self : Task) -> String {
  self.name
}

///|
pub fn Task::duration(self : Task) -> Int {
  self.duration
}

///|
/// The deterministic earliest-start schedule of a dependency graph.
pub struct TaskPlan {
  order : Array[NodeIndex]
  start_times : Array[Int]
  finish_times : Array[Int]
  critical_path : Array[NodeIndex]
  makespan : Int
}

///|
pub fn TaskPlan::order(self : TaskPlan) -> Array[NodeIndex] {
  self.order
}

///|
pub fn TaskPlan::start_times(self : TaskPlan) -> Array[Int] {
  self.start_times
}

///|
pub fn TaskPlan::finish_times(self : TaskPlan) -> Array[Int] {
  self.finish_times
}

///|
pub fn TaskPlan::critical_path(self : TaskPlan) -> Array[NodeIndex] {
  self.critical_path
}

///|
pub fn TaskPlan::makespan(self : TaskPlan) -> Int {
  self.makespan
}

///|
/// Builds a dependency graph. Each inner array lists prerequisite task indices.
pub fn build_dependency_graph(
  tasks : Array[Task],
  dependencies : Array[Array[Int]],
) -> Result[Graph[Task, Int], String] {
  if tasks.length() != dependencies.length() {
    return Err("task and dependency lengths differ")
  }
  for i = 0; i < tasks.length(); i = i + 1 {
    if tasks[i].duration < 0 {
      return Err("task duration cannot be negative")
    }
  }
  let graph : Graph[Task, Int] = Graph::new(directed=true)
  for i = 0; i < tasks.length(); i = i + 1 {
    let _ = graph.add_node(tasks[i])
  }
  for target = 0; target < dependencies.length(); target = target + 1 {
    let prerequisites = dependencies[target]
    for i = 0; i < prerequisites.length(); i = i + 1 {
      let source = prerequisites[i]
      if source < 0 || source >= tasks.length() {
        return Err("dependency index is out of range")
      }
      if source == target {
        return Err("task cannot depend on itself")
      }
      let _ = graph.add_edge(
        NodeIndex::{ val: source },
        NodeIndex::{ val: target },
        0,
      )
    }
  }
  Ok(graph)
}

///|
/// Computes earliest start/finish times and one critical path.
pub fn schedule_tasks(graph : Graph[Task, Int]) -> Result[TaskPlan, String] {
  let order = match graph.topological_sort() {
    None => return Err("dependency graph contains a cycle")
    Some(value) => value
  }
  let starts = Array::make(graph.node_count(), 0)
  let finishes = Array::make(graph.node_count(), 0)
  let predecessor = Array::make(graph.node_count(), -1)
  let mut makespan = 0
  for position = 0; position < order.length(); position = position + 1 {
    let current = order[position]
    let mut best_start = 0
    let mut best_predecessor = -1
    for source = 0; source < graph.node_count(); source = source + 1 {
      let neighbors = graph.neighbors(NodeIndex::{ val: source })
      for i = 0; i < neighbors.length(); i = i + 1 {
        if neighbors[i].val == current.val && finishes[source] > best_start {
          best_start = finishes[source]
          best_predecessor = source
        }
      }
    }
    starts[current.val] = best_start
    let task = graph.node_weight(current).unwrap()
    finishes[current.val] = best_start + task.duration
    predecessor[current.val] = best_predecessor
    if finishes[current.val] > makespan {
      makespan = finishes[current.val]
    }
  }
  let critical_path = []
  if order.length() > 0 {
    let mut tail = order[0].val
    for i = 1; i < order.length(); i = i + 1 {
      if finishes[order[i].val] > finishes[tail] {
        tail = order[i].val
      }
    }
    while tail >= 0 {
      critical_path.push(NodeIndex::{ val: tail })
      tail = predecessor[tail]
    }
    reverse_array(critical_path)
  }
  Ok({
    order,
    start_times: starts,
    finish_times: finishes,
    critical_path,
    makespan,
  })
}
