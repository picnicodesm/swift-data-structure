//: [Previous](@previous)

import Foundation

struct Stack<T> {
    private var stack: [T] = []
    
    mutating func push(_ element: T) {
        stack.append(element)
    }
    
    mutating func pop() -> T? {
        stack.popLast()
    }
    
    var isEmpty: Bool { stack.isEmpty }
    
    var top: T? { stack.last }
    
    var size: Int { stack.count }
}

var stack = Stack<Int>()

stack.push(1)
stack.push(3)
stack.push(5)

print(stack.size) // 3

print(stack.pop()!)
print(stack.pop()!)
print(stack.top!)
//Optional(5)
//Optional(3)
//Optional(1)

stack.pop()
print(stack.isEmpty) // true


//: [Next](@next)
