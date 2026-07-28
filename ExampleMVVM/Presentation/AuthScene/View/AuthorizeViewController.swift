//
//  AuthorizeViewController.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import UIKit
import SafariServices
final class AuthorizeViewController: UIViewController,StoryboardInstantiable {
    @IBOutlet private weak var openTMDBButton: AuthButtonView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var cardView: UIView!


        private var viewModel: AuthorizeViewModel!

    static func create(with viewModel: AuthorizeViewModel) -> AuthorizeViewController {
          let vc = AuthorizeViewController.instantiateViewController()
          vc.viewModel = viewModel
          return vc
      }
      
      override func viewDidLoad() {
          super.viewDidLoad()
          setupView()
          bindViewModel()
          observeReturnFromTMDB()
      }
      
      deinit {
          NotificationCenter.default.removeObserver(self)
      }
      
      private func setupView() {
          title = "Authentication"
          
          cardView.layer.cornerRadius = 16
          cardView.clipsToBounds = true
          
          openTMDBButton.configure(title: "Open TMDB", style: .filled)
          openTMDBButton.addTarget(self, action: #selector(openTMDBTapped))
          activityIndicator.hidesWhenStopped = true
          activityIndicator.stopAnimating()
      }
      
      private func bindViewModel() {
          viewModel.openURL.observe(on: self) { [weak self] url in
              guard let url = url else { return }
              
              let safariViewController = SFSafariViewController(url: url)
              safariViewController.dismissButtonStyle = .close
              safariViewController.delegate = self
              self?.present(safariViewController, animated: true)
          }
          
          viewModel.error.observe(on: self) { [weak self] message in
              guard !message.isEmpty else { return }
              self?.activityIndicator.stopAnimating()
              self?.openTMDBButton.isUserInteractionEnabled = true
              self?.showError(message: message)
          }
      }
      
      private func observeReturnFromTMDB() {
          NotificationCenter.default.addObserver(
              self,
              selector: #selector(didReturnFromTMDB),
              name: .didReturnFromTMDB,
              object: nil
          )
      }
      
      @objc private func openTMDBTapped() {
          activityIndicator.startAnimating()
          openTMDBButton.isUserInteractionEnabled = false
          viewModel.didTapOpenTMDB()
      }
      
    @objc private func didReturnFromTMDB(_ notification: Notification) {
        guard let token = notification.userInfo?[AuthConstants.requestToken] as? String else {
            return
        }
        dismiss(animated: true) { [weak self] in
            self?.viewModel.didReturnFromTMDB(requestToken: token)
        }
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
extension AuthorizeViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
        activityIndicator.stopAnimating()
        openTMDBButton.isUserInteractionEnabled = true
        
    }
}
