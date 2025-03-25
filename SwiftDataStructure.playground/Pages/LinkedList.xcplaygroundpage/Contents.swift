//: [Previous](@previous)

import Foundation

class Node<T> {
    var data: T
    var next: Node<T>?
    
    init(_ data: T, next: Node<T>? = nil) {
        self.data = data
        self.next = next
    }
}

class LinkedList<T: Equatable> {
    private var head: Node<T>? = nil
    
    func append(_ data: T) {
        let node = Node(data)
        if head == nil {
            head = node
            return
        }
        
        var lastNode = head
        while lastNode?.next != nil {
            lastNode = lastNode?.next
        }
        lastNode?.next = node
    }
    
    func insert(_ data: T, at index: Int) {
        let node = Node(data)
        if index == 0 {
            node.next = head
            head = node
            return
        }
        
        var lastNode = head
        for _ in 0..<index-1 {
            lastNode = lastNode?.next
        }
        
        node.next = lastNode?.next
        lastNode?.next = node
    }
    
    func removeLast() {
        if head == nil { return }
        if head?.next == nil {
            head = nil
            return
        }
        
        var beforeRemoveNode = head
        while beforeRemoveNode?.next?.next != nil {
            beforeRemoveNode = beforeRemoveNode?.next
        }
        
        beforeRemoveNode?.next = nil
    }
    
    func remove(at index: Int) {
        if head == nil { return }
        if index == 0 {
            head = head?.next
            return
        }
        
        var beforeRemoveNode = head
        for _ in 0..<(index-1) {
            beforeRemoveNode = beforeRemoveNode?.next
        }
        
        beforeRemoveNode?.next = beforeRemoveNode?.next?.next
    }
    
    func search(_ data: T) -> Bool {
        if head == nil { return false }
        
        var findNode = head
        while findNode != nil {
            if findNode?.data == data {
                return true
            } else {
                findNode = findNode?.next
            }
        }
        return false
    }
    
    func printNodes() {
        if head == nil { return }
        var printNode = head
        
        while printNode != nil {
            print(printNode!.data, terminator: " ")
            printNode = printNode?.next
        }
        print("")
    }
}

var linkedList = LinkedList<Int>()

for i in 1...5 {
    linkedList.append(i)
}
linkedList.printNodes()

for i in 0...2 {
    linkedList.remove(at: i)
}
linkedList.printNodes()

linkedList.insert(3, at: 1)
linkedList.insert(1, at: 0)
linkedList.printNodes()

linkedList.removeLast()
linkedList.printNodes()



//: [Next](@next)




