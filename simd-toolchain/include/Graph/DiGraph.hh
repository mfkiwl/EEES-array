#ifndef ES_SIMD_DIGRAPH_HH
#define ES_SIMD_DIGRAPH_HH

#include "Graph/GraphDefs.hh"
#include <lemon/list_graph.h>
#include <lemon/bfs.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#include <lemon/connectivity.h>
#pragma clang diagnostic pop

#include <tr1/unordered_map>
#include <tr1/unordered_set>
#include <string>

namespace ES_SIMD {
  typedef lemon::ListDigraph::Node DiGraphNode;
  typedef lemon::ListDigraph::Arc  DiGraphEdge;
  typedef lemon::ListDigraph::NodeMap<int> DiGraphNodeIntMap;
  /// Basically a wrapper of ListDigraph and some node/arc maps in LEMON
  template<typename NodePropertyType, typename EdgePropertyType>
  class DiGraph {
  protected:
    lemon::ListDigraph                            digraph_;
    lemon::ListDigraph::NodeMap<NodePropertyType> nodeProperty_;
    lemon::ListDigraph::ArcMap<EdgePropertyType>  edgeProperty_;
  public:
    typedef lemon::ListDigraph::NodeIt iterator;
    typedef const iterator const_iterator;
    typedef lemon::ListDigraph::ArcIt edge_iterator;
    typedef const edge_iterator edge_const_iterator;
    typedef lemon::ListDigraph::OutArcIt out_edge_iterator;
    typedef const out_edge_iterator out_edge_const_iterator;
    typedef lemon::ListDigraph::InArcIt in_edge_iterator;
    typedef const in_edge_iterator in_edge_const_iterator;
    typedef lemon::ListDigraph::NodeMap<int> NodeIntMap;

    DiGraph() : nodeProperty_(digraph_), edgeProperty_(digraph_) {}
    DiGraph(const DiGraph& gr)
      : nodeProperty_(digraph_),edgeProperty_(digraph_) {
      lemon::digraphCopy(gr.digraph_, digraph_)
        .nodeMap(gr.nodeProperty_, nodeProperty_)
        .nodeMap(gr.edgeProperty_,  edgeProperty_).run();
    }
    ~DiGraph() {}

    const lemon::ListDigraph& GetGraph() const { return digraph_; }

    void DrawDOT(std::ostream& o, const std::string& name) const;

    bool IsDAG() const { return lemon::dag(digraph_); }

    DiGraphNode AddNode() { return digraph_.addNode(); }
    DiGraphNode AddNode(const NodePropertyType& np) {
      DiGraphNode u = digraph_.addNode();
      nodeProperty_[u] = np;
      return u;
    }
    void RemoveNode(DiGraphNode u) {
      if (digraph_.valid(u)) {
        digraph_.erase(u);
      }
    }
    DiGraphEdge AddEdge(DiGraphNode s, DiGraphNode t,
                       const EdgePropertyType& ep) {
      DiGraphEdge e = digraph_.addArc(s, t);
      edgeProperty_[e] = ep;
      return e;
    }
    DiGraphEdge AddEdge(DiGraphNode s, DiGraphNode t) {
      return digraph_.addArc(s, t);
    }
    void RemoveEdge(DiGraphEdge e) {
      if (digraph_.valid(e)) {
        digraph_.erase(e);
      }
    }

    DiGraphEdge FindEdge(DiGraphNode s, DiGraphNode t) const {
      return lemon::findArc(digraph_, s, t);
    }
    bool HasEdge(DiGraphNode s, DiGraphNode t) const {
      return (FindEdge(s, t) != lemon::INVALID);
    }

    bool Valid(DiGraphNode u) const { return digraph_.valid(u); }
    bool Valid(DiGraphEdge e) const { return digraph_.valid(e); }

    inline int  InDegree(DiGraphNode u) const {
      return digraph_.valid(u) ? countInArcs(digraph_, u) : 0;
    }
    inline int  OutDegree(DiGraphNode u) const {
      return digraph_.valid(u) ? countOutArcs(digraph_, u) : 0;
    }

    NodePropertyType& operator[](DiGraphNode u) {
      return nodeProperty_[u];
    }
    const NodePropertyType& operator[](DiGraphNode u) const {
      return nodeProperty_[u];
    }

    EdgePropertyType& operator[](DiGraphEdge e) {
      return edgeProperty_[e];
    }
    const EdgePropertyType& operator[](DiGraphEdge e) const {
      return edgeProperty_[e];
    }

    DiGraphNode operator[](int id) const {
      return digraph_.nodeFromId(id);
    }

    DiGraphNode GetSource(DiGraphEdge e) {
      return digraph_.valid(e) ? digraph_.source(e) : lemon::INVALID;
    }
    const DiGraphNode GetSource(DiGraphEdge e) const {
      return digraph_.valid(e) ? digraph_.source(e) : lemon::INVALID;
    }

    DiGraphNode GetTarget(DiGraphEdge e) {
      return digraph_.valid(e) ? digraph_.target(e) : lemon::INVALID;
    }
    const DiGraphNode GetTarget(DiGraphEdge e) const {
      return digraph_.valid(e) ? digraph_.target(e) : lemon::INVALID;
    }

    /// \brief If there is a path from s to t
    bool Reachable(DiGraphNode s, DiGraphNode t) const {
      if (!Valid(s) || !Valid(t)) { return false; }
      if (HasEdge(s, t)) { return true; }
      lemon::Bfs<lemon::ListDigraph> bfs(digraph_);
      bfs.run(s,t);
      return bfs.reached(t);
    }

    // Container interface and iterators
    size_t  size() const  { return lemon::countNodes(digraph_); }
    bool    empty() const { return size() == 0; }
    void    clear()       { digraph_.clear(); }
    void    reserve(int n){ digraph_.reserveNode(n); }
    iterator       begin()       {return lemon::ListDigraph::NodeIt(digraph_);}
    const_iterator begin() const {return lemon::ListDigraph::NodeIt(digraph_);}
    iterator       end()         {return lemon::INVALID; }
    const_iterator end()   const {return lemon::INVALID; }

    size_t  edge_size() const  { return lemon::countArcs(digraph_); }
    bool    edge_empty() const { return edge_size() == 0; }
    edge_iterator       edge_begin() {
      return lemon::ListDigraph::ArcIt(digraph_);
    }
    edge_const_iterator edge_begin() const {
      return lemon::ListDigraph::ArcIt(digraph_);
    }
    edge_iterator       edge_end()         { return lemon::INVALID; }
    edge_const_iterator edge_end()   const { return lemon::INVALID; }

    out_edge_iterator out_edge_begin(DiGraphNode u) {
      return lemon::ListDigraph::OutArcIt(digraph_, u);
    }
    out_edge_const_iterator out_edge_begin(DiGraphNode u) const {
      return lemon::ListDigraph::OutArcIt(digraph_, u);
    }
    out_edge_iterator out_edge_end(DiGraphNode u) { return lemon::INVALID; }
    out_edge_const_iterator out_edge_end(DiGraphNode u) const {
      return lemon::INVALID;
    }

    in_edge_iterator in_edge_begin(DiGraphNode u) {
      return lemon::ListDigraph::InArcIt(digraph_, u);
    }
    in_edge_const_iterator in_edge_begin(DiGraphNode u) const {
      return lemon::ListDigraph::InArcIt(digraph_, u);
    }
    in_edge_iterator in_edge_end(DiGraphNode u) { return lemon::INVALID; }
    in_edge_const_iterator in_edge_end(DiGraphNode u) const {
      return lemon::INVALID;
    }
  };// class DiGraph

  template<typename NodePropertyType, typename EdgePropertyType>
  void DiGraph<NodePropertyType, EdgePropertyType>::
  DrawDOT(std::ostream& o, const std::string& name) const{
    o << "digraph "<< name <<" {\n    node [fontsize = \"12\"];\n\n";
    for (iterator u = begin(); u != end(); ++u) {
      const NodePropertyType& np = nodeProperty_[u];
      o <<"    node"<< digraph_.id(u) <<" [ label=\""<< np <<"\",shape=ellipse";
      if (nodeProperty_[u].Shaded()) {
        o << ",style=filled, fillcolor=lightblue";
      }
      o <<"];\n";
    }// for iterator u
    for (edge_iterator e = edge_begin(); e != edge_end(); ++e) {
      const EdgePropertyType ep = edgeProperty_[e];
      if (ep.Hide()) { continue; }
      DiGraphNode s = digraph_.source(e);
      DiGraphNode t = digraph_.target(e);
      o <<"    node"<< digraph_.id(s) <<"->node"<< digraph_.id(t)<<"[label=\""
        << ep <<"\"";
      LineStyle ls = ep.GetStyle();
      if (ls == LS_Dashed)
        o <<", style=\"dashed\"";
      o << "]\n";
    }// for ArcIt e(digraph)
    o << "}\n";
  }
};// namespace ES_SIMD

#endif//ES_SIMD_DIGRAPH_HH
