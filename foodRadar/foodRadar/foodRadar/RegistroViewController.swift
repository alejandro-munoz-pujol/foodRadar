//
//  RegistroViewController.swift
//  foodRadar
//
//  Created by Pol on 7/11/25.
//

import UIKit
import FirebaseAuth

class RegistroViewController: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var logoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    
    @IBAction func registrarsePressed(_sender: UIButton) {
            
            do {
                try mailTextField.validarComoEmail()
                try passwordTextField.validarComoContrasena(longitudMinima: 8)
                try confirmPasswordTextField.validarCoincidencia(con: passwordTextField)
                
                let email = mailTextField.text!
                let password = passwordTextField.text!

                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    
                    DispatchQueue.main.async {
                        if let error = error {
                            self.mostrarAlerta(titulo: "Register error", mensaje: error.localizedDescription)
                        } else {
                            let emailUsuario = authResult?.user.email ?? email
                            
                            let alertController = UIAlertController(title: "Successful registration!", message: "¡User \(emailUsuario) created!", preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                
            } catch {
                if let errorValidacion = error as? LoginError {
                    mostrarAlerta(titulo: "Validation error", mensaje: errorValidacion.localizedDescription)
                } else {
                    mostrarAlerta(titulo: "Error", mensaje: "An unexpected error occurred.")
                }
            }
        }
        
        @IBAction func volverPressed(_sender: UIButton) {
            self.dismiss(animated: true, completion: nil)
        }
        
        func mostrarAlerta(titulo: String, mensaje: String) {
            let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    
        func configUI() {
            logoImageView.layer.cornerRadius = logoImageView.frame.height / 2
            logoImageView.clipsToBounds = true
            logoImageView.layer.borderWidth = 2
            logoImageView.layer.borderColor = UIColor.white.cgColor

            configurarTextField(mailTextField, icon: "envelope")
            configurarTextField(passwordTextField, icon: "lock")
            configurarTextField(confirmPasswordTextField, icon: "lock")
                    
            mailTextField.keyboardType = .emailAddress
            mailTextField.autocapitalizationType = .none
            passwordTextField.isSecureTextEntry = true
            confirmPasswordTextField.isSecureTextEntry = true
            
        }
    
        func configurarTextField(_ textField: UITextField, icon: String) {
                textField.layer.cornerRadius = 12
                textField.layer.borderWidth = 1
                textField.layer.borderColor = UIColor.systemGray4.cgColor
                textField.backgroundColor = .systemBackground
                
                let iconView = UIImageView(image: UIImage(systemName: icon))
                iconView.tintColor = .systemGray
                iconView.contentMode = .scaleAspectFit
                
                let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                iconView.frame = CGRect(x: 12, y: 12, width: 20, height: 20)
                container.addSubview(iconView)
                
                textField.leftView = container
                textField.leftViewMode = .always
                    
            }

}
