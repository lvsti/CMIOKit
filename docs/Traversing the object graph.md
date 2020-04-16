# Traversing the object graph

No CMIO object exists alone, each of them are connected to other objects in some way or another. For some applications, it may be useful to be able to traverse this object network while collecting certain properties for the visited nodes along the way. In CMIOKit, this can easily be accomplished with the `CMIONode` recursive structure.

Each `CMIONode` has an object ID as a bare minimum, but beyond that it's up to the API user to decide what to do with it. There are 2 customization points: node hierarchy and contents.

### Hierarchy

There is an inherent hierarchy in CMIO objects based on the `.ownedObjects` property. At the root, there is the `.systemObject` which typically owns plugins and devices, and devices own their streams and controls. Since traversing this hierarchy is a common scenario, CMIOKit offers it out-of-the-box:

```swift
let ownershipTree = CMIONode(objectID: .systemObject)
print("immediate children of the system object: \(ownershipTree.children)")
```

However, there can be a need to e.g. filter or flatten this hierarchy, or build a graph based on a completely different relationship. The `hierarchy` argument of the `CMIONode` initializer can be used to specify such custom traversals:

```swift
let appleObjectsOnly: (CMIOObjectID) -> [CMIOObjectID] { objectID in
    if case .string(let creator) = ObjectProperty.creator.value(in: objectID), 
       creator.starts(with: "com.apple."),
       case .arrayOfObjectIDs(let ids) = ObjectProperty.ownedObjects.value(in: objectID)
    {
        return ids
    }
    return []
}
let appleTree = CMIONode(objectID: .systemObject, 
                         hierarchy: .custom(appleObjectsOnly))
```

### Contents

Nodes can expose arbitrary information for the represented CMIO objects. The bag of properties that a node should hold is specified by passing a type to the `propertySource` parameter of `CMIONode` that conforms to `CMIOPropertySource`. The conforming object is responsible for querying and storing whatever information is necessary for a node. The following example retrieves the object name and class for each CMIO object it is invoked for:

```swift
struct NameAndClass: CMIOPropertySource {
    let classID: CMIOClassID
    let name: String

    static func properties(for objectID: CMIOObjectID) -> Self {
        if case .classID(let id) = ObjectProperty.class.value(in: objectID),
           case .string(let name) = ObjectProperty.name.value(in: objectID)
        {
            return NameAndClass(classID: id, name: name)
        }
        return NameAndClass(classID: .object, name: "?")
    }
}

let nameAndClassTree = CMIONode(objectID: .systemObject, propertySource: NameAndClass.self)
if let firstChild = nameAndClassTree.children.first {
    print("first child name: \(firstChild.name), classID: \(firstChild.classID)")
}
```