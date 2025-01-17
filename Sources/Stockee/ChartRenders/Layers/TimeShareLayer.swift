//
//  GradientLayer.swift
//  Stockee
//
//  Created by octree on 2022/3/31.
//
//  Copyright (c) 2022 Octree <fouljz@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

private final class _GradientLayer: CAGradientLayer {
    override func action(forKey event: String) -> CAAction? {
        nil
    }

    override class func defaultAction(forKey event: String) -> CAAction? {
        nil
    }
}

/// 绘制分时图的 Layer
final class TimeShareLayer: CALayer {
    private var gradientLayer: _GradientLayer = .init()
    private var maskLayer: ShapeLayer = .init()
    private var lineLayer: ShapeLayer = .init()
    private var indicatorLayer: ShapeLayer = .init()
    private var indicatorShadowLayer: ShapeLayer = .init()
    
    private let indicatorWidth: CGFloat = 6

    override public init() {
        super.init()
        configureHierarchy()
    }
    
    override public init(layer: Any) {
        guard let layer = layer as? TimeShareLayer else {
            fatalError("init(layer:) error: layer: \(layer)")
        }
        super.init()
        configureHierarchy()
        frame = layer.frame
        gradientLayer.colors = layer.gradientLayer.colors
        gradientLayer.frame = layer.gradientLayer.frame
        lineLayer.strokeColor = layer.lineLayer.strokeColor
        lineLayer.path = layer.lineLayer.path
        maskLayer.path = layer.maskLayer.path
        indicatorLayer.backgroundColor = layer.indicatorLayer.backgroundColor
        indicatorShadowLayer.shadowColor = layer.indicatorShadowLayer.shadowColor
        indicatorShadowLayer.isHidden = layer.indicatorShadowLayer.isHidden
        indicatorShadowLayer.frame = layer.indicatorShadowLayer.frame
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureHierarchy()
    }

    func update(color: UIColor, indicatorShadowColor: UIColor) {
        gradientLayer.colors = [
            color.withAlphaComponent(0.3).cgColor,
            color.withAlphaComponent(0.01).cgColor
        ]
        lineLayer.strokeColor = color.cgColor
        indicatorLayer.backgroundColor = color.cgColor
        indicatorShadowLayer.shadowColor = indicatorShadowColor.cgColor
    }

    // MARK: - Public

    func update<Q: Quote>(with context: RendererContext<Q>) {
        guard !context.visibleRange.isEmpty else { 
            indicatorShadowLayer.isHidden = true
            return
        }
        let start = max(0, context.visibleRange.startIndex - 1)
        let end = min(context.data.count, context.visibleRange.endIndex + 1)
        let minX = context.layout.quoteMidX(at: start)
        let maxX = context.layout.quoteMidX(at: end - 1)
        var rect = context.contentRect
        let minY = rect.minY
        rect.origin.x = minX
        rect.size.width = maxX - minX
        frame = rect
        gradientLayer.frame = bounds
        let path = CGMutablePath()

        func point(forQuoteAt index: Int) -> CGPoint {
            let x = context.layout.quoteMidX(at: index) - minX
            let y = context.yOffset(for: context.data[index].close) - minY
            return .init(x: x, y: y)
        }

        path.move(to: point(forQuoteAt: start))

        for index in (start ..< end).dropFirst() {
            path.addLine(to: point(forQuoteAt: index))
        }
        lineLayer.path = path
        path.addLine(to: CGPoint(x: frame.width, y: frame.height))
        path.addLine(to: CGPoint(x: 0, y: frame.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        maskLayer.path = path
        
        if context.visibleRange.contains(context.data.count - 1) {
            indicatorShadowLayer.isHidden = false
            let lastPointX = context.layout.quoteMidX(at: context.data.count - 1) - minX - indicatorWidth / 2
            let lastPointY = context.yOffset(for: context.data.last!.close) - minY - indicatorWidth / 2
            indicatorShadowLayer.frame = CGRectMake(lastPointX, lastPointY, indicatorWidth, indicatorWidth)
        } else {
            indicatorShadowLayer.isHidden = true
        }
    }

    // MARK: Override

    override func action(forKey event: String) -> CAAction? {
        nil
    }

    override class func defaultAction(forKey event: String) -> CAAction? {
        nil
    }

    // MARK: - Private

    private func configureHierarchy() {
        addSublayer(gradientLayer)
        addSublayer(lineLayer)
        lineLayer.lineWidth = 1
        lineLayer.fillColor = UIColor.clear.cgColor
        gradientLayer.startPoint = .init(x: 0.5, y: 0)
        gradientLayer.endPoint = .init(x: 0.5, y: 1)
        gradientLayer.mask = maskLayer
        
        
        addSublayer(indicatorShadowLayer)
        indicatorShadowLayer.masksToBounds = false
        indicatorShadowLayer.shadowRadius = 8
        indicatorShadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        indicatorShadowLayer.shadowOpacity = 1
        
        indicatorShadowLayer.addSublayer(indicatorLayer)
        indicatorLayer.backgroundColor = UIColor.clear.cgColor
        indicatorLayer.masksToBounds = true
        indicatorLayer.cornerRadius = indicatorWidth/2
        indicatorLayer.frame = CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorWidth)
    }
}
