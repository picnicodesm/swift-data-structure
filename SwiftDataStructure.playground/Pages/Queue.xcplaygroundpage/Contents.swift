//: [Previous](@previous)

import Foundation

struct QueueDS<T> { // Double Stack으로 구현한 큐
    private var input: [T] = []
    private var output: [T] = []
    
    mutating func enqueue(_ element: T) {
        input.append(element)
    }
    
    mutating func dequeue() -> T? {
        if output.isEmpty {
            output = input.reversed()
            input = []
        }
        
        return output.popLast()
    }
    
    var isEmpty: Bool { input.isEmpty && output.isEmpty }
    
    var size: Int { input.count + output.count }
}

var queueDS = QueueDS<Int>()

for i in 1...5 {
    queueDS.enqueue(i)
}

while !queueDS.isEmpty {
    print(queueDS.dequeue()!)
}

print(queueDS.dequeue())

struct QueueI<T> { // index로 구현한 큐
    private var arr: [T] = []
    private var head: Int = -1
    
    mutating func enqueue(_ element: T) {
        arr.append(element)
    }
    
    mutating func dequeue() -> T? {
        head += 1
        
        if head > arr.count-1 {
            head = -1
            return nil
        } else if head < arr.count-1 {
            return arr[head]
        } else {
            let output = arr[head]
            clear()
            return output
        }
    }
    
    private mutating func clear() {
        arr = []
        head = -1
    }
    
    var isEmpty: Bool { arr.isEmpty }
    
    var size: Int { arr.count - head - 1 }
}

var queueI = QueueI<Int>()

for i in 1...5 {
    queueDS.enqueue(i)
}

while !queueDS.isEmpty {
    print(queueDS.dequeue()!)
}

print(queueI.isEmpty)


//: [Next](@next)
