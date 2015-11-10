#ifndef ES_SIMD_GENERICTREE_HH
#define ES_SIMD_GENERICTREE_HH

#include <list>
#include <set>
#include <deque>
#include <iostream>

namespace ES_SIMD {

  /// \brief A generic n-ary tree structure
  template<typename Ty>
  class GenericTree {
  public:
    class Node;
  private:
    Node* root_;
  public:
    GenericTree() :root_(NULL) {}
    GenericTree(Ty& t);
    ~GenericTree();
    Node*&       Root()       { return root_; }
    const Node*& Root() const { return root_; }
    /// \brief Get the number of nodes in the tree.
    size_t TreeSize() const { return root_ ? root_->size() : 0; }
    Node* Find(Ty& t) {
      return root_ ? root_->Find(t) : NULL;
    }
    struct CollectNodes {
      std::set<Node*>* container_;
      CollectNodes(std::set<Node*>* c) : container_(c) {}
      void SetContainer(std::set<Node*>* c) { container_ = c; }
      void operator()(Node* x) { container_->insert(x); }
    };
  };// class GenericTree<Type>

  /// \brief Node of GenericTree
  template<typename Ty>
  class GenericTree<Ty>::Node {
    Ty node_;                              ///< Node value
    Node*            parent_;   ///< Parent node in the tree
    std::list<Node*> children_; ///< Children nodes
  public:
    typedef typename std::list<Node*> NodeList;
    typedef typename NodeList::iterator iterator;
    typedef typename NodeList::const_iterator  const_iterator;
    Node() : parent_(NULL) {}
    Node(Ty& t) :node_(t), parent_(NULL) {}
    Node(Ty& t, Node* p) : node_(t), parent_(p) {}
    ~Node() {}

    template <class Compare>
    void sort (Compare comp) {
      children_.sort(comp);
    }
    void  SetParent(Node* p) { parent_ = p;    }
    Node* GetParent()  const { return parent_; }
    Node* GetRoot() { return parent_ ? parent_->GetRoot() : this; }
    /// \brief Search a value in the tree.
    ///
    /// Since this is not a search tree, this function just traverses the tree
    /// to find the value.
    /// \param t The value to find.
    /// \return Pointer to the node containing t, NULL if t in not in the tree.
    Node* Find(const Ty& t) {
      if (t == node_) { return this; }
      for (iterator it = children_.begin(); it != children_.end(); ++it) {
        Node* f = (*it)->Find(t);
        if (f) { return f; }
      }
      return NULL;
    }
    Ty&       operator*()       { return node_; }
    const Ty& operator*() const { return node_; }

    int  GetDepth() {
      return parent_ ? (parent_->GetDepth()+1) : 0;
    }
    bool IsLeaf() const  { return children_.empty(); }
    Node* AddChild(Ty& c) {
      Node* ch = new Node(c, this);
      children_.push_back(ch);
      return ch;
    }
    iterator RemoveChild(iterator it) {
      (*it)->SetParent(NULL);
      return children_.erase(it);
    }
    size_t GetNumChildren() const { return children_.size(); }

    template<typename F> void TraversePreOrder(F& f) {
      f(this);
      for (iterator it = children_.begin(); it != children_.end(); ++it) {
        if(*it) { (*it)->TraversePreOrder(f); }
      }
    }
    template<typename F> void TraversePostOrder(F& f) {
      for (iterator it = children_.begin(); it != children_.end(); ++it) {
        if(*it) { (*it)->TraversePostOrder(f); }
      }
      f(this);
    }
    template<typename F> void TraverseBreadthFirst(F& f) {
      std::deque<GenericTree<Ty>::Node*> nodeQueue;
      nodeQueue.push_back(this);
      while (!nodeQueue.empty()) {
        GenericTree<Ty>::Node* n = nodeQueue.front();
        nodeQueue.pop_front();
        f(n);
        for (iterator it = n->begin(); it != n->end(); ++it) {
          if(*it) { nodeQueue.push_back(*it); }
        }
      }// while (!nodeQueue.empty())
    }// TraverseBreadthFirst()
    /// \brief The size of the (sub)tree with this node as root.
    ///
    /// \note The time complexity is not constant, so be careful.
    size_t size() const  {
      int s = 1;
      for (const_iterator it = children_.begin(); it != children_.end(); ++it) {
        s += (*it)->size();
      }
      return s;
    }
    Node*&       front()       { return  children_.front(); }
    Node* const& front() const { return  children_.front(); }
    Node*&       back()        { return  children_.back(); }
    Node* const& back()  const { return  children_.back(); }
    bool   empty() const { return children_.empty(); }
    iterator begin() { return children_.begin(); }
    iterator end()   { return children_.end();   }
    const_iterator begin() const { return children_.begin(); }
    const_iterator end()   const { return children_.end();   }
  };// class Node()

  template<typename Ty>
  GenericTree<Ty>::GenericTree(Ty& t) {
    root_ = new Node(t);
  }
  template<typename Ty>
  GenericTree<Ty>::~GenericTree() {
    if (root_) {
      std::set<Node*> nodes;
      CollectNodes col(&nodes);
      root_->TraversePostOrder(col);
      for (typename std::set<Node*>::iterator it=nodes.begin();
           it != nodes.end(); ++it) { delete *it; }
    }
  }
}// namespace ES_SIMD

#endif//ES_SIMD_DATADEPENDENCY_HH
