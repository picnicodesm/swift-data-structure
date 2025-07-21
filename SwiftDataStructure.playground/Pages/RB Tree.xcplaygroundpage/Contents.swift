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
        guard let node = search(value, from: root) else {
            print("삭제할 값 \(value)를 찾을 수 없습니다.")
            return
        }
        deleteNode(node)
    }
    
    private func search(_ value: T, from node: RBNode<T>?) -> RBNode<T>? {
        guard let node = node else { return nil }
        
        if value < node.value {
            return search(value, from: node.left)
        } else if value > node.value {
            return search(value, from: node.right)
        } else {
            return node
        }
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
        var target = node
        var originalColor = target.color // 실제 삭데죄는 노드의 색상
        
        var replacement: RBNode<T>?
        
        // 자식이 둘인 경우 -> successor 찾기
        if let successor = minimum(node.right) {
            originalColor = successor.color
            replacement = successor.right // 삭제하려던 노드의 자리를 successor가 대신함
            
            transplant(successor, to: successor.right) // 후계자를 그 오른쪽 자식으로 대체해서, 후계자를 삭제한 효과를 줌
            
            successor.left = node.left // successor의 하위 노드들을 삭제하려는 노드의 하위 노드(서브 트리)들로 바꿔줌
            successor.left?.parent = successor
            successor.right = node.right
            successor.right?.parent = successor
            successor.color = node.color
            
            transplant(node, to: successor) // node 자체를 successor로 대체
        } else {
            // 자식이 하나 또는 없음
            replacement = node.left ?? node.right // 있다면 작은 값이 위로 올라와야 하므로 left를 먼저 작성한다.
            transplant(node, to: replacement)
            // TODO: - 하나 있는 자식이 레드 노드일 때 black으로 바꿔줘야 하지 않나? 이것도 더블 블랙을 처리하나?
        }
        
        // 삭제된 노드가 black이면 double-black 처리
        if originalColor == .black {
            fixAfterDeletion(replacement, parent: node.parent)
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
    
    private func minimum(_ node: RBNode<T>?) -> RBNode<T>? { // 오른쪽 서브 트리의 최솟값을 찾아줌.
        var current = node
        while let next = current?.left {
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
                    sibling?.color = parent?.color ?? .black // ??는 의미 없는 코드
                    parent?.color = .black
                    sibling?.right?.color = .black
                    if let parent = parent {
                        rotateLeft(parent)
                    }
                    node = root
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

                    sibling?.color = parent?.color ?? .black
                    parent?.color = .black
                    sibling?.left?.color = .black
                    if let parent = parent {
                        rotateRight(parent)
                    }
                    node = root
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
}

extension RedBlackTree {
    /// 전체 트리가 유효한 RB 트리인지 확인
    func isValidRedBlackTree() -> Bool {
        // 조건 2: 루트는 black이어야 함
        if let root = root, root.isRed {
            print("❌ 루트 노드가 RED입니다.")
            return false
        }

        // 실제 검사는 재귀 함수로 수행
        let (isValid, _) = checkSubtree(node: root)
        return isValid
    }

    /// 서브트리를 재귀적으로 검사하며, (유효성 여부, black-height) 반환
    private func checkSubtree(node: RBNode<T>?) -> (Bool, Int) {
        // nil = 리프 노드 → black-height = 1
        guard let node = node else {
            return (true, 1)
        }

        // 조건 4: red 노드의 자식은 black이어야 함
        if node.isRed {
            if node.left?.isRed == true || node.right?.isRed == true {
                print("❌ 연속된 빨간 노드가 발견됨: \(node.value)")
                return (false, 0)
            }
        }

        // 좌/우 서브트리 검증
        let (leftValid, leftBlackHeight) = checkSubtree(node: node.left)
        let (rightValid, rightBlackHeight) = checkSubtree(node: node.right)

        if !leftValid || !rightValid {
            return (false, 0)
        }

        // 조건 5: 좌우 서브트리의 black-height 일치해야 함
        if leftBlackHeight != rightBlackHeight {
            print("❌ black-height 불일치: \(node.value), left: \(leftBlackHeight), right: \(rightBlackHeight)")
            return (false, 0)
        }

        // 현재 노드가 black이면 +1
        let currentBlackHeight = node.isBlack ? leftBlackHeight + 1 : leftBlackHeight

        return (true, currentBlackHeight)
    }
}

let tree = RedBlackTree<Int>()
tree.insert(10)
tree.insert(5)
tree.insert(20)
tree.insert(15)
tree.insert(25)
tree.insert(3)
tree.insert(7)

tree.printTree()


if tree.isValidRedBlackTree() {
    print("✅ 트리는 유효한 Red-Black Tree입니다.")
} else {
    print("❌ 트리는 유효하지 않습니다.")
}

//: [Next](@next)
