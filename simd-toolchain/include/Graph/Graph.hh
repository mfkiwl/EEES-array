#ifndef ES_SIMD_GRAPH_HH
#define ES_SIMD_GRAPH_HH

#include "Graph/GraphDefs.hh"
#include <lemon/list_graph.h>
#include <lemon/connectivity.h>
#include <tr1/unordered_map>
#include <tr1/unordered_set>
#include <string>

namespace ES_SIMD {
  typedef lemon::ListGraph::Node GraphNode;
  typedef lemon::ListGraph::Edge GraphEdge;
  /// Basically a wrapper of ListGraph and some node/arc maps in LEMON
  template<typename NodePropertyType, typename EdgePropertyType>
  class Graph {
  protected:
    lemon::ListGraph                            graph_;
    lemon::ListGraph::NodeMap<NodePropertyType> nodeProperty_;
    lemon::ListGraph::ArcMap<EdgePropertyType>  edgeProperty_;
  public:
    typedef lemon::ListGraph::NodeIt    iterator;
    typedef const iterator              const_iterator;
    typedef lemon::ListGraph::EdgeIt    edge_iterator;
    typedef const edge_iterator         edge_const_iterator;
    typedef lemon::ListGraph::IncEdgeIt inc_edge_iterator;
    typedef const inc_edge_iterator     inc_edge_const_iterator;
    typedef lemon::ListGraph::NodeMap<int> NodeIntMap;

    Graph() : nodeProperty_(graph_), edgeProperty_(graph_) {}
    Graph(const Graph& gr)
      : nodeProperty_(graph_),edgeProperty_(graph_) {
      lemon::digraphCopy(gr.graph_, graph_)
        .nodeMap(gr.nodeProperty_, nodeProperty_)
        .nodeMap(gr.edgeProperty_,  edgeProperty_).run();
    }
    ~Graph() {}

    const lemon::ListGraph& GetGraph() const { return graph_; }

    void DrawDOT(std::ostream& o, const std::string& name) const;

    GraphNode AddNode() { return graph_.addNode(); }
    GraphNode AddNode(const NodePropertyType& np) {
      GraphNode u = graph_.addNode();
      nodeProperty_[u] = np;
      return u;
    }
    void RemoveNode(GraphNode u) {
      if (graph_.valid(u)) {
        graph_.erase(u);
      }
    }
    GraphEdge AddEdge(GraphNode u, GraphNode v,
                       const EdgePropertyType& ep) {
      GraphEdge e = graph_.addEdge(u, v);
      edgeProperty_[e] = ep;
      return e;
    }
    GraphEdge AddEdge(GraphNode u, GraphNode v) {
      return graph_.addEdge(u, v);
    }
    void RemoveEdge(GraphEdge e) {
      if (graph_.valid(e)) {
        graph_.erase(e);
      }
    }

    GraphEdge FindEdge(GraphNode u, GraphNode v) const {
      return lemon::findEdge(graph_, u, v);
    }
    bool HasEdge(GraphNode u, GraphNode v) const {
      return (FindEdge(u, v) != lemon::INVALID);
    }

    bool Valid(GraphNode u) const { return graph_.valid(u); }
    bool Valid(GraphEdge e) const { return graph_.valid(e); }

    inline int  Degree(GraphNode u) const {
      return graph_.valid(u) ? countIncEdges(graph_, u) : 0;
    }

    NodePropertyType& operator[](GraphNode u) {
      return nodeProperty_[u];
    }
    const NodePropertyType& operator[](GraphNode u) const {
      return nodeProperty_[u];
    }

    EdgePropertyType& operator[](GraphEdge e) {
      return edgeProperty_[e];
    }
    const EdgePropertyType& operator[](GraphEdge e) const {
      return edgeProperty_[e];
    }

    GraphNode operator[](int id) const {
      return graph_.nodeFromId(id);
    }
    GraphNode GetU(GraphEdge e) {
      return graph_.valid(e) ? graph_.u(e) : lemon::INVALID;
    }
    const GraphNode GetU(GraphEdge e) const {
      return graph_.valid(e) ? graph_.u(e) : lemon::INVALID;
    }
    GraphNode GetV(GraphEdge e) {
      return graph_.valid(e) ? graph_.v(e) : lemon::INVALID;
    }
    const GraphNode GetV(GraphEdge e) const {
      return graph_.valid(e) ? graph_.v(e) : lemon::INVALID;
    }
    const GraphNode OppositeNode (GraphNode u, GraphEdge e) const {
      return graph_.oppositeNode(u, e);
    }

    // Container interface and iterators
    size_t  size() const  { return lemon::countNodes(graph_); }
    bool    empty() const { return size() == 0; }
    void    clear()       { graph_.clear(); }
    void    reserve(int n){ graph_.reserveNode(n); }
    iterator       begin()       {return lemon::ListGraph::NodeIt(graph_);}
    const_iterator begin() const {return lemon::ListGraph::NodeIt(graph_);}
    iterator       end()         {return lemon::INVALID; }
    const_iterator end()   const {return lemon::INVALID; }

    size_t  edge_size() const  { return lemon::countEdges(graph_); }
    bool    edge_empty() const { return edge_size() == 0; }
    edge_iterator       edge_begin() {
      return lemon::ListGraph::EdgeIt(graph_);
    }
    edge_const_iterator edge_begin() const {
      return lemon::ListGraph::EdgeIt(graph_);
    }
    edge_iterator       edge_end()         { return lemon::INVALID; }
    edge_const_iterator edge_end()   const { return lemon::INVALID; }

    inc_edge_iterator inc_edge_begin(GraphNode u) {
      return lemon::ListGraph::IncEdgeIt(graph_, u);
    }
    inc_edge_const_iterator inc_edge_begin(GraphNode u) const {
      return lemon::ListGraph::IncEdgeIt(graph_, u);
    }
    inc_edge_iterator inc_edge_end(GraphNode u) { return lemon::INVALID; }
    inc_edge_const_iterator inc_edge_end(GraphNode u) const {
      return lemon::INVALID;
    }
  };// class Graph

  template<typename NodePropertyType, typename EdgePropertyType>
  void Graph<NodePropertyType, EdgePropertyType>::
  DrawDOT(std::ostream& o, const std::string& name) const{
    o << "graph "<< name <<" {\n    node [fontsize = \"12\"];\n\n";
    for (iterator u = begin(); u != end(); ++u) {
      const NodePropertyType& np = nodeProperty_[u];
      o <<"    node"<< graph_.id(u) <<" [ label=\""<< np <<"\",shape=ellipse";
      if (nodeProperty_[u].Shaded()) {
        o << ",style=filled, fillcolor=lightblue";
      }
      o <<"];\n";
    }// for iterator u
    for (edge_iterator e = edge_begin(); e != edge_end(); ++e) {
      const EdgePropertyType ep = edgeProperty_[e];
      if (ep.Hide()) {
        continue;
      }
      GraphNode s = graph_.u(e);
      GraphNode t = graph_.v(e);
      o <<"    node"<< graph_.id(s) <<"--node"<< graph_.id(t)<<"[label=\""
        << ep <<"\"";
      LineStyle ls = ep.GetStyle();
      if (ls == LS_Dashed)
        o <<", style=\"dashed\"";
      o << "]\n";
    }// for ArcIt e(digraph)
    o << "}\n";
  }
};// namespace ES_SIMD

#endif//ES_SIMD_GRAPH_HH
