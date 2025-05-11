//: [Previous](@previous)

import Foundation

struct Heap<T: Comparable> {
    enum Direction { case left, right, none }
    
    var heap: [T] = []
    
    init(_ data: T) {
        heap.append(data)
        heap.append(data)
    }
    
    mutating func insert(_ data: T) {
        heap.append(data)
        var currentIndex = heap.count-1
        var parentIndex = currentIndex / 2
        
        while parentIndex > 0 && heap[parentIndex] > heap[currentIndex] {
            heap.swapAt(parentIndex, currentIndex)
            currentIndex = parentIndex
            parentIndex = currentIndex / 2
        }
    }
    
    mutating func pop() -> T? {
        if heap.count <= 1 { return nil }
        else if heap.count == 2 { return heap.removeLast() }

        var currentIndex = 1
        var changeIndex = 0
        let returnValue = heap[currentIndex]
        
        heap[1] = heap.removeLast()
        
        func choiceDirection(_ currentIndex: Int) -> Direction {
            let leftChildIndex = currentIndex * 2
            let rightChildIndex = currentIndex * 2 + 1
            
            // case 1: 자식이 없을 경우
            if leftChildIndex >= heap.count { return .none }
            // case 2: leftChild만 있을 경우
            if leftChildIndex < heap.count && rightChildIndex >= heap.count {
                if heap[leftChildIndex] < heap[currentIndex] { return .left }
                else { return .none }
            }
            // case 3: child가 둘 다 있을 경우
            // case 3-1: 둘 다 클 경우
            if heap[leftChildIndex] > heap[currentIndex] && heap[rightChildIndex] > heap[currentIndex] {
                return .none
            }
            // case 3-2 둘 다 작을 경우 -> 작은 쪽으로 내려감
            if heap[leftChildIndex] < heap[currentIndex] && heap[rightChildIndex] < heap[currentIndex] {
                return heap[leftChildIndex] < heap[rightChildIndex] ? .left : .right
            }
            // case 3-3: 하나만 작을 경우
            return heap[leftChildIndex] < heap[currentIndex] ? .left : .right
        }
        
        while true {
            switch choiceDirection(currentIndex) {
            case .none: return returnValue
            case .left:
                changeIndex = currentIndex * 2
            case .right:
                changeIndex = currentIndex * 2 + 1
            }
            
            heap.swapAt(changeIndex, currentIndex)
            currentIndex = changeIndex
        }
    }
}

extension Heap {
    func printHeap() {
        var level = 1
        var startIndex = 1
        
        while true {
            print("level \(level): ", terminator: " ")
            for i in 0..<startIndex {
                let index = startIndex + i
                if index >= heap.count { break }
                
                print(heap[index], terminator: " ")
            }
            
            level += 1
            startIndex *= 2
            if startIndex >= heap.count { break }
            print("")
        }
        print("\n")
    }
}
// 10 10 12 42 72 45 23
var heap = Heap(10)
heap.insert(42)
heap.insert(23)
heap.insert(64)
heap.insert(72)
heap.insert(45)
heap.insert(12)

heap.insert(3)
heap.printHeap()

heap.pop()
heap.printHeap()


//: [Next](@next)


