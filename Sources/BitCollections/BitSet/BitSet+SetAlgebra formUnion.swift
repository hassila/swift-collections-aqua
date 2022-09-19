//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BitSet {
  /// Adds the elements of the given set to this set.
  ///
  ///     var set: BitSet = [1, 2, 3, 4]
  ///     let other: BitSet = [0, 2, 4, 6]
  ///     set.formUnion(other)
  ///     // `set` is now `[0, 1, 2, 3, 4, 6]`
  ///
  /// - Parameter other: The set of elements to insert.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in either input.
  public mutating func formUnion(_ other: __owned Self) {
    _ensureCapacity(limit: other._capacity)
    _update { target in
      other._read { source in
        target.combineSharedPrefix(with: source) { $0.formUnion($1) }
      }
    }
  }

  /// Adds the elements of the given sequence to this set.
  ///
  ///     var set: BitSet = [1, 2, 3, 4]
  ///     let other = [6, 4, 2, 0, 2, 0]
  ///     set.formUnion(other)
  ///     // `set` is now `[0, 1, 2, 3, 4, 6]`
  ///
  /// - Parameter other: A sequence of nonnegative integers.
  ///
  /// - Complexity: O(*max*) + *k*, where *max* is the largest item in either
  ///    input, and *k* is the complexity of iterating over all elements in
  ///    `other`.
  @inlinable
  public mutating func formUnion<S: Sequence>(
    _ other: __owned S
  ) where S.Element == Int {
    if S.self == BitSet.self {
      formUnion(other as! BitSet)
      return
    }
    if S.self == BitSet.Counted.self {
      formUnion(other as! BitSet.Counted)
      return
    }
    if S.self == Range<Int>.self {
      formUnion(other as! Range<Int>)
      return
    }
    for value in other {
      self.insert(value)
    }
  }

  public mutating func formUnion(_ other: __owned BitSet.Counted) {
    formUnion(other._bits)
  }

  /// Adds the elements of the given range of integers to this set.
  ///
  ///     var set: BitSet = [1, 2, 3, 4]
  ///     set.formUnion(3 ..< 7)
  ///     // `set` is now `[1, 2, 3, 4, 5, 6]`
  ///
  /// - Parameter other: A range of nonnegative integers.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in either input.
  public mutating func formUnion(_ other: Range<Int>) {
    guard let other = other._toUInt() else {
      preconditionFailure("Invalid range")
    }
    guard !other.isEmpty else { return }
    _ensureCapacity(limit: other.upperBound)
    _update { handle in
      handle.formUnion(other)
    }
  }
}

