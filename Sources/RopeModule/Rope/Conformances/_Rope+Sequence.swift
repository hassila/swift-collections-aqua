//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension _Rope: Sequence {
  func makeIterator() -> Iterator {
    Iterator(self, from: self.startIndex)
  }
  
  func makeIterator(from start: Index) -> Iterator {
    Iterator(self, from: start)
  }
  
  struct Iterator: IteratorProtocol {
    let rope: _Rope
    private(set) var index: Index

    init(_ rope: _Rope, from start: Index) {
      rope.validate(start)
      self.rope = rope
      self.index = start
      self.rope.ensureLeaf(in: &index)
    }
    
    var isAtEnd: Bool {
      index._leaf == nil
    }
    
    var isAtStart: Bool {
      index == rope.startIndex
    }
    
    var current: Element {
      guard let leaf = index._leaf else {
        preconditionFailure("Cannot access current element in iterator at end")
      }
      return leaf.read { $0.children[index._path[0]].value }
    }
    
    func withCurrent<R>(_ body: (Element) -> R) -> R {
      guard let leaf = index._leaf else {
        preconditionFailure("Cannot access current element in iterator at end")
      }
      return leaf.read { body($0.children[index._path[0]].value) }
    }
    
    mutating func stepForward() -> Bool {
      let end = rope.endPath
      guard index._path < end else { return false }
      let next = rope.index(after: index)
      guard next._path < end else { return false }
      index = next
      return true
    }

    mutating func stepBackward() -> Bool {
      guard index._path > rope.startPath else { return false }
      rope.formIndex(before: &index)
      return true
    }
    
    mutating func stepToEnd() {
      index = rope.endIndex
    }

    mutating func next() -> Element? {
      guard !isAtEnd else { return nil }
      let item = self.current
      if !stepForward() {
        stepToEnd()
      }
      return item
    }
  }
}

extension _Rope {
  func _unmanagedLeaf(at path: Path) -> UnmanagedLeaf? {
    assert(path.height == self.height)
    guard path < endPath else { return nil }
    return root.unmanagedLeaf(at: path)
  }

  func _leaf(at path: Path) -> Node? {
    assert(path.height == self.height)
    guard _root != nil else { return nil }
    var node = root
    while true {
      let h = node.height
      let slot = path[h]
      guard slot < node.childCount else { return nil }
      if h == 0 { break }
      node = node.readInner { $0.child(at: slot)! }
    }
    return node
  }
}
