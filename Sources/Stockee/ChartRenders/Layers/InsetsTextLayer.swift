//
//  InsetsTextLayer.swift
//  BTCTuring
//
//  Created by caishengbo on 2024/1/25.
//  Copyright © 2024 Turing. All rights reserved.
//

import UIKit

public class InsetsTextLayer: ShapeLayer {
    
    private let insets: UIEdgeInsets
    lazy var textLayer: TextLayer = {
        let textLayer = TextLayer()
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.foregroundColor = textColor.cgColor
        return textLayer
    }()
    
    public override var contentsScale: CGFloat {
        didSet {
            textLayer.contentsScale = contentsScale
        }
    }
    
    public var font = UIFont.systemFont(ofSize: 10) {
        didSet {
            textLayer.font = font
            textLayer.fontSize = font.pointSize
        }
    }
    
    public var textColor: UIColor = .white {
        didSet {
            textLayer.foregroundColor = textColor.cgColor
        }
    }
    
    public var text: String = "" {
        didSet {
            textLayer.string = text
        }
    }
    
    public var alignmentMode: CATextLayerAlignmentMode {
        set {
            textLayer.alignmentMode = newValue
        }
        get {
            textLayer.alignmentMode
        }
    }
    
    public override var frame: CGRect {
        didSet {
            textLayer.frame = CGRect(x: insets.left, y: insets.top, width: frame.width - insets.left - insets.right, height: frame.height - insets.top - insets.bottom)
        }
    }
    
    public init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init()
        addSublayer(textLayer)
        contentsScale = UIScreen.main.scale
        allowsEdgeAntialiasing = true
        textLayer.allowsEdgeAntialiasing = true
    }
    
    public override init(layer: Any) {
        guard let layer = layer as? InsetsTextLayer else {
            fatalError("init(layer:) layer class: \(layer)")
        }
        self.insets = layer.insets
        super.init()
        addSublayer(textLayer)
        contentsScale = UIScreen.main.scale
        allowsEdgeAntialiasing = true
        textLayer.allowsEdgeAntialiasing = true
        frame = layer.frame
        contentsScale = layer.contentsScale
        font = layer.font
        textLayer.font = layer.font
        textLayer.fontSize = layer.font.pointSize
        textColor = layer.textColor
        textLayer.foregroundColor = layer.textColor.cgColor
        text = layer.text
        textLayer.string = layer.text
        alignmentMode = layer.alignmentMode
        textLayer.alignmentMode = layer.alignmentMode
        backgroundColor = layer.backgroundColor
        cornerRadius = layer.cornerRadius
        borderWidth = layer.borderWidth
        borderColor = layer.borderColor
        textLayer.frame = layer.textLayer.frame
        zPosition = layer.zPosition
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitTextSize = size
        if size.width != .greatestFiniteMagnitude {
            fitTextSize.width = size.width - insets.left - insets.right
        }
        if size.height != .greatestFiniteMagnitude {
            fitTextSize.height = size.height - insets.top - insets.bottom
        }
        let expectedSize = text.boundingRect(with: fitTextSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let result = CGSize(width: expectedSize.width + insets.left + insets.right, height: expectedSize.height + insets.top + insets.bottom)
        return result
    }
    
    public func sizeToFit() {
        let expectedSize = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let fitFrame = CGRect(origin: frame.origin, size: CGSize(width: expectedSize.width + insets.left + insets.right, height: expectedSize.height + insets.top + insets.bottom))
        frame = fitFrame
    }
}
