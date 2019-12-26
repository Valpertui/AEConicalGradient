/**
 *  https://github.com/tadija/AEConicalGradient
 *  Copyright (c) Marko Tadić 2015-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit

/**
    Subclass of `CALayer` which draws a conical gradient over its background color,
    filling the shape of the layer (i.e. including rounded corners).
 
    You can set colors and locations for the gradient.

    If no colors are set, default colors will be used.
    If no locations are set, colors will be equally distributed.
*/
open class ConicalGradientLayer: CALayer {

    // MARK: Types

    private struct Constants {
        static let MaxAngle: Double = 2 * .pi
        static let MaxHue = 255.0
    }

    private struct Transition {
        let fromLocation: Double
        let toLocation: Double
        let fromColor: UIColor
        let toColor: UIColor

        func color(forPercent percent: Double) -> UIColor {
            let normalizedPercent = percent.convert(fromMin: fromLocation, max: toLocation, toMin: 0.0, max: 1.0)
            return UIColor.lerp(from: fromColor.rgba, to: toColor.rgba, percent: CGFloat(normalizedPercent))
        }
    }

    // MARK: Properties

    /// The array of UIColor objects defining the color of each gradient stop.
    /// Defaults to empty array. Animatable.
  @NSManaged open var colors: [UIColor]

    /// The array of Double values defining the location of each gradient stop as a value in the range [0,1].
    /// The values must be monotonically increasing.
    /// If empty array is given, the stops are assumed to spread uniformly across the [0,1] range.
    /// Defaults to nil. Animatable.
  @NSManaged open var locations: [Double]

    /// Start angle in radians. Defaults to 0.0.
  @NSManaged open var startAngle: Double
  
  @NSManaged open var angleSize: Double

    private var transitions = [Transition]()
    
    // MARK: Lifecycle

    /// This method is doing actual drawing of the conical gradient.
    open override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        draw(in: ctx.boundingBoxOfClipPath)
        UIGraphicsPopContext()
    }

    // MARK: Helpers

    private func draw(in rect: CGRect) {
      loadTransitions()
      
      let center = CGPoint(x: rect.midX, y: rect.midY)
      let longerSide = max(rect.width, rect.height)
      let radius = Double(longerSide) * 2.squareRoot()
      let step = (.pi / 2) / radius
      let startAngle = self.startAngle.truncatingRemainder(dividingBy: Constants.MaxAngle)
      var currentAngle = startAngle
      let angleSize = self.angleSize.truncatingRemainder(dividingBy: Constants.MaxAngle)
      while currentAngle <= (startAngle + angleSize) {
        let pointX = radius * cos(currentAngle) + Double(center.x)
            let pointY = radius * sin(currentAngle) + Double(center.y)
            let startPoint = CGPoint(x: pointX, y: pointY)

            let line = UIBezierPath()
            line.move(to: startPoint)
            line.addLine(to: center)

        color(forAngle: currentAngle - startAngle, angleSize: angleSize).setStroke()
            line.stroke()

            currentAngle += step
        }
    }
  
  private func color(forAngle angle: Double, angleSize: Double) -> UIColor {
    let percent = angle.convert(fromZeroToMax: angleSize, toZeroToMax: 1.0).truncatingRemainder(dividingBy: 1.0)
    guard let transition = transition(forPercent: percent) else {
      return spectrumColor(forAngle: angle, angleSize: angleSize)
    }
    
    return transition.color(forPercent: percent)
  }

  private func spectrumColor(forAngle angle: Double, angleSize: Double) -> UIColor {
    let hue = angle.convert(fromZeroToMax: angleSize, toZeroToMax: Constants.MaxHue)
    return UIColor(hue: CGFloat(hue / Constants.MaxHue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
  }

  override open class func needsDisplay(forKey key: String) -> Bool {
    if isAnimatableProperty(key) {
      return true
    } else {
      return super.needsDisplay(forKey: key)
    }
  }
  
  /// the properties which are animatable
  static let animatableProperties: [String] = ["angleSize", "startAngle", "colors", "locations"]

  // Returns whether or not a given property key is animatable
  static func isAnimatableProperty(_ key: String) -> Bool {
      return animatableProperties.firstIndex(of: key) != nil
  }
  
  private func loadTransitions() {
    transitions.removeAll()
    
    if colors.count > 1 {
      let transitionsCount = colors.count - 1
      let locationStep = 1.0 / Double(transitionsCount)
      
      for i in 0 ..< transitionsCount {
        let fromLocation, toLocation: Double
        let fromColor, toColor: UIColor
        
        if locations.count == colors.count {
          fromLocation = locations[i]
          toLocation = locations[i + 1]
        } else {
          fromLocation = locationStep * Double(i)
          toLocation = locationStep * Double(i + 1)
        }
        
        fromColor = colors[i]
        toColor = colors[i + 1]
        
        let transition = Transition(fromLocation: fromLocation, toLocation: toLocation,
                                    fromColor: fromColor, toColor: toColor)
        transitions.append(transition)
      }
    }
  }

    private func transition(forPercent percent: Double) -> Transition? {
        let filtered = transitions.filter { percent >= $0.fromLocation && percent < $0.toLocation }
        let defaultTransition = percent <= 0.5 ? transitions.first : transitions.last
        return filtered.first ?? defaultTransition
    }

}

// MARK: - Extensions

private extension Double {
    func convert(fromMin oldMin: Double, max oldMax: Double, toMin newMin: Double, max newMax: Double) -> Double {
        let oldRange, newRange, newValue: Double
        oldRange = (oldMax - oldMin)
        if (oldRange == 0.0) {
            newValue = newMin
        } else {
            newRange = (newMax - newMin)
            newValue = (((self - oldMin) * newRange) / oldRange) + newMin
        }
        return newValue
    }

    func convert(fromZeroToMax oldMax: Double, toZeroToMax newMax: Double) -> Double {
        return ((self * newMax) / oldMax)
    }
}

private extension UIColor {
    struct RGBA {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        init(color: UIColor) {
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
    }

    var rgba: RGBA {
        return RGBA(color: self)
    }

    class func lerp(from: RGBA, to: RGBA, percent: CGFloat) -> UIColor {
        let red = from.red + percent * (to.red - from.red)
        let green = from.green + percent * (to.green - from.green)
        let blue = from.blue + percent * (to.blue - from.blue)
        let alpha = from.alpha + percent * (to.alpha - from.alpha)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
