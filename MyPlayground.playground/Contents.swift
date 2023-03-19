import Cocoa

var greeting = "Hello, playground"

var myImage = NSImage(contentsOfFile: "/Users/easwar/Pictures/Kollage Icons macOS/Dark/macOS/AppIcon.appiconset/Kollage Icon Dark-1024.png")

extension NSImage {
    
    class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        
        let newColor = color
        newColor.drawSwatch(in: NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
}

func clipImageToShape(imageToClip: NSImage, shapeImage: NSImage) -> NSImage? {
    
    // Get the size of the shape image
    let shapeSize = shapeImage.size
    
    // Create a new image with the same size as the shape image
     let clippedImage = NSImage(size: shapeSize)
    
    // Draw the shape image onto the new image, using the alpha channel as a mask
    clippedImage.lockFocus()
    shapeImage.draw(in: NSRect(x: 0, y: 0, width: shapeSize.width, height: shapeSize.height), from: NSRect(x: 0, y: 0, width: shapeSize.width, height: shapeSize.height), operation: .sourceOver, fraction: 1.0)
    clippedImage.unlockFocus()
    
    // Create a new image with the same size as the image to clip
    let finalImage = NSImage(size: imageToClip.size)
    
    // Draw the image to clip onto the new image, using the clipped image as a mask
    finalImage.lockFocus()
    imageToClip.draw(in: NSRect(x: 0, y: 0, width: shapeSize.width, height: shapeSize.height), from: NSRect(x: 0, y: 0, width: imageToClip.size.width, height: imageToClip.size.height), operation: .sourceIn, fraction: 1.0)
    finalImage.unlockFocus()
    
    // Return the final clipped image
    return finalImage
}


func clipImage(imageToClip: NSImage, shapeImage: NSImage) -> NSImage? {
    
    // Create a new bitmap image with the same dimensions as the shape image
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(shapeImage.size.width), pixelsHigh: Int(shapeImage.size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
        
        print("failed to create bitmap 1")
        return nil
    }
    
    // Draw the shape image onto the bitmap using the alpha channel as a mask
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    shapeImage.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: shapeImage.size), operation: .sourceOver, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    
    // Create a new bitmap image with the same dimensions as the image to clip
    guard let clippedBitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imageToClip.size.width), pixelsHigh: Int(imageToClip.size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
        
        print("failed to create bitmap 2")
        return nil
    }
    
    // Draw the image to clip onto the clipped bitmap using the shape bitmap as a mask
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: clippedBitmap)
    imageToClip.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: imageToClip.size), operation: .sourceIn, fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    
    // Create a new NSImage from the clipped bitmap
    let clippedImage = NSImage(size: imageToClip.size)
    clippedImage.addRepresentation(clippedBitmap)
    
    
    
    print(String(describing: clippedImage))
    return clippedImage
}

var shadow = NSImage.swatchWithColor(color: NSColor.yellow, size: myImage!.size)

let clippedImage = clipImage(imageToClip: shadow, shapeImage: myImage!)
let clippedImage2 = clipImageToShape(imageToClip: shadow, shapeImage: myImage!)
