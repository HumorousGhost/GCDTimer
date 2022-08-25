# GCDTimer

Encapsulate DispatchSourceTimer with functions including timer, countdown, and execution after a few seconds.

## Usage

timer

```swift
let timer = GCDTimer()
timer.start(1) {
    // code
}
timer.pause()
timer.restart()
timer.stop()
```

countdown
```swift
let timer = GCDTimer()
timer.countdown(60, repeating: 1) {
    // code
}
```

execution after a few seconds
```swift
let timer = GCDTimer()
timer.after(1.5) {
    // code
}
```

**Note:** Execute after a few seconds can be executed concurrently with the other two operations.

**For Exmple**
```swift
let timer = GCDTimer()
timer.after(2) {
    // code
}
timer.start(1) {
    // code
}
```

## Installation

You can add GCDTimer to an Xcode project by adding it as a package dependency.

* From the **File** menu, select **Swift Packages** > **Add Package Dependency...**
* Enter https://github.com/HumorousGhost/GCDTimer into the package repository URL text field.
* Link **GCDTimer** to your application target.
