//
//  CustomView.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//


import UIKit

class CustomView: UIView {

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init(frame:) called")
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init(coder:) called")
        commonInit()
    }

    private func commonInit() {
        // Common initialization code
        print("commonInit called")
    }

    // MARK: - Awake From Nib

    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib() called")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews() called")
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("draw(_ rect:) called")
        // Example drawing code
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.systemBlue.cgColor)
            context.fill(rect)
        }
    }

    // MARK: - View Hierarchy Changes

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        print("didMoveToSuperview() called")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        print("didMoveToWindow() called")
    }

    // MARK: - Display Updates

    func triggerLayout() {
        print("setNeedsLayout() called")
        self.setNeedsLayout()
    }

    func triggerDisplay() {
        print("setNeedsDisplay() called")
        self.setNeedsDisplay()
    }

    // MARK: - Removal

    func removeView() {
        print("removeFromSuperview() called")
        self.removeFromSuperview()
    }

    // MARK: - Deinitialization

    deinit {
        print("deinit called")
    }
}
