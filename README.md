# AEConicalGradient
**Conical (angular) gradient in Swift**

[![Language Swift 2.2](https://img.shields.io/badge/Language-Swift%202.2-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/tadija/AEConicalGradient/blob/master/LICENSE)

[![CocoaPods Version](https://img.shields.io/cocoapods/v/AEConicalGradient.svg?style=flat)](https://cocoapods.org/pods/AEConicalGradient)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

> You never think about a conical gradient written in Swift until you need one. I hope that somebody will find this useful. And nice. 

![AEConicalGradient](http://tadija.net/projects/AEConicalGradient/AEConicalGradient.png)

## Usage

**AEConicalGradient** is a [minion](http://tadija.net/public/minion.png) which consists of two objects:  

- [AEConicalGradientLayer](Sources/AEConicalGradientLayer.swift)  
Subclass of `CALayer` which performs drawing of conical gradient. You can set colors and locations for the gradient. 
If no colors are set, default colors will be used. If no locations are set, colors will be equally distributed.  

- [AEConicalGradientView](Sources/AEConicalGradientView.swift)  
Subclass of `UIView` which uses `AEConicalGradientLayer` as the view’s Core Animation layer. 
You can configure conical gradient options with `gradientLayer` property.

## Requirements
- Xcode 7.0+
- iOS 8.0+

## Installation

- [CocoaPods](http://cocoapods.org/):

    ```ruby
    pod 'AEConicalGradient'
    ```

- [Carthage](https://github.com/Carthage/Carthage):

    ```ogdl
    github "tadija/AEConicalGradient"
    ```

- Manually:

    Just drag *AEConicalGradientLayer.swift* and *AEConicalGradientView.swift* into your project and that's it.

## License
AEConicalGradient is released under the MIT license. See [LICENSE](LICENSE) for details.
