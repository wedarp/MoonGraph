///|
struct PQElement[K, V] {
  priority : K
  value : V
}

///|
pub struct PriorityQueue[K, V] {
  data : Array[PQElement[K, V]]
}

///|
pub fn[K, V] PriorityQueue::new() -> PriorityQueue[K, V] {
  { data: [] }
}

///|
pub fn[K : Compare, V] PriorityQueue::push(
  self : PriorityQueue[K, V],
  priority : K,
  value : V,
) -> Unit {
  self.data.push({ priority, value })
  self.sift_up(self.data.length() - 1)
}

///|
pub fn[K : Compare, V] PriorityQueue::pop(self : PriorityQueue[K, V]) -> V? {
  if self.data.length() == 0 {
    return None
  }
  let result = self.data[0].value
  let last = self.data.pop().unwrap()
  if self.data.length() > 0 {
    self.data[0] = last
    self.sift_down(0)
  }
  Some(result)
}

///|
pub fn[K, V] PriorityQueue::is_empty(self : PriorityQueue[K, V]) -> Bool {
  self.data.length() == 0
}

///|
fn[K : Compare, V] PriorityQueue::sift_up(
  self : PriorityQueue[K, V],
  index : Int,
) -> Unit {
  let mut i = index
  while i > 0 {
    let parent = (i - 1) / 2
    if self.data[i].priority < self.data[parent].priority {
      let temp = self.data[i]
      self.data[i] = self.data[parent]
      self.data[parent] = temp
      i = parent
    } else {
      break
    }
  }
}

///|
fn[K : Compare, V] PriorityQueue::sift_down(
  self : PriorityQueue[K, V],
  index : Int,
) -> Unit {
  let len = self.data.length()
  let mut i = index
  while true {
    let left = 2 * i + 1
    let right = 2 * i + 2
    let mut smallest = i

    if left < len && self.data[left].priority < self.data[smallest].priority {
      smallest = left
    }
    if right < len && self.data[right].priority < self.data[smallest].priority {
      smallest = right
    }

    if smallest != i {
      let temp = self.data[i]
      self.data[i] = self.data[smallest]
      self.data[smallest] = temp
      i = smallest
    } else {
      break
    }
  }
}
