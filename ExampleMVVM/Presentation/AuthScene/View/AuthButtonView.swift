//
//  AuthButtonView.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 29/12/1447 AH.
//

import UIKit

final class AuthButtonView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var button: UIButton!

    enum ButtonStyle {
        case filled
        case outlined
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib()
    }

    private func loadViewFromNib() {
        Bundle(for: AuthButtonView.self).loadNibNamed("AuthButtonView", owner: self, options: nil)

        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    func configure(title: String, style: ButtonStyle) {
        button.setTitle(title, for: .normal)

        switch style {
        case .filled:
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 0

        case .outlined:
            button.backgroundColor = .clear
            button.setTitleColor(button.tintColor, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = button.tintColor.cgColor
        }
    }

    func addTarget(_ target: Any?, action: Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
    }
}
