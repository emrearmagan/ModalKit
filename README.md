# ModalKit

![Platform](https://img.shields.io/badge/platform-ios-lightgray.svg)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-blue.svg)
[![SwiftPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
![MIT](https://img.shields.io/github/license/mashape/apistatus.svg)

**ModalKit** is a simple and flexible framework for managing modal view presentations in iOS. With support for custom animations, configurable presentation sizes, and interactive gestures. ModalKit simplifies the process of creating dynamic and user-friendly modal interfaces.

[📖 Documentation](https://emrearmagan.github.io/ModalKit/)

<div align="center">
  <img src="./Example/Supporting Files/Preview/TableView.gif" width="24%">
  <img src="./Example/Supporting Files/Preview/Default.gif" width="24%">
  <img src="./Example/Supporting Files/Preview/Textfield.gif" width="24%">
  <img src="./Example/Supporting Files/Preview/TabBar.gif" width="24%">
</div>

> **⚠️ Important**  
> The current version is still in development. There can and will be breaking changes in version updates until version 1.0.

## Features
- `Multiple Sticky Points`: Transition between predefined modal heights, such as small, medium, and large.
- `Scroll View Integration`: Seamlessly handle scroll views, enabling smooth transitions between scrolling and dragging.
- `Dynamic Resizing`: Adapt the modal's size programmatically or based on content changes.

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

## Presentation Sizes
ModalKit supports a variety of presentation sizes, which can be defined using the `MKPresentationSize` enum:

- `.large`: Full-screen presentation.
- `.medium`: Half-screen presentation.
- `.small`: Quarter-screen presentation.
- `.contentHeight(CGFloat)`: Fixed height.
- `.intrinsicHeight`: Automatically adjusts based on content size.
- `.additionalHeight(MKPresentationSize, CGFloat)`: Allows specifying an additional offset height relative to another presentation size.

You can provide multiple options in preferredPresentationSize. The modal can snap to whichever is appropriate.

Example:
```swift
class MyViewController: MKPresentable {
    var preferredPresentationSize: [MKPresentationSize] {
        return [.small, .intrinsicHeight, .large]
}
```

<img src="./Example/Supporting Files/Preview/Sizes.gif" width="30%">

#### Transition to a New Presentation Size
You also can programmatically transition the modal to a different size:
```swift
self.transition(to: .medium)
```
This method animates the modal to the new size while respecting the constraints defined by `MKPresentationSize`. This is particularly useful for modals that need to adapt dynamically to user interactions or content changes.

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

    // Called when the dimming view is tapped.
    // By default, this dismisses the modal. Override for custom behavior.
    func onDimmingViewTap() {
        dismiss(animated: true)
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

## Dynamic Layout Updates
ModalKit provides methods to handle layout changes during runtime, ensuring modals adjust properly when their content or constraints change.
This is especially useful for dynamic content, such as updated text, added views, or changes in size requirements.

### Force Layout Updates
If the layout of the modal is affected by content changes or external updates, you can manually trigger a recalculation to ensure the modal adjusts to its new size. By calling the `presentationLayoutIfNeeded()` method, the modal updates its layout and animates to the correct position based on the `preferredPresentationSize` or other defined size configurations:

```swift
self.updateUI()
self.presentationLayoutIfNeeded()
```
<div align="center">
    <img src="./Example/Supporting Files/Preview/Layout1.gif" width="35%">
    <img src="./Example/Supporting Files/Preview/Layout2.gif" width="35%">
</div>


## MKPresentableConfiguration
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

## Scroll View Integration
ModalKit provides built-in support for `UIScrollView` and its subclasses, such as `UITableView` and `UICollectionView`, allowing seamless interaction between scrolling and modal gestures. `ModalKit` ensures smooth transitions when scrolling content overlaps with dragging gestures to resize or dismiss the modal.

### Example
To enable scroll view integration, implement the `MKPresentable` protocol and return your scroll view in the `scrollView` property:
```swift
class MyViewController: MKPresentable {
    var scrollView: UIScrollView? {
        return myTableView
    }
}
```
<img src="./Example/Supporting Files/Preview/ScrollViewExample.gif" width="30%">

Handoff Between Scroll and Drag: When the scroll view is at the top or bottom of its content, dragging gestures transition seamlessly to resizing or dismissing the modal.
ModalKit observes the scroll view's content offset to determine when to allow dragging or maintain scrolling behavior.

If you need to customize the interaction between the scroll view and the modal, you can override the shouldContinue(with:) method in the MKPresentable protocol:
```swift
class MyViewController: MKPresentable {
    var scrollView: UIScrollView? {
        return myTableView
    }

    func shouldContinue(with gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        // Custom logic to determine if dragging should continue
        return true
    }
}
```

## TabBar Integration
`ModalKit works also great with `UITabBarController`, ensuring that modals are presented above the tab bar without interfering with its functionality. `ModalKit` automatically handles the safe area insets and adjusts the modal's layout to avoid overlapping with the tab bar.

### Example
```swift
class MyTabBarViewController: UITabBarController, MKPresentable {
    /// The preferred presentation size for the currently selected view controller.
    var preferredPresentationSize: [MKPresentationSize] {
        if let vc = selectedViewController as? MKPresentable {
            return vc.preferredPresentationSize
        }
        return [.large]
    }
}
```
<img src="./Example/Supporting Files/Preview/TabBarExample.gif" width="30%">

## Navigation Controller Integration
`ModalKit` is fully compatible with UINavigationController, allowing modals to be presented within navigation stacks. It also supports smooth transitions between pushed view controllers and modally presented views.

### Example

```swift
class MyNavigationViewController: UINavigationController, UINavigationControllerDelegate, MKPresentable {
    /// Returns the preferred presentation size of the top view controller if it conforms to `MKPresentable`,
    /// otherwise defaults to `.large`.
    var preferredPresentationSize: [MKPresentationSize] {
        if let vc = topViewController as? MKPresentable {
            return vc.preferredPresentationSize
        }
        return [.large]
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.isBeingPresented else { return }
        /// Ensures the presentation layout is updated when transitioning between view controllers.
        presentationLayoutIfNeeded()
    }
}
```
<img src="./Example/Supporting Files/Preview/NavigationExample.gif" width="30%">

## Examples
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
    .package(url: "https://github.com/emrearmagan/ModalKit.git")
]
```

### Manual Installation
1. Download ModalKit.zip from the latest release and extract its content in your project's folder.
2. From the Xcode project, choose **Add Files to ...** from the File menu and add the extracted files.

## Contributing
Contributions are welcome! If you’d like to contribute, please open a pull request or issue on GitHub.

## License
`ModalKit` is available under the MIT license. See the LICENSE file for more information.

