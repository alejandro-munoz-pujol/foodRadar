//
//  ViewController.swift
//  Demo
//
//  Created by Alejandro Muñoz Pujol and Pol Cuadriello Bravo on 23/9/25.
//

import UIKit
import FirebaseAuth

enum LoginError: Error {
    case camposVacios
    case formatoEmailInvalido
    case contrasenaCorta(longitudMinima: Int)
    case contrasenasNoCoinciden
    
    var localizedDescription: String {
        switch self {
        case .camposVacios:
            return "The email and password fields can't be empty."
        case .formatoEmailInvalido:
            return "Please, introduce a valid address."
        case .contrasenaCorta(let minLength):
            return "The password must have at least \(minLength) caracters."
        case .contrasenasNoCoinciden:
                    return "The passwords don't match."
        }
    }
}

extension UITextField {
    
    func validarComoEmail() throws {
        guard let texto = self.text, !texto.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw LoginError.camposVacios
        }
        guard let email = self.text, email.contains("@") && email.contains(".") else {
            throw LoginError.formatoEmailInvalido
        }
    }

    func validarComoContrasena(longitudMinima: Int) throws {
        guard let texto = self.text, !texto.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw LoginError.camposVacios
        }
        guard let contrasena = self.text, contrasena.count >= longitudMinima else {
            throw LoginError.contrasenaCorta(longitudMinima: longitudMinima)
        }
    }
    func validarCoincidencia(con otroTextField: UITextField) throws {
        guard let texto = self.text, !texto.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw LoginError.camposVacios
        }
        
        guard let textoContrasena = otroTextField.text, texto == textoContrasena else {
            throw LoginError.contrasenasNoCoinciden
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var mailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mailText.text = "alex@gmail.com"
        passwordText.text = "12345678"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
 

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExitLogin" {
            if let destination = segue.destination as? HomeController{
                destination.mail = self.mailText.text
            }
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        do {
            try mailText.validarComoEmail()
            try passwordText.validarComoContrasena(longitudMinima: 8)
            realizarLogin { [weak self] resultado in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch resultado {
                    case .success(let mensajeExito):
                        self.performSegue(withIdentifier: "ExitLogin", sender: nil)
                        self.mostrarAlerta(titulo: "Successful Login", mensaje: mensajeExito)
                    case .failure(let error):
                        let mensajeError = error.localizedDescription
                        self.mostrarAlerta(titulo: "Login error", mensaje: mensajeError)
                    }
                        
                }
            }
        } catch{
            if let errorValidacion = error as? LoginError {
                mostrarAlerta(titulo: "Validation error", mensaje: errorValidacion.localizedDescription)
            } else {

                mostrarAlerta(titulo: "Error", mensaje: "An unexpected error occurred.")
            }
        }
    }
    
    func realizarLogin(completion: @escaping (Result<String, Error>) -> Void) {
        guard let email = mailText.text,
              let password = passwordText.text else {
            completion(.failure(LoginError.camposVacios))
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            if let authResult = authResult {
                let mensajeExito = "Logged in as \(authResult.user.email ?? email)!"
                completion(.success(mensajeExito))
            }
        }
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

        configurarTextField(mailText, icon: "envelope")
        configurarTextField(passwordText, icon: "lock")
                
        mailText.keyboardType = .emailAddress
        mailText.autocapitalizationType = .none
        passwordText.isSecureTextEntry = true
        
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

