//
//  CreateListViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 15/01/1448 AH.
//

import UIKit

final class CreateListViewController: UIViewController {
    // MARK: - Create
    static func create(
        with viewModel: CreateListViewModel
    ) -> CreateListViewController {
        let viewController = CreateListViewController(
            nibName: String(describing: CreateListViewController.self),
            bundle: nil
        )

        viewController.viewModel = viewModel
        return viewController
    }
    // MARK: - IBOutlet
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var createButton: UIButton!
    
    var viewModel: CreateListViewModel!
    
    // MARK: - Properties
    private let nameLimit = 50
    private let descriptionLimit = 200
    private let descriptionPlaceholder = NSLocalizedString("Enter list description", comment: "")
    private let nameCountLabel = UILabel()
    private let descriptionCountLabel = UILabel()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    @IBAction private func didTapCreateButton(_ sender: UIButton) {
        viewModel.didTapCreateList(
            name: nameTextField.text ?? "",
            description: currentDescriptionText()
        )
    }
}
// MARK: - Private
private extension CreateListViewController {
    
    func setupViews() {
        title = NSLocalizedString("Create List", comment: "")
        view.backgroundColor = .white
        
        setupNameTextField()
        setupDescriptionTextView()
        setupCreateButton()
        setupCounters()
    }
    
    func setupNameTextField() {
        nameTextField.delegate = self
        nameTextField.placeholder = NSLocalizedString("Enter list name", comment: "")
        
        nameTextField.layer.cornerRadius = 10
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        nameTextField.clipsToBounds = true
    }

    func setupDescriptionTextView() {
        descriptionTextView.delegate = self
        descriptionTextView.text = descriptionPlaceholder
        descriptionTextView.textColor = .lightGray
        
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        descriptionTextView.clipsToBounds = true
    }
    
    func setupCreateButton() {
        createButton.layer.cornerRadius = 8
        createButton.clipsToBounds = true
    }
    
    func setupCounters() {
        nameCountLabel.text = "0/\(nameLimit)"
        nameCountLabel.textColor = .lightGray
        nameCountLabel.font = UIFont.systemFont(ofSize: 14)
        nameCountLabel.textAlignment = .right
        nameCountLabel.frame = CGRect(x: 10, y: 0, width: 55, height: 22)
        
        nameTextField.rightView = nameCountLabel
        nameTextField.rightViewMode = .always
        
        descriptionCountLabel.text = "0/\(descriptionLimit)"
        descriptionCountLabel.textColor = .lightGray
        descriptionCountLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionCountLabel.textAlignment = .right
        descriptionCountLabel.frame = CGRect(
            x: descriptionTextView.frame.width - 55,
            y: descriptionTextView.frame.height - 30,
            width: 60,
            height: 22
        )
        
        descriptionTextView.addSubview(descriptionCountLabel)
    }
    
    func currentDescriptionText() -> String {
        if descriptionTextView.text == descriptionPlaceholder {
            return ""
        }
        return descriptionTextView.text
    }
}
// MARK: - UITextFieldDelegate
extension CreateListViewController: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField == nameTextField else { return true }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(
            in: stringRange,
            with: string
        )
        
        let isValid = updatedText.count <= nameLimit
        
        if isValid {
            nameCountLabel.text = "\(updatedText.count)/\(nameLimit)"
        }
        
        return isValid
    }
}
// MARK: - UITextViewDelegate
extension CreateListViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == descriptionTextView else { return }
        
        if textView.text == descriptionPlaceholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == descriptionTextView else { return }
        
        if textView.text.isEmpty {
            textView.text = descriptionPlaceholder
            textView.textColor = .lightGray
            descriptionCountLabel.text = "0/\(descriptionLimit)"
        }
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard textView == descriptionTextView else { return true }
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(
            in: stringRange,
            with: text
        )
        
        return updatedText.count <= descriptionLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == descriptionTextView else { return }
        
        descriptionCountLabel.text = "\(textView.text.count)/\(descriptionLimit)"
    }
}
