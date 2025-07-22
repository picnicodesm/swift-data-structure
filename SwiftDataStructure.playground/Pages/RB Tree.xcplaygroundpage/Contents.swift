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
    
    func delete(_ value: T) {
        guard let node = search(value) else {
            print("삭제할 값 \(value)를 찾을 수 없습니다.")
            return
        }
        deleteNode(node)
    }
    
    func search(_ value: T) -> RBNode<T>? {
        var current = root
        while let node = current {
            if value == node.value {
                return node
            } else if value < node.value {
                current = node.left
            } else {
                current = node.right
            }
        }
        return nil
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
    
    private func deleteNode(_ node: RBNode<T>) {
        var deleteNode: RBNode<T> = node      // 실제로 제거되는 노드(node 또는 successor)
        var replacement: RBNode<T>?          // deleteNode의 대체 노드
        var replacementParent: RBNode<T>?    // 대체 노드의 부모 노드(Double Black을 처리하기 위함)
        
        var deleteNodeColor = deleteNode.color
        
        // Case 1: 자식 노드가 없거나 1개인 경우
        if node.left == nil || node.right == nil {
            replacement = node.left ?? node.right
            replacementParent = node.parent
            transplant(deleteNode, to: replacement)
        }
        // Case 2: 삭제할 노드(node)에 두 개의 자식이 있는 경우
        else {
            deleteNode = minimum(node.right!)   // successor
            deleteNodeColor = deleteNode.color
            
            replacement = deleteNode.right
            
            // 바로 아래 오른쪽 자식이 아닌 경우
            if deleteNode.parent !== node {
                replacementParent = deleteNode.parent
                transplant(deleteNode, to: deleteNode.right)
                
                deleteNode.right = node.right
                deleteNode.right?.parent = deleteNode
            } else {
                replacementParent = deleteNode
            }
            
            transplant(node, to: deleteNode)
            deleteNode.left = node.left
            deleteNode.left?.parent = deleteNode
            deleteNode.color = node.color
        }
        
        if deleteNodeColor == .black {
            fixAfterDeletion(replacement, parent: replacementParent)
        }
    }
    
    private func transplant(_ old: RBNode<T>, to new: RBNode<T>?) { // 부모와의 연결만을 담당해주는 함수
        if old.parent == nil {
            root = new
        } else if old === old.parent?.left {
            old.parent?.left = new
        } else {
            old.parent?.right = new
        }
        
        new?.parent = old.parent
    }
    
    private func minimum(_ node: RBNode<T>) -> RBNode<T> { // 오른쪽 서브 트리의 최솟값을 찾아줌.
        var current = node
        while let next = current.left {
            current = next
        }
        return current
    }
    
    private func fixAfterDeletion(_ node: RBNode<T>?, parent: RBNode<T>?) {
        var node = node
        var parent = parent
        
        while node !== root && (node?.isBlack ?? true) {
            if node === parent?.left {
                var sibling = parent?.right
                
                // Case 1: sibling is red
                if sibling?.isRed == true {
                    sibling?.color = .black
                    parent?.color = .red
                    rotateLeft(parent!)
                    sibling = parent?.right
                }
                
                // Case 2: sibling and both children black
                if (sibling?.left?.isBlack ?? true) && (sibling?.right?.isBlack ?? true) {
                    sibling?.color = .red
                    node = parent
                    parent = node?.parent
                } else {
                    // Case 3: sibling is black, sibling.left is red, sibling.right is black
                    if sibling?.right?.isBlack ?? true {
                        sibling?.left?.color = .black
                        sibling?.color = .red
                        if let sibling = sibling {
                            rotateRight(sibling)
                        }
                        sibling = parent?.right
                    }
                    
                    // Case 4
                    sibling?.color = parent!.color
                    parent?.color = .black
                    sibling?.right?.color = .black
                    if let parent = parent {
                        rotateLeft(parent)
                    }
                    break
                }
            } else {
                // 대칭 처리: node가 오른쪽 자식인 경우
                var sibling = parent?.left
                
                if sibling?.isRed == true {
                    sibling?.color = .black
                    parent?.color = .red
                    rotateRight(parent!)
                    sibling = parent?.left
                }
                
                if (sibling?.left?.isBlack ?? true) && (sibling?.right?.isBlack ?? true) {
                    sibling?.color = .red
                    node = parent
                    parent = node?.parent
                } else {
                    if sibling?.left?.isBlack ?? true {
                        sibling?.right?.color = .black
                        sibling?.color = .red
                        if let sibling = sibling {
                            rotateLeft(sibling)
                        }
                        sibling = parent?.left
                    }
                    
                    sibling?.color = parent!.color
                    parent?.color = .black
                    sibling?.left?.color = .black
                    if let parent = parent {
                        rotateRight(parent)
                    }
                    break
                }
            }
        }
        
        node?.color = .black
    }
}

extension RedBlackTree {
    /// 트리를 콘솔에 시각적으로 출력
    func printTree() {
        print("Red-Black Tree:")
        printSubtree(root, prefix: "", isTail: true)
    }
    
    private func printSubtree(_ node: RBNode<T>?, prefix: String, isTail: Bool) {
        guard let node = node else {
            print(prefix + (isTail ? "└── " : "├── ") + "nil ⚫️")
            return
        }
        
        let color = node.color == .red ? "🔴" : "⚫️"
        print(prefix + (isTail ? "└── " : "├── ") + "\(node.value) \(color)")
        
        let children = [node.left, node.right]
        for (index, child) in children.enumerated() {
            let isLast = index == children.count - 1
            printSubtree(child, prefix: prefix + (isTail ? "    " : "│   "), isTail: isLast)
        }
    }
    
    
    // MARK: - Tree Printing
       /// 트리를 콘솔에 90도 회전된 형태로 시각화
       func drawDiagram() {
           print(diagram(for: self.root))
       }

       /// `drawDiagram`을 위한 재귀 헬퍼 함수
       private func diagram(for node: RBNode<T>?,
                            _ top: String = "",
                            _ rootPrefix: String = "", // 현재 노드에 붙는 접두사 (ex: "───", "┌──", "└──")
                            _ bottom: String = "") -> String {
           guard let node = node else {
               // nil 노드는 항상 블랙(⚫️)으로 명시적으로 출력됩니다.
               // nil 노드는 리프 노드이므로, '마지막 가지' 형태인 "└──"를 사용합니다.
               // 또는 부모로부터 상속받은 rootPrefix를 활용할 수도 있습니다.
               return rootPrefix + "nil ⚫️\n"
           }

           let colorSymbol = node.color == .black ? "⚫️" : "🔴"

           // 오른쪽 자식 -> 현재 노드 -> 왼쪽 자식 순서로 재귀 호출하여 시각화
           // 중요: prefix 문자열들이 다음 레벨의 "가지"를 올바르게 형성하도록 조정합니다.

           // 오른쪽 자식 호출: 'top'은 오른쪽 자식의 부모 경로 (현재 노드 오른쪽 위)
           //                   'rootPrefix'는 오른쪽 자식에 붙을 가지 (┌──)
           //                   'bottom'은 오른쪽 자식의 아래 경로 (│   )
           let rightSubtree = diagram(for: node.right,
                                      top + "    ",         // 다음 레벨 'top'
                                      top + "┌── ",          // 다음 레벨 'rootPrefix'
                                      top + "│   ")          // 다음 레벨 'bottom'

           // 현재 노드 출력
           let currentNode = rootPrefix + "\(node.value) \(colorSymbol)\n"

           // 왼쪽 자식 호출: 'top'은 왼쪽 자식의 부모 경로 (현재 노드 왼쪽 위)
           //                   'rootPrefix'는 왼쪽 자식에 붙을 가지 (└──)
           //                   'bottom'은 왼쪽 자식의 아래 경로 (    )
           let leftSubtree = diagram(for: node.left,
                                     bottom + "│   ",       // 다음 레벨 'top'
                                     bottom + "└── ",        // 다음 레벨 'rootPrefix'
                                     bottom + "    ")        // 다음 레벨 'bottom'

           return rightSubtree + currentNode + leftSubtree
       }
}


// MARK: - Red-Black Tree Operations Test Scenarios

let rbTree = RedBlackTree<Int>()

print("--- Red-Black Tree 삽입/삭제 시나리오 시작 ---\n")

// MARK: - 삽입 시나리오
print("➡️ 삽입: 10")
rbTree.insert(10)
rbTree.drawDiagram()

print("➡️ 삽입: 20")
rbTree.insert(20)
rbTree.drawDiagram()

print("➡️ 삽입: 30")
rbTree.insert(30)
rbTree.drawDiagram()

print("➡️ 삽입: 15")
rbTree.insert(15)
rbTree.drawDiagram()

print("➡️ 삽입: 5")
rbTree.insert(5)
rbTree.drawDiagram()

print("➡️ 삽입: 25")
rbTree.insert(25)
rbTree.drawDiagram()

print("➡️ 삽입: 35")
rbTree.insert(35)
rbTree.drawDiagram()

print("➡️ 삽입: 2")
rbTree.insert(2)
rbTree.drawDiagram()

print("➡️ 삽입: 7")
rbTree.insert(7)
rbTree.drawDiagram()

print("➡️ 삽입: 12")
rbTree.insert(12)
rbTree.drawDiagram()

print("➡️ 삽입: 18")
rbTree.insert(18)
rbTree.drawDiagram()

print("\n--- 모든 삽입 완료 ---\n")

// MARK: - 삭제 시나리오
print("➡️ 삭제: 25)")
rbTree.delete(25)
rbTree.drawDiagram()

print("➡️ 삭제: 5")
rbTree.delete(5)
rbTree.drawDiagram()

print("➡️ 삭제: 30")
rbTree.delete(30)
rbTree.drawDiagram()

print("➡️ 삭제: 10")
rbTree.delete(10)
rbTree.drawDiagram()

print("➡️ 삭제: 2")
rbTree.delete(2)
rbTree.drawDiagram()

print("➡️ 삭제: 7")
rbTree.delete(7)
rbTree.drawDiagram()

print("➡️ 삭제: 12")
rbTree.delete(12)
rbTree.drawDiagram()

print("➡️ 삭제: 18")
rbTree.delete(18)
rbTree.drawDiagram()

print("➡️ 삭제: 35")
rbTree.delete(35)
rbTree.drawDiagram()

print("➡️ 삭제: 20")
rbTree.delete(20)
rbTree.drawDiagram()

print("➡️ 존재하지 않는 값 삭제 시도: 99")
rbTree.delete(99)
rbTree.drawDiagram()

print("\n--- Red-Black Tree 삽입/삭제 시나리오 종료 ---")



//: [Next](@next)





