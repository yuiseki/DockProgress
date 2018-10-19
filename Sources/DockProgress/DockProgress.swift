import Cocoa

public final class DockProgress : NSObject {
	private static let appIcon = NSApp.applicationIconImage!
	private static var previousProgressValue: Double = 0
	private static var progressObserver: NSKeyValueObservation?

	private static var dockImageView = with(NSImageView()) {
		NSApp.dockTile.contentView = $0
	}

	public static var progress: Progress? {
		didSet {
			if let progress = progress {
				progressObserver = progress.observe(\.fractionCompleted) { object, _ in
					progressValue = object.fractionCompleted
				}
			}
		}
	}

	public static var progressValue: Double = 0 {
		didSet {
			if previousProgressValue == 0 || (progressValue - previousProgressValue).magnitude > 0.01 {
				previousProgressValue = progressValue
				updateDockIcon()
			}
		}
	}

	@objc public static func setProgressValue(_ newProgressValue: NSNumber) {
        progressValue = newProgressValue.doubleValue
    }

	public enum ProgressStyle {
		case bar
		/// TODO: Make `color` optional when https://github.com/apple/swift-evolution/blob/master/proposals/0155-normalize-enum-case-representation.md is shipping in Swift
		case circle(radius: Double, color: NSColor)
		case custom(drawHandler: (_ rect: CGRect) -> Void)
	}

	public static var style: ProgressStyle = .bar
	
	@objc public static func setProgressStyle(_ newStyle: NSString, radius: NSNumber, color: NSColor){
		switch newStyle {
		case "bar":
			style = .bar
		case "circle":
			style = .circle(radius: radius.doubleValue, color: color)
		default:
			style = .bar
		}
	}

	/// TODO: Make the progress smoother by also animating the steps between each call to `updateDockIcon()`
	private static func updateDockIcon() {
		/// TODO: If the `progressValue` is 1, draw the full circle, then schedule another draw in n milliseconds to hide it
		let icon = (0..<1).contains(self.progressValue) ? self.draw() : appIcon
		DispatchQueue.main.async {
			/// TODO: Make this better by drawing in the `contentView` directly instead of using an image
			dockImageView.image = icon
			NSApp.dockTile.display()
		}
	}

	private static func draw() -> NSImage {
		return NSImage(size: appIcon.size, flipped: false) { dstRect in
			NSGraphicsContext.current?.imageInterpolation = .high
			self.appIcon.draw(in: dstRect)

			switch self.style {
			case .bar:
				self.drawProgressBar(dstRect)
			case let .circle(radius, color):
				self.drawProgressCircle(dstRect, radius: radius, color: color)
			case let .custom(drawingHandler):
				drawingHandler(dstRect)
			}

			return true
		}
	}

	private static func drawProgressBar(_ dstRect: CGRect) {
		func roundedRect(_ rect: CGRect) {
			NSBezierPath(roundedRect: rect, cornerRadius: rect.height / 2).fill()
		}

		let bar = CGRect(x: 0, y: 20, width: dstRect.width, height: 10)
		NSColor.white.with(alpha: 0.8).set()
		roundedRect(bar)

		let barInnerBg = bar.insetBy(dx: 0.5, dy: 0.5)
		NSColor.black.with(alpha: 0.8).set()
		roundedRect(barInnerBg)

		var barProgress = bar.insetBy(dx: 1, dy: 1)
		barProgress.size.width = barProgress.width * CGFloat(progressValue)
		NSColor.white.set()
		roundedRect(barProgress)
	}

	private static func drawProgressCircle(_ dstRect: CGRect, radius: Double, color: NSColor) {
		guard let cgContext = NSGraphicsContext.current?.cgContext else {
			return
		}

		let progressCircle = ProgressCircleShapeLayer(radius: radius, center: dstRect.center)
		progressCircle.strokeColor = color.cgColor
		progressCircle.lineWidth = 4
		progressCircle.cornerRadius = 3
		progressCircle.progress = progressValue
		progressCircle.render(in: cgContext)
	}
}
