//
//  MainFooterView.swift
//  KidsForm
//
//  Created by Maksim Zimens on 18.02.2025.
//

import UIKit

// MARK: - FooterDelegate

protocol FooterDelegate: AnyObject {
    func didTapDeleteAllButton()
}

// MARK: - MainFooterView

final class MainFooterView: UICollectionReusableView {
    
    // MARK: - Properties
    
    private lazy var deleteAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Очистить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapDeleteAllButton), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: FooterDelegate?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        addSubview(deleteAllButton)
        deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deleteAllButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteAllButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            deleteAllButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            deleteAllButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapDeleteAllButton() {
        superview?.endEditing(true)
        delegate?.didTapDeleteAllButton()
    }
}
