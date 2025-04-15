//: [Previous](@previous)

import Foundation

struct Deque<T> {
    private var frontStack: [T] = []
    private var backStack: [T] = []
    
    mutating func pushFront(_ element: T) {
        frontStack.append(element)
    }
    
    mutating func pushBack(_ element: T) {
        backStack.append(element)
    }
    
    mutating func popFront() -> T? {
        if frontStack.isEmpty {
            frontStack = backStack.reversed()
            backStack = []
        }
        
        return frontStack.popLast()
    }
    
    mutating func popBack() -> T? {
        if backStack.isEmpty {
            backStack = frontStack.reversed()
            frontStack = []
        }
        
        return backStack.popLast()
    }
    
    var size: Int {
        return frontStack.count + backStack.count
    }
    
    var isEmpty: Bool {
        return frontStack.isEmpty && backStack.isEmpty
    }
    
    var front: T? {
        if frontStack.isEmpty { return backStack.first }
        return frontStack.last
    }
    
    var back: T? {
        if backStack.isEmpty { return frontStack.first }
        return backStack.last
    }
    
    func printElements() {
        for e in frontStack.reversed() { print(e, terminator: " ") }
        for e in backStack { print(e, terminator: " ") }
        print("")
    }
}

var deque = Deque<Int>()

deque.pushFront(2)
deque.pushBack(1)
print(deque.front)
print(deque.back)
print(deque.size)
print(deque.isEmpty)
deque.pushFront(3)
deque.printElements()
print(deque.popFront())
print(deque.popBack())
deque.printElements()



//: [Next](@next)
