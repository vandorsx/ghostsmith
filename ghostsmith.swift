import Cocoa

// MARK: - NSImage+Extension.swift

extension NSImage {
    /// Combine multiple images with the given blend modes.
    static func combine(images: [NSImage], blendingModes: [CGBlendMode]) -> NSImage? {
        guard images.count == blendingModes.count else { return nil }
        guard images.count > 0 else { return nil }

        // The final size will be the same size as our first image.
        let size = images.first!.size

        // Create a bitmap context manually
        guard let bitmapContext = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        // Clear the context
        bitmapContext.setFillColor(.clear)
        bitmapContext.fill(.init(origin: .zero, size: size))

        // Draw each image with its corresponding blend mode
        for (index, image) in images.enumerated() {
            guard let cgImage = image.cgImage(
                forProposedRect: nil,
                context: nil,
                hints: nil
            ) else { return nil }

            let blendMode = blendingModes[index]
            bitmapContext.setBlendMode(blendMode)
            bitmapContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }

        // Create a CGImage from the context
        guard let combinedCGImage = bitmapContext.makeImage() else { return nil }

        // Wrap the CGImage in an NSImage
        return NSImage(cgImage: combinedCGImage, size: size)
    }

    /// Apply a gradient onto this image, using this image as a mask.
    func gradient(colors: [NSColor]) -> NSImage? {
        let resultImage = NSImage(size: size)
        resultImage.lockFocus()
        defer { resultImage.unlockFocus() }

        // Draw the gradient
        guard let gradient = NSGradient(colors: colors) else { return nil }
        gradient.draw(in: .init(origin: .zero, size: size), angle: 90)

        // Apply the mask
        draw(at: .zero, from: .zero, operation: .destinationIn, fraction: 1.0)

        return resultImage
    }

    // Tint an NSImage with the given color by applying a basic fill on top of it.
    func tint(color: NSColor) -> NSImage? {
        // Create a new image with the same size as the base image
        let newImage = NSImage(size: size)

        // Draw into the new image
        newImage.lockFocus()
        defer { newImage.unlockFocus() }

        // Set up the drawing context
        guard let context = NSGraphicsContext.current?.cgContext else { return nil }
        defer { context.restoreGState() }

        // Draw the base image
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        context.draw(cgImage, in: .init(origin: .zero, size: size))

        // Set the tint color and blend mode
        context.setFillColor(color.cgColor)
        context.setBlendMode(.sourceAtop)

        // Apply the tint color over the entire image
        context.fill(.init(origin: .zero, size: size))

        return newImage
    }
}

// MARK: - ColorizedGhosttyIcon.swift

enum MacOSIconFrame: String, CaseIterable {
    case aluminum
    case beige
    case chrome
    case plastic
}

struct ColorizedGhosttyIcon {
    /// The colors that make up the gradient of the screen.
    let screenColors: [NSColor]

    /// The color of the ghost.
    let ghostColor: NSColor

    /// The frame type to use
    let frame: MacOSIconFrame

    /// Make a custom colorized ghostty icon.
    func makeImage() -> NSImage? {
        // Get the path to the executable
        guard let executableURL = Bundle.main.executableURL else {
            print("Error: Could not determine executable URL.")
            return nil
        }
        let imagesFolderURL = executableURL.deletingLastPathComponent().appendingPathComponent("assets")
        // All of our layers (not in order)
        guard let screen = NSImage(contentsOf: imagesFolderURL.appendingPathComponent("CustomIconScreen.png")) else { print("Error: Could not load CustomIconScreen.png"); return nil }
        guard let screenMask = NSImage(contentsOf: imagesFolderURL.appendingPathComponent("CustomIconScreenMask.png")) else { print("Error: Could not load CustomIconScreenMask.png"); return nil }
        guard let ghost = NSImage(contentsOf: imagesFolderURL.appendingPathComponent("CustomIconGhost.png")) else { print("Error: Could not load CustomIconGhost.png"); return nil}
        guard let crt = NSImage(contentsOf: imagesFolderURL.appendingPathComponent("CustomIconCRT.png")) else { print("Error: Could not load CustomIconCRT.png"); return nil}
        guard let gloss = NSImage(contentsOf: imagesFolderURL.appendingPathComponent("CustomIconGloss.png")) else { print("Error: Could not load CustomIconGloss.png"); return nil}

        let baseName = switch (frame) {
        case .aluminum: "CustomIconBaseAluminum"
        case .beige: "CustomIconBaseBeige"
        case .chrome: "CustomIconBaseChrome"
        case .plastic: "CustomIconBasePlastic"
        }
        guard let base = NSImage(contentsOf: imagesFolderURL.appendingPathComponent("\(baseName).png")) else { print("Error: Could not load \(baseName).png"); return nil}

        // Apply our color in various ways to our layers.
        guard let screenGradient = screenMask.gradient(colors: screenColors) else { return nil }
        guard let tintedGhost = ghost.tint(color: ghostColor) else { return nil }

        // Combine our layers using the proper blending modes
        return NSImage.combine(images: [
            base,
            screen,
            screenGradient,
            ghost,
            tintedGhost,
            crt,
            gloss,
        ], blendingModes: [
            .normal,
            .normal,
            .color,
            .normal,
            .color,
            .overlay,
            .normal,
        ])
    }
}

// MARK: - Helper Functions

// Function to parse the rgb.txt file and create a color dictionary
func loadColorMap(from fileURL: URL) -> [String: NSColor] {
    var colorMap: [String: NSColor] = [:]

    do {
        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = fileContents.components(separatedBy: "\n")

        for line in lines {
            // Ignore empty lines or lines starting with "#" (comments)
            if line.isEmpty || line.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
                continue
            }

            let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

            if components.count >= 4 {
                // Extract RGB values (first 3 components)
                if let red = Int(components[0]),
                   let green = Int(components[1]),
                   let blue = Int(components[2]),
                   red >= 0, red <= 255,
                   green >= 0, green <= 255,
                   blue >= 0, blue <= 255 {
                    // Combine the remaining components to form the color name
                    let colorName = components[3...].joined(separator: " ").lowercased()

                    // Create NSColor and add to dictionary
                    let color = NSColor(red: CGFloat(red) / 255.0,
                                        green: CGFloat(green) / 255.0,
                                        blue: CGFloat(blue) / 255.0,
                                        alpha: 1.0)
                    colorMap[colorName] = color
                } else {
                    print("Invalid RGB values in line: \(line)")
                }
            } else {
                print("Invalid format in line: \(line)")
            }
        }
    } catch {
        print("Error loading color map: \(error)")
    }

    return colorMap
}

// Function to parse a color string (either named color or hex code)
func parseColor(_ colorString: String, colorMap: [String: NSColor]) -> NSColor? {
    // Check if the color string exists in the color map
    if let color = colorMap[colorString.lowercased()] {
        return color
    }

    // Attempt to parse hex color
    if colorString.hasPrefix("#") {
        let hexString = String(colorString.dropFirst())
        var hexNumber: UInt64 = 0
        if Scanner(string: hexString).scanHexInt64(&hexNumber) {
            let red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            let green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            let blue = CGFloat(hexNumber & 0x0000ff) / 255
            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }

    return nil
}

func saveImageAsPNG(image: NSImage, filename: String) {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Error: Could not convert NSImage to CGImage")
        return
    }
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Error: Could not convert image to PNG data")
        return
    }
    do {
        try pngData.write(to: URL(fileURLWithPath: filename))
        print("Image saved as \(filename)")
    } catch {
        print("Error saving image: \(error)")
    }
}

// MARK: - Main Program Logic

@main
struct GhostSmith {
    static func main() {
        // Get the path to the executable
        guard let executableURL = Bundle.main.executableURL else {
            print("Error: Could not determine executable URL.")
            exit(1)
        }

        // Construct the path to the "rgb.txt" file
        let rgbFileURL = executableURL
            .deletingLastPathComponent()
            .appendingPathComponent("assets")
            .appendingPathComponent("rgb.txt")

        // Load the color map from the "rgb.txt" file
        let colorMap = loadColorMap(from: rgbFileURL)

        // Initialize variables
        var screenColorStrings: [String] = []
        var ghostColorString: String?
        var frameString: String?

        // Parse command line arguments
        let arguments = CommandLine.arguments
        var i = 1
        while i < arguments.count {
            switch arguments[i] {
            case "--screen-color":
                i += 1
                if i < arguments.count {
                    // Split screen colors by comma
                    screenColorStrings = arguments[i].components(separatedBy: ",")
                }
                i += 1
            case "--ghost-color":
                ghostColorString = arguments[i + 1]
                i += 2
            case "--frame":
                frameString = arguments[i + 1]
                i += 2
            default:
                i += 1
            }
        }

        // Validate and process inputs
        guard screenColorStrings.count >= 1 else {
            print("Error: At least one screen color is required.")
            return
        }

        // Trim whitespace from screen color strings
        let trimmedScreenColorStrings = screenColorStrings.map { $0.trimmingCharacters(in: .whitespaces) }

        let screenColors = trimmedScreenColorStrings.compactMap { parseColor($0, colorMap: colorMap) }
        if screenColors.count != trimmedScreenColorStrings.count {
            print("Error: Invalid screen color(s) provided.")
            return
        }

        guard let ghostColorString = ghostColorString, let ghostColor = parseColor(ghostColorString.trimmingCharacters(in: .whitespaces), colorMap: colorMap) else {
            print("Error: Invalid or missing ghost color.")
            return
        }

        guard let frameString = frameString, let frame = MacOSIconFrame(rawValue: frameString.trimmingCharacters(in: .whitespaces).lowercased()) else {
            print("Error: Invalid or missing frame type. Choose from: aluminum, beige, chrome, plastic")
            return
        }

        // Create and save the image
        let iconGenerator = ColorizedGhosttyIcon(screenColors: screenColors, ghostColor: ghostColor, frame: frame)
        if let icon = iconGenerator.makeImage() {
            saveImageAsPNG(image: icon, filename: "custom-icon.png")
        } else {
            print("Error: Could not generate icon.")
        }
    }
}
