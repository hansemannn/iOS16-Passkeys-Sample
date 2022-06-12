//
//  ViewController.swift
//  Passkeys-Sample
//
//  Created by Hans Knöchel on 12.06.22.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {
  @IBAction func onButtonTapped(_ sender: UIButton) {
    performPasswordLessSignIn()
  }
  
  private func performPasswordLessSignIn() {
    let bytes = [UInt32](repeating: 0, count: 32).map { _ in arc4random() }

    let challenge = Data(bytes: bytes, count: 32)
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "lambus.com")
    let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
    let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])

    authController.delegate = self
    authController.presentationContextProvider = self
    authController.performRequests()
  }
  
  private func showAlert(with title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: false)
  }
}

// MARK: ASAuthorizationControllerDelegate

extension ViewController : ASAuthorizationControllerDelegate {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
      showAlert(with: "Authorized with Passkeys", message: "Create account with credential ID = \(credential.credentialID)")
      // Take steps to handle the registration.
    } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
      showAlert(with: "Authorized with Passkeys", message: "Sign in with credential ID = \(credential.credentialID)")
      let signature = credential.signature
      let clientDataJSON = credential.rawClientDataJSON
      
      // Take steps to verify the challenge by sending it to your server tio verify
    } else {
      showAlert(with: "Authorized", message: "e.g. with \"Sign in with Apple\"")
      // Handle other authentication cases, such as Sign in with Apple.
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    showAlert(with: "Error", message: error.localizedDescription)
  }
}
