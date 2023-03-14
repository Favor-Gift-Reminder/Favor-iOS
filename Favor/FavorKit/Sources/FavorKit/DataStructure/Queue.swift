//
//  Queue.swift
//  Favor
//
//  Created by 이창준 on 2023/03/14.
//

struct Queue<T> {
  private var queue: [T?] = []
  private var front: Int = 0

  public var frontIndex: Int { return self.front }

  public var size: Int { return self.queue.count }

  public var isEmpty: Bool { return self.size == 0 || self.queue[self.front] == nil }

  public mutating func enqueue(_ element: T) {
    self.queue.append(element)
  }

  @discardableResult
  public mutating func dequeue() -> T? {
    guard
      self.front <= self.size,
      let element = self.queue[self.front]
    else { return nil }
    
    self.queue[self.front] = nil
    self.front += 1
    return element
  }
}
