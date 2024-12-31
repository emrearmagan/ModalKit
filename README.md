# ModalKit

![Platform](https://img.shields.io/badge/platform-ios-lightgray.svg)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-blue.svg)
![MIT](https://img.shields.io/github/license/mashape/apistatus.svg)

**ModalKit** is a simple and flexible framework for managing modal view presentations in iOS. With support for custom animations, configurable presentation sizes, and interactive gestures, ModalKit simplifies the process of creating dynamic and user-friendly modal interfaces.

<div>
<br>
<div align="center">
<img src="./docs/overview.png" alt="Overview">
</div>

## Usage

#### Basic Usage
To present a view controller with ModalKit:

##### Using the `presentModal` Extension
```swift
import ModalKit

let viewControllerToPresent = MyViewController()
presentModal(viewControllerToPresent)
```

##### Directly Setting Up ModalKit
```swift
import ModalKit

let viewControllerToPresent = MyViewController()
viewControllerToPresent.modalPresentationStyle = .custom
viewControllerToPresent.transitioningDelegate = MKPresentationManager()
present(viewControllerToPresent, animated: true)
```

##### Dismissing the Modal
To dismiss the modal programmatically:
```swift
self.dismiss(animated: true, completion: nil)
```

## MKPresentable
View controllers can conform to the MKPresentable protocol to customize how they are presented. This protocol gives you fine-grained control over:
- Preferred Presentation Sizes
- Scroll View Integration
- Gesture & Transition Control
- Configuration Settings

Below is an example of a **basic conformance** that also demonstrates optional methods you can override to fully control the modal’s behavior, including transitions and scrolling behavior:

```swift
extension MyViewController: MKPresentable {

    // Defines the possible sizes for the presented view controller (e.g., medium & large).
    var preferredPresentationSize: [MKPresentationSize] {
        return [.medium, .large]
    }

    // If your view contains a scroll view (like a UITableView), provide it here.
    // ModalKit will observe its offset to seamlessly hand off between scrolling and dragging the modal.
    var scrollView: UIScrollView? {
        return myTableView
    }

    // Called once before the modal is presented. Use this to configure drag indicators,
    // corner radius, and other presentation options.
    func configure(_ configuration: inout MKPresentableConfiguration) {
        configuration.showDragIndicator = true
        configuration.hasRoundedCorners = true
    }

    // Return false if you want to disallow certain drag gestures (e.g., under some conditions).
    // By default, this returns true, letting the modal's pan gesture proceed.
    func shouldContinue(with gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }

    // Called right before the modal tries to switch to a new size (e.g., from .small to .medium).
    // Return false to block that transition. By default, this returns true.
    func shouldTransition(to size: MKPresentationSize) -> Bool {
        return true
    }

    // Called immediately before the modal begins resizing to the new size.
    // Use this to update your UI (e.g., hiding certain subviews).
    func willTransition(to size: MKPresentationSize) {
        // e.g., hide a toolbar
    }

    // Called after the modal has finished transitioning to the new size.
    // Use this to finalize any layout changes or re-display elements.
    func didTransition(to size: MKPresentationSize) {
        // e.g., show the toolbar again
    }
}
```


### MKPresentableConfiguration
The MKPresentableConfiguration provides a variety of options:

| Option                   | Description                                                                                              |
|--------------------------|----------------------------------------------------------------------------------------------------------|
| `showDragIndicator`      | Indicates whether a drag indicator should be displayed at the top of the modal. Default: `false`.         |
| `dragIndicatorColor`     | The color of the drag indicator, if enabled. Default: `.label`.                                           |
| `dragIndicatorSize`      | The size of the drag indicator, if shown. Default: `CGSize(width: 40, height: 5)`.                        |
| `dismissibleScale`       | Scale at which the vc will be automatically dismissed. Default: `0.6`.                                    |
| `isDismissable`          | Determines whether the modal can be dismissed by dragging. Default: `true`.                              |
| `dragResistance`         | Specifies how resistant the modal is to drag gestures, ranging from `0.0` (no resistance) to `1.0` (full resistance). Default: `0`. |
| `hasRoundedCorners`      | Indicates whether the modal should have rounded corners. Default: `false`.                               |
| `closeOnTap`             | Determines whether tapping outside the modal should dismiss it. Default: `true`.                         |


#### Dynamic Layout Updates
ModalKit provides methods to dynamically adjust the layout and presentation size of modals during runtime.

##### Force Layout Updates
When changes occur that affect the layout of the modal, such as content size updates, you can force the layout to recalculate and animate to the correct position:
```swift
self.presentationLayoutIfNeeded()
```
This ensures that the sheet is correctly laid out according to the `preferredPresentationSize`.

##### Transition to a New Presentation Size
You can programmatically transition the modal to a different size:
```swift
self.transition(to: .medium)
```
This method animates the modal to the new size while respecting the constraints defined by `MKPresentationSize`. This is particularly useful for modals that need to adapt dynamically to user interactions or content changes.


#### Presentation Sizes
ModalKit supports a variety of presentation sizes, which can be defined using the `MKPresentationSize` enum:
- `.large`: Full-screen presentation.
- `.medium`: Half-screen presentation.
- `.small`: Quarter-screen presentation.
- `.contentHeight(CGFloat)`: Fixed height.
- `.intrinsicHeight`: Automatically adjusts based on content size.

You can provide multiple options in preferredPresentationSize. The modal can snap to whichever is appropriate.

Example:
```swift
preferredPresentationSize: [.small, .medium, .large]
```

### Examples
The `ModalKitExample` project provides a variety of usage examples. These examples showcase how to implement and customize ModalKit for different use cases. Explore the `ModalKitExample` project for more details.

## Requirements
- iOS 13.0+
- Xcode 12+
- Swift 5.0+

## Installation

### Swift Package Manager
To integrate `ModalKit` into your project using Swift Package Manager, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/emrearmagan/ModalKit.git", from: "0.0.1")
]
```

### Manual Installation
1. Download ModalKit.zip from the latest release and extract its content in your project's folder.
2. From the Xcode project, choose **Add Files to ...** from the File menu and add the extracted files.

## Contributing
Contributions are welcome! If you’d like to contribute, please open a pull request or issue on GitHub.

## License
`ModalKit` is available under the MIT license. See the LICENSE file for more information.

