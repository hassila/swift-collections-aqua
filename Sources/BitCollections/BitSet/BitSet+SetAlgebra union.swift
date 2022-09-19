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
  /// Returns a new set with the elements of both this and the given set.
  ///
  ///     let set: BitSet = [1, 2, 3, 4]
  ///     let other: BitSet = [0, 2, 4, 6]
  ///     set.union(other) // [0, 1, 2, 3, 4, 6]
  ///
  /// - Parameter other: The set of elements to insert.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in either input.
  public __consuming func union(_ other: __owned Self) -> Self {
    self._read { first in
      other._read { second in
        Self(
          _combining: (first, second),
          includingTail: true,
          using: { $0.union($1) })
      }
    }
  }

  /// Returns a new set with the elements of both this set and the given
  /// sequence of integers.
  ///
  ///     let set: BitSet = [1, 2, 3, 4]
  ///     let other = [6, 4, 2, 0, 2, 0]
  ///     set.union(other) // [0, 1, 2, 3, 4, 6]
  ///
  /// - Parameter other: A sequence of nonnegative integers.
  ///
  /// - Complexity: O(*max*) + *k*, where *max* is the largest item in either
  ///    input, and *k* is the complexity of iterating over all elements in
  ///    `other`.
  @inlinable
  public __consuming func union<S: Sequence>(
    _ other: __owned S
  ) -> Self
  where S.Element == Int
  {
    if S.self == BitSet.self {
      return union(other as! BitSet)
    }
    if S.self == BitSet.Counted.self {
      return union(other as! BitSet.Counted)
    }
    if S.self == Range<Int>.self {
      return union(other as! Range<Int>)
    }
    var result = self
    result.formUnion(other)
    return result
  }

  public __consuming func union(_ other: __owned BitSet.Counted) -> Self {
    union(other._bits)
  }

  /// Returns a new set with the elements of both this set and the given
  /// range of integers.
  ///
  ///     let set: BitSet = [1, 2, 3, 4]
  ///     set.union(3 ..< 7) // [1, 2, 3, 4, 5, 6]
  ///
  /// - Parameter other: A range of nonnegative integers.
  ///
  /// - Complexity: O(*max*), where *max* is the largest item in either input.
  public __consuming func union(_ other: Range<Int>) -> Self {
    var result = self
    result.formUnion(other)
    return result
  }
}
