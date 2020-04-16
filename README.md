# CMIOKit

Swift wrapper around the CoreMediaIO C APIs

### Description

CoreMediaIO (CMIO for short) is a neglected foster child in the macOS platform SDK for that its API is still a decades-old C interface that auto-translates miserably to Swift with all that unsafe pointer business going on. CMIOKit aims at offering a somewhat higher-level, developer-friendly API for these calls while making no simplifications or compromises on the data that can be accessed.

### Elevator pitch

Why would you write this:

```swift
var address = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
                                        mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
                                        mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
let dataSize = UInt32(MemoryLayout<UInt32>.size)
var dataUsed: UInt32 = 0
var data = UnsafeMutableRawPointer.allocate(byteCount: Int(dataSize), alignment: MemoryLayout<UInt32>.alignment)
defer { data.deallocate() }

let status = CMIOObjectGetPropertyData(objectID, &address, 0, nil, dataSize, &dataUsed, data)
if status == kCMIOHardwareNoError {
    let typedData = data.bindMemory(to: UInt32.self, capacity: 1)
    print("property value = \(typedData.pointee)")
}
```

when you can also do this?

```swift
if case .boolean(let value) = SystemProperty.allowScreenCaptureDevices.value(in: .systemObject) {
    print("property value = \(value)")
}
```

### Usage

See the [docs](https://github.com/lvsti/CMIOKit/blob/master/docs) for more detailed instructions.

### Requirements

To build: Xcode 10.1+, Swift 4.2+<br/>
To use: macOS 10.13+

Note: To use CMIOKit in your application, you'll need to link to the `CoreMediaIO.framework` as well.

### License

MIT