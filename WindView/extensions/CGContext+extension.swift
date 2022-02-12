//
//  CGContext+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/12.
//

import Foundation
import CoreGraphics
import UIKit

extension CGContext {
    func addCircle(center: CGPoint, with radius: CGFloat) {
        addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(.pi * 2.0), clockwise: false)
    }
    
    open func drawText(_ text: String, at point: CGPoint, align: NSTextAlignment, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5), angleRadians: CGFloat = 0.0, attributes: [NSAttributedString.Key : Any]?)
    {
        let drawPoint = getDrawPoint(text: text, point: point, align: align, attributes: attributes)
        
        if (angleRadians == 0.0)
        {
            UIGraphicsPushContext(self)
            
            (text as NSString).draw(at: drawPoint, withAttributes: attributes)
            
            UIGraphicsPopContext()
        }
        else
        {
            drawText(text, at: drawPoint, anchor: anchor, angleRadians: angleRadians, attributes: attributes)
        }
    }
    
    open func drawText(_ text: String, at point: CGPoint, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5), angleRadians: CGFloat, attributes: [NSAttributedString.Key : Any]?)
    {
        var drawOffset = CGPoint()
        
        UIGraphicsPushContext(self)
        
        if angleRadians != 0.0
        {
            let size = text.size(withAttributes: attributes)
            
            // Move the text drawing rect in a way that it always rotates around its center
            drawOffset.x = -size.width * 0.5
            drawOffset.y = -size.height * 0.5
            
            var translate = point
            
            // Move the "outer" rect relative to the anchor, assuming its centered
            if anchor.x != 0.5 || anchor.y != 0.5
            {
                let rotatedSize = size.rotatedBy(radians: angleRadians)
                
                translate.x -= rotatedSize.width * (anchor.x - 0.5)
                translate.y -= rotatedSize.height * (anchor.y - 0.5)
            }
            
            saveGState()
            translateBy(x: translate.x, y: translate.y)
            rotate(by: angleRadians)
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
            
            restoreGState()
        }
        else
        {
            if anchor.x != 0.0 || anchor.y != 0.0
            {
                let size = text.size(withAttributes: attributes)
                
                drawOffset.x = -size.width * anchor.x
                drawOffset.y = -size.height * anchor.y
            }
            
            drawOffset.x += point.x
            drawOffset.y += point.y
            
            (text as NSString).draw(at: drawOffset, withAttributes: attributes)
        }
        
        UIGraphicsPopContext()
    }
    
    private func getDrawPoint(text: String, point: CGPoint, align: NSTextAlignment, attributes: [NSAttributedString.Key : Any]?) -> CGPoint
    {
        var point = point
        
        if align == .center
        {
            point.x -= text.size(withAttributes: attributes).width / 2.0
        }
        else if align == .right
        {
            point.x -= text.size(withAttributes: attributes).width
        }
        return point
    }
}

extension CGSize {
    func rotatedBy(radians: CGFloat) -> CGSize {
        CGSize(
            width: abs(width * cos(radians)) + abs(height * sin(radians)),
            height: abs(width * sin(radians)) + abs(height * cos(radians))
        )
    }
}
