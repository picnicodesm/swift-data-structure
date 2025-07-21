//: [Previous](@previous)

import Foundation

enum RBNodeColor {
    case red, black
}

// MARK: - RBNode
final class RBNode<Value: Comparable> {
    var value: Value
    var color: RBNodeColor
    
    var left: RBNode<Value>?
    var right: RBNode<Value>?
    weak var parent: RBNode<Value>? // 순환 참조 방지를 위해 weak
    
    init(value: Value, color: RBNodeColor = .red) {
        self.value = value
        self.color = color
    }
}

extension RBNode {
    var isRed: Bool { color == .red }

    var isBlack: Bool { color == .black }
    
    var sibling: RBNode? {
        guard let parent = parent else { return nil }
        return parent.left === self ? parent.right : parent.left
    }
    
    var grandparent: RBNode? { parent?.parent }
    
    var uncle: RBNode? { parent?.sibling }
}

// MARK: - RB Tree
final class RedBlackTree<T: Comparable> {
    private(set) var root: RBNode<T>?
    
    init() { }
    
    func insert(_ value: T) {
        let newNode = RBNode(value: value)
        insertBST(newNode)
        fixAfterInsertion(newNode)
    }
}

extension RedBlackTree {
    private func insertBST(_ node: RBNode<T>) {
        var current = root
        var parent: RBNode<T>? = nil
        
        // 삽입 위치 탐색
        while let unwrapped = current {
            parent = unwrapped
            
            if node.value < unwrapped.value {
                current = unwrapped.left
            } else { current = unwrapped.right }
        }
        
        node.parent = parent
        
        if parent == nil {
            root = node
        } else if node.value < parent!.value {
            parent!.left = node
        } else {
            parent!.right = node
        }
    }
    
    private func fixAfterInsertion(_ node: RBNode<T>) {
        var node = node
        
        while node !== root && node.parent!.isRed { // 강제 언래핑을 쓸 수 있는 이유: root를 제외한 모든 노드는 parent가 존재하는데, root인지 앞에서 검사하기 떄문에
            if node.parent === node.grandparent?.left { // P가 G의 왼쪽 자식일 경우
                let uncle = node.uncle
                
                if uncle?.isRed == true {
                    // Case 1: 부모와 삼촌이 모두 빨간색
                    node.parent!.color = .black
                    uncle!.color = .black
                    node.grandparent!.color = .red
                    node = node.grandparent! // 재귀적으로 올라가기 위함
                } else {
                    if node === node.parent!.right {
                        // Case 2: P는 G의 왼쪽 자식, 자신은 P의 오른쪽 자식(LR) -> LL Case로 만듦
                        node = node.parent!
                        rotateLeft(node)
                    }
                    // Case 3: P는 G의 왼쪽 자식, 자신은 P의 왼쪽 자식(LL)
                    node.parent!.color = .black
                    node.grandparent!.color = .red
                    rotateRight(node.grandparent!)
                }
            } else {
                // P가 G의 오른쪽 자식일 경우
                let uncle = node.uncle
                
                if uncle?.isRed == true {
                    node.parent!.color = .black
                    uncle!.color = .black
                    node.grandparent!.color = .red
                    node = node.grandparent! // 재귀적으로 올라가기 위함
                } else {
                    if node === node.parent!.left {
                        node = node.parent!
                        rotateRight(node)
                    }
                    node.parent!.color = .black
                    node.grandparent!.color = .red
                    rotateLeft(node.grandparent!)
                }
            }
        }
        
        root?.color = .black
    }
    
    private func rotateLeft(_ node: RBNode<T>) {
        guard let right = node.right else { return }
        
        node.right = right.left
        if node.parent == nil {
            root = right
        } else if node === node.parent!.left {
            node.parent!.left = right
        } else {
            node.parent!.right = right
        }
        
        right.left = node
        node.parent = right
    }
    
    private func rotateRight(_ node: RBNode<T>) {
        guard let left = node.left else { return }
        
        node.left = left.right
        if node.parent == nil {
            root = left
        } else if node === node.parent!.left {
            node.parent!.left = left
        } else {
            node.parent!.right = left
        }
        
        left.right = node
        node.parent = left
    }
}

//: [Next](@next)
