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
        return parent.left?.value == self.value ? parent.right : parent.left
    }
    
    var grandparent: RBNode? { parent?.parent }
    
    var uncle: RBNode? { parent?.sibling }
}

//: [Next](@next)
