//: [Previous](@previous)

import Foundation

struct Heap<T: Comparable> {
    var heap: [T]
    var orderCriteria: (T, T) -> Bool
    
    init(_ heap: [T] = [], orderCriteria: @escaping (T, T) -> Bool) {
        self.heap = heap
        self.orderCriteria = orderCriteria
        
        if !heap.isEmpty {
            for i in stride(from: (heap.count / 2) - 1, through: 0, by: -1) {
                siftDown(from: i)
            }
        }
    }
    
    var isEmpty: Bool { heap.isEmpty }
    var peek: T? { heap.first }
    var count: Int { heap.count }
    
    mutating func insert(_ element: T) {
        heap.append(element)
        siftUp(from: heap.count-1)
    }
    
    mutating func pop() -> T? {
        if heap.isEmpty { return nil }
        
        if heap.count == 1 { return heap.removeLast() }
        else {
            let value = heap[0]
            heap[0] = heap.removeLast()
            siftDown(from: 0)
            
            return value
        }
    }
    
    mutating func remove(at index: Int) -> T? {
        if index >= heap.count { return nil }
        
        let leafIndex = heap.count - 1
        if index != leafIndex {
            heap.swapAt(index, leafIndex)
            siftDown(from: index, until: leafIndex)
            siftUp(from: index)
        }
        return heap.removeLast()
    }
}

extension Heap {
    private func getParentIndex(of index: Int) -> Int {
        return (index - 1) / 2
    }
    
    private func getLeftChildIndex(of index: Int) -> Int {
        return index * 2 + 1
    }
    
    private func getRightChildIndex(of index: Int) -> Int {
        return index * 2 + 2
    }
    
    private mutating func siftUp(from currentIndex: Int) {
        var childIndex = currentIndex
        var parentIndex = getParentIndex(of: childIndex)
        
        while childIndex > 0 && orderCriteria(heap[childIndex], heap[parentIndex]) {
            heap.swapAt(childIndex, parentIndex)
            childIndex = parentIndex
            parentIndex = getParentIndex(of: childIndex)
        }
    }
    
    private mutating func siftDown(from index: Int, until endIndex: Int? = nil) {
        let limit = endIndex ?? heap.count
        var parentIndex = index
        
        while true {
            let leftChildIndex = getLeftChildIndex(of: parentIndex)
            let rightChildIndex = getRightChildIndex(of: parentIndex)
            var candidateIndex = parentIndex
            
            if leftChildIndex < limit && orderCriteria(heap[leftChildIndex], heap[candidateIndex]) {
                candidateIndex = leftChildIndex
            }
            
            if rightChildIndex < limit && orderCriteria(heap[rightChildIndex], heap[candidateIndex]) {
                candidateIndex = rightChildIndex
            }
            
            if candidateIndex == parentIndex { return }
            
            heap.swapAt(parentIndex, candidateIndex)
            parentIndex = candidateIndex
        }
    }
}

struct PriorityQueue<T: Comparable> {
    private var heap: Heap<T>
    
    init() {
        heap = Heap<T>(orderCriteria: <)
    }
    
    init(sort: @escaping (T, T) -> Bool) {
        heap = Heap<T>(orderCriteria: sort)
    }
    
    var isEmpty: Bool { heap.isEmpty }
    
    var count: Int { heap.count }
    
    var peek: T? { heap.peek }
    
    mutating func enqueue(_ element: T) {
        heap.insert(element)
    }
    
    mutating func dequeue() -> T? {
        return heap.pop()
    }
    
}

var heap = Heap<Int>([42, 64, 10, 23, 72, 12, 45], orderCriteria: <)

print(heap.heap)
heap.insert(3)
print(heap.heap)
heap.pop()
print(heap.heap)

// remove(at:)에서 shiftUp이 필요한 이유: https://stackoverflow.com/questions/68510425/removing-value-from-heap-why-siftup-and-siftdown-need-to-be-calledㅇㅇ

// MARK: - 최소 우선순위 큐 사용 예시 (가장 작은 숫자가 먼저 나옴)
print("--- 최소 우선순위 큐 ---")
var minPriorityQueue = PriorityQueue<Int>()
minPriorityQueue.enqueue(5)
minPriorityQueue.enqueue(1)
minPriorityQueue.enqueue(10)
minPriorityQueue.enqueue(3)

print("Peek: \(minPriorityQueue.peek ?? -1)") // 예상 출력: 1

while let element = minPriorityQueue.dequeue() {
    print("Dequeued: \(element)")
}
// 예상 출력:
// Dequeued: 1
// Dequeued: 3
// Dequeued: 5
// Dequeued: 10

print("Is Empty: \(minPriorityQueue.isEmpty)") // 예상 출력: true

print("\n--- 최대 우선순위 큐 ---")
// MARK: - 최대 우선순위 큐 사용 예시 (가장 큰 숫자가 먼저 나옴)
// `sort` 클로저를 `>`로 변경하여 최대 힙처럼 동작하도록 합니다.
var maxPriorityQueue = PriorityQueue<Int>(sort: >)
maxPriorityQueue.enqueue(5)
maxPriorityQueue.enqueue(1)
maxPriorityQueue.enqueue(10)
maxPriorityQueue.enqueue(3)

print("Peek: \(maxPriorityQueue.peek ?? -1)") // 예상 출력: 10

while let element = maxPriorityQueue.dequeue() {
    print("Dequeued: \(element)")
}
// 예상 출력:
// Dequeued: 10
// Dequeued: 5
// Dequeued: 3
// Dequeued: 1


//: [Next](@next)


