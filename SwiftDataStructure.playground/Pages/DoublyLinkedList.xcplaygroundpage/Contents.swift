//: [Previous](@previous)

import Foundation

class Node<T> {
    var data: T
    var next: Node<T>?
    var prev: Node<T>?
    
    init(_ data: T, next: Node<T>?=nil, prev: Node<T>?=nil) {
        self.data = data
        self.next = next
        self.prev = prev
    }
    
    deinit {
        print("data \(data) is deinit")
    }
}

class DoublyLinkedList<T: Equatable> {
    enum SearchDirection {
        case forward
        case backward
    }
    
    private var head: Node<T>? = nil
    private var tail: Node<T>? = nil
    
    func appendFirst(_ data: T) {
        let newNode = Node(data)
        
        if head == nil && tail == nil {
            head = newNode
            tail = newNode
            return
        }
        
        head?.prev = newNode
        newNode.next = head
        head = newNode
    }
    
    func appendLast(_ data: T) {
        let newNode = Node(data)
        
        if head == nil && tail == nil {
            head = newNode
            tail = newNode
            return
        }
        
        tail?.next = newNode
        newNode.prev = tail
        tail = newNode
    }
    
    func insert(_ data: T, at index: Int) {
        if index == 0 {
            appendFirst(data)
            return
        }
        
        let newNode = Node(data)
        var searchNode = head
        
        for _ in 0..<index-1 {
            searchNode = searchNode?.next
        }
        
        newNode.prev = searchNode
        newNode.next = searchNode?.next
        searchNode?.next?.prev = newNode
        searchNode?.next = newNode
        
        if searchNode === tail { tail = newNode }
    }
    
    func removeFirst() {
        if head?.next == nil { tail = nil }
        
        head = head?.next
        head?.prev = nil
    }
    
    func removeLast() {
        if tail?.prev == nil { head = nil }
        
        tail = tail?.prev
        tail?.next = nil
    }
    
    func remove(at index: Int) {
        if index == 0 { removeFirst() }
        
        var removeNode = head
        for _ in 0..<index {
            removeNode = removeNode?.next
        }
        
        removeNode?.prev?.next = removeNode?.next
        removeNode?.next?.prev = removeNode?.prev
        
        if removeNode === tail { tail = removeNode?.prev }
    }
    
    func contains(_ data: T, direction: SearchDirection) -> Bool {
        if head == nil && tail == nil { return false }
        
        var node = direction == .forward ? head : tail
        while node != nil {
            if node?.data == data { return true }
            node = direction == .forward ? node?.next : node?.prev
        }
        
        return false
    }
    
    func printList() {
        if head == nil && tail == nil { return }
        
        print("head: \(head!.data), tail: \(tail!.data)")
        
        var node = head
        while node?.next != nil {
            print(node!.data, terminator: " -> ")
            node = node?.next
        }
        
        print("\(node!.data)\n")
    }
}

var doublyLinkedList = DoublyLinkedList<Int>()


for i in 1...5 {
    doublyLinkedList.appendLast(i)
}
doublyLinkedList.printList()

doublyLinkedList.appendFirst(0)
doublyLinkedList.appendLast(6)
doublyLinkedList.printList()

doublyLinkedList.removeFirst()
doublyLinkedList.removeLast()
doublyLinkedList.printList()

doublyLinkedList.remove(at: 1)
doublyLinkedList.remove(at: 2)
doublyLinkedList.printList()

doublyLinkedList.insert(2, at: 1)
doublyLinkedList.insert(4, at: 3)
doublyLinkedList.insert(6, at: 5)
doublyLinkedList.printList()

//: [Next](@next)




