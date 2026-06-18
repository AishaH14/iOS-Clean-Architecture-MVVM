//
//  LoginViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 28/12/1447 AH.
//

import UIKit

final class LoginViewController: UIViewController, StoryboardInstantiable {

   
    @IBOutlet private weak var signInButtonView: AuthButtonView?
    @IBOutlet private weak var continueAsGuestButtonView: AuthButtonView?
    @IBOutlet private weak var cardView: UIView?

    
    private var viewModel: LoginViewModel!

   
    static func create(with viewModel: LoginViewModel) -> LoginViewController {
        let vc = LoginViewController.instantiateViewController()
        vc.viewModel = viewModel
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    private func bindViewModel() {
        viewModel.loading.observe(on: self) { [weak self] isLoading in
            self?.signInButtonView?.isUserInteractionEnabled = !isLoading
            self?.continueAsGuestButtonView?.isUserInteractionEnabled = !isLoading
        }
        
        viewModel.error.observe(on: self) { [weak self] message in
            guard !message.isEmpty else { return }
            self?.showError(message: message)
        }
    }
    private func setupView() {
        cardView?.layer.cornerRadius = 16
        cardView?.clipsToBounds = true

        signInButtonView?.configure(title: "Sign In with TMDB", style: .filled)
        signInButtonView?.addTarget(self, action: #selector(signInTapped))

        continueAsGuestButtonView?.configure(title: "Continue as Guest", style: .outlined)
        continueAsGuestButtonView?.addTarget(self, action: #selector(continueAsGuestTapped))
    }

    @objc private func signInTapped() {
        viewModel.didTapSignIn()
    }

    @objc private func continueAsGuestTapped() {
        viewModel.didTapContinueAsGuest()
    }
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
