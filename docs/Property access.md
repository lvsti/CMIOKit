# Property access

Undoubtedly, the biggest pain when using raw CMIO is accessing object properties, so this is what CMIOKit's main focus is. 

#### Property sets

In CMIOKit, all known properties are collected and grouped according to the class of object they are defined for. The framework exposes the following property sets:

Property set enum|Description
:---|:---
`ObjectProperty`|properties that apply to any CMIO object
`SystemProperty`|properties of the System object (i.e. the root of the object hierarchy)
`DeviceProperty`|media device properties
`StreamProperty`|media stream properties
`ControlProperty`|properties common to any kind of control object
`BooleanControlProperty`|boolean control properties
`SelectorControlProperty`|selector control properties (discrete value setting)
`FeatureControlProperty`|feature control properties (continuous value setting)
`ExposureControlProperty`|exposure control properties (a video-specific subtype of feature control)

Internally, each property knows its value type and read semantics as well, both based on the information available in the CMIO headers. Reading a property is as easy as calling the `value()` method with the object ID:

```swift
let ret = ObjectProperty.class.value(in: objectID)
```

The return value is an enum with an associated value which should be extracted by pattern matching, for example:

```swift
if case .classID(let value) = ObjectProperty.class.value(in: objectID) {
    print("class ID: \(value)") // prints the numerical value
}
```

Some properties may be writable as well, this can be queried with `isSettable()`. To change the value of a property value, use `setValue`:

```swift
let prop = SystemProperty.allowScreenCaptureDevices
assert(prop.isSettable(in: .systemObject))
prop.setValue(.boolean(true), in: .systemObject)
```

#### Scopes, elements, qualifiers

CMIOKit's property sets only bind the selector part of a `CMIOObjectPropertyAddress`, leaving the scope and element on a default/general value. If a specific scope or element needs to be accessed, this can be done by being explicit about the `scope` and `element` arguments in any of the property accessor methods:

```swift
let ret = DeviceProperty.canBeDefaultDevice.value(scope: .deviceInput, element: .master, in: objectID)
```

Similarly, if a query requires qualifiers, constructing a qualifier and passing it to the `qualifiedBy` argument will do the job:

```swift
let classIDs: [CMIOClassID] = [.plugIn, .device]
let qualifier = Qualifier(fromArray: classIDs)
let ret = ObjectProperty.ownedObjects.value(qualifiedBy: qualifier, in: .systemObject)
```

#### Value translation

CMIO object properties vary in their reading semantics, probably the most curious of which is value translation (currently only exhibited by `SystemProperty.deviceForUID` and `.plugInForBundleID`, as well as `FeatureControlProperty.convertNativeToAbsolute` and `.convertAbsoluteToNative`). In these cases, property read is performed in such a way that the memory for the return value is prefilled with input parameters which affect the read operation. CMIOKit offers the `translateValue()` function to reduce the boilerplate:

```swift
// get the plugin name from the bundle ID
if case .objectID(let pluginID) = SystemProperty.plugInForBundleID.translateValue(.string("com.example.plugin"), in: .systemObject),
   case .string(let name) = ObjectProperty.name(in: pluginID) {
    print("plugin name: \(name)")
}
```

#### Property listeners

CMIO allows interested clients to listen to property changes on certain objects. CMIOKit wraps this functionality in an easy-to-use, closure-based interface:

```swift
let listener = ObjectProperty.ownedObjects.addListener(in: .systemObject) { _ in
    print("top level objects changed!")
}
```

The returned `listener` is an opaque object that acts like a subscription handle which automatically stops listening when deallocated. Alternatively, the subscription can be cancelled manually with the `remove()` function.

```swift
listener?.remove()
```
