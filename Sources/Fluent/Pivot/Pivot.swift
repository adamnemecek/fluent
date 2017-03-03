/// A basic Pivot using two entities:
/// left and right.
/// The pivot itself conforms to entity
/// and can be used like any other Fluent model
/// in preparations, querying, etc.
public final class Pivot<
    L: Entity,
    R: Entity
>: PivotProtocol, Entity {
    public typealias Left = L
    public typealias Right = R

    public static var entity: String {
        if Left.name < Right.name {
            return "\(Left.name)\(pivotNameConnector)\(Right.name)"
        } else {
            return "\(Right.name)\(pivotNameConnector)\(Left.name)"
        }
    }

    public static var identifier: String {
        if Left.name < Right.name {
            return "Pivot<\(Left.identifier),\(Right.identifier)>"
        } else {
            return "Pivot<\(Right.identifier),\(Left.identifier)>"
        }
    }

    public static var name: String {
        return entity
    }

    public var leftId: Node
    public var rightId: Node
    public let storage = Storage()

    public init(_ left: Left, _ right: Right) throws {
        guard left.exists else {
            throw PivotError.existRequired(left)
        }

        guard let leftId = left.id else {
            throw PivotError.idRequired(left)
        }

        guard right.exists else {
            throw PivotError.existRequired(right)
        }

        guard let rightId = right.id else {
            throw PivotError.idRequired(right)
        }

        self.leftId = leftId
        self.rightId = rightId
    }

    public init(node: Node) throws {
        leftId = try node.get(Left.foreignIdKey)
        rightId = try node.get(Right.foreignIdKey)

        id = try node.get(idKey)
    }

    public func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(idKey, id)
        try node.set(Left.foreignIdKey, leftId)
        try node.set(Right.foreignIdKey, rightId)
        return node
    }

    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id(for: self)
            builder.foreignId(for: Left.self)
            builder.foreignId(for: Right.self)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

public var pivotNameConnector: String = "_"
