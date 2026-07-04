# MoonGraph：基于 MoonBit 的高性能图论基础设施

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

> **OSC2026 参赛项目（第一赛道）** / **结项总结报告**
> 项目作者：权炜琨

在日常的业务开发和底层系统构建中，图（Graph）往往是用来描述复杂关系（如模块依赖、网络拓扑、寻路导航等）不可或缺的基石。然而，在目前快速发展的 MoonBit 生态里，开发者往往需要手写邻接表和基础遍历算法，缺乏一个像 Rust 的 `petgraph` 或是 Python 的 `NetworkX` 这样功能全面、性能可靠的通用图论基础库。

为了填补这一空白，**MoonGraph** 应运而生。它是一个完全采用 MoonBit 语言原生编写的高性能、强泛型图论核心库。MoonGraph 不依赖任何第三方外部包（Zero Dependencies），且在设计上充分利用了 MoonBit 优秀的类型系统，力求为开发者提供开箱即用、安全且高效的算法基础设施。

---

## 🚀 核心亮点

* **极致的泛型支持**：所有的 `Graph[N, E]` 均支持携带任意自定义类型的节点权重（`N`）与边权重（`E`），完美适配从简单的无权图到复杂的带有特定业务状态的路网图。
* **原生零依赖 (Zero Dependencies)**：100% 采用纯 MoonBit 编写，无论是构建 WebAssembly 还是本地 Native 目标，都能直接嵌入，无任何跨包负担。
* **类型安全与无缝编译**：代码在 `moon check` 阶段做到零警告（Zero Warnings），底层实现尽量避免了过度的装箱拆箱操作，数据流向清晰。
* **涵盖经典图论算法全家桶**：从最基础的 BFS/DFS，到经典的寻路、强连通分量识别，甚至内置了导出 Graphviz DOT 格式的可视化能力。

## 🛠️ 功能图谱与算法全景

MoonGraph 虽然小巧，但在算法的广度和深度上做得很扎实。以下是本库目前已稳定支持的核心特性：

### 1. 基础结构与存储
- **邻接表核心**：基于泛型动态数组构建的底层二元邻接表，支持快速查找、动态插入节点和边。
- **有向图 & 无向图兼容**：在初始化时通过参数 `directed=true/false` 轻松切换底层构建逻辑。

### 2. 图的遍历与连通性
- **BFS (广度优先)** & **DFS (深度优先)**：图论的基础遍历支撑，支持状态收集与路径回溯。
- **Tarjan SCC**：借助经典的 Tarjan 算法以 $O(V+E)$ 的时间复杂度快速找出有向图中的强连通分量（Strongly Connected Components）。
- **环检测 (Cycle Detection)**：快速诊断图中是否存在闭环，是编译器中循环引用检测和死锁分析的核心组件。

### 3. 最短路径与寻路规划
- **Dijkstra**：适用于无负权边的经典单源最短路径。项目中自己手写了基于二叉堆的高性能 `PriorityQueue`，运行效率极高。
- **A* (A-Star) 启发式搜索**：支持传入自定义的估价启发式函数，非常适合游戏开发和地图网格路网的高级寻路场景。
- **Bellman-Ford**：专门应对带有负权边的特殊场景，并内置了**负权环预警**机制，防范异常路网导致的死循环。

### 4. 拓扑与树结构
- **Kahn 拓扑排序**：有向无环图（DAG）的杀手锏算法，可以用来快速生成构建任务的执行序列。
- **Kruskal 最小生成树 (MST)**：利用内部稳健的 `DisjointSet`（并查集）数据结构，以最优时间复杂度计算全局的最小生成树。

### 5. 可视化辅助
- **Graphviz DOT 导出**：自带 `to_dot()` 函数，一键导出可以通过 Graphviz 渲染的文本。在排查图结构 BUG 时，能让你一眼看穿全貌。

---

## 📖 快速上手指南

MoonGraph 的 API 设计非常直观且符合使用直觉，以下是几个常见场景的示例。

### 创建图与基础操作

```moonbit
// 创建一个节点数据类型为 String，边权重类型为 Int 的有向图
let g: Graph[String, Int] = Graph::new(directed=true)

// 添加节点，返回该节点的内部唯一索引
let a = g.add_node("A")
let b = g.add_node("B")
let c = g.add_node("C")

// 建立带有权重的边
g.add_edge(a, b, 10)
g.add_edge(b, c, 15)

// 基础遍历调用
let bfs_result = g.bfs(a)
```

### 最短路径计算

对于非负权图，可以直接使用经典的 Dijkstra：

```moonbit
let distances = g.dijkstra(a)
// distances 中保存了节点 'a' 到其他所有连通节点的最短带权距离
```

如果你是在开发带有网格坐标的业务，可以尝试带启发函数的 A* 算法：

```moonbit
// 传入启发函数（例如根据坐标计算曼哈顿距离或欧几里得距离）
let heuristic = fn(node) { 0 /* 在此实现具体的距离预估 */ }
let path = g.a_star(a, c, heuristic)
```

### 拓扑排序与连通分量

在解决依赖解析或者编译器模块分析问题时非常有用：

```moonbit
// 尝试获取拓扑执行序
let sorted_nodes = g.topological_sort()

// 获取所有的强连通分量 (SCC)
let components = g.tarjan_scc()
```

---

## 🧪 测试与质量保证

作为一个底层的基础设施，稳健性是重中之重。我在项目内部编写了完整的自动化单元测试（参考 `src/graph_test.mbt`），包含十多组不同场景的边界测试，覆盖了从简单的权重连通到复杂的带负权成环等多种极端拓扑环境。同时确保了算法在执行过程中具备极低的内存占用和良好的垃圾回收表现。

---

## 🔮 未来演进与展望

目前的 MoonGraph 已经具备了处理日常绝大部分图论需求的能力，作为本次 OSC2026 第一赛道的参赛作品，我已经将其打磨到了相对成熟的状态。未来我还计划继续维护，为其加入：
- **Floyd-Warshall 算法**：解决全节点全源的最短路径问题。
- **最大流 / 最小割 (Ford-Fulkerson)**：丰富网络流方向的算法储备。
- **图同构识别与子图匹配**：进一步提升库在复杂特征分析中的潜力。

希望这个库能为 MoonBit 生态的繁荣添砖加瓦！感谢本届比赛组委会提供的平台，如果你觉得这个项目还不错，欢迎为我点亮 Star 或是交流探讨。

---
*License: MIT | Written with 💙 in MoonBit*
