//
//  InfoUserViewController.swift
//  foodRadar
//
//  Created by Pol on 10/11/25.
//

import UIKit
import FirebaseAuth

class InfoUserViewController: UIViewController {

    @IBOutlet weak var mailTextLabel: UILabel!
    
    @IBOutlet weak var mailDetailLabel: UILabel!
    @IBOutlet weak var containerUI: UIView!
    var mail: String?
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupBackgroundGradient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let email = mail,
           let name = email.split(separator: "@").first {
            mailTextLabel.text = "Hello, \(name.capitalized)"
            mailDetailLabel.text = email
        } else {
            mailTextLabel.text = "Hello user"
        }
    }

    
    @IBAction func cerrarSessionPressed(_ sender: Any) {
            do {
                try Auth.auth().signOut()

                let loginPresenter = self.presentingViewController?.presentingViewController

                self.dismiss(animated: true) {
                    loginPresenter?.dismiss(animated: true, completion: nil)
                }

            } catch let signOutError as NSError {
                print("Error at logging out: %@", signOutError)
            }
        }

        @IBAction func volverAlMapaPressed(_ sender: UIButton) {
            self.dismiss(animated: true, completion: nil)
        }
    
    
    func configUI() {
        view.backgroundColor = .systemGroupedBackground

        containerUI.backgroundColor = .secondarySystemGroupedBackground
        containerUI.layer.cornerRadius = 20
        containerUI.layer.masksToBounds = true

        mailTextLabel.font = .preferredFont(forTextStyle: .largeTitle)
        mailTextLabel.adjustsFontForContentSizeCategory = true
        mailTextLabel.textColor = .label
        mailTextLabel.textAlignment = .center
    }
    
    private func setupBackgroundGradient() {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, at: 0)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        gradientLayer.colors = [
            UIColor(red: 0.90, green: 0.65, blue: 0.68, alpha: 0.35).cgColor,
            UIColor(red: 0.98, green: 0.94, blue: 0.95, alpha: 0.10).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.3, 0.7]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = view.bounds

        backgroundView.layer.addSublayer(gradientLayer)
    }
    

}
