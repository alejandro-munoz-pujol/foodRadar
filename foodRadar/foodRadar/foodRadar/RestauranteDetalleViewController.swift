//
//  RestauranteDetalleViewController.swift
//  foodRadar
//
//  Created by Pol on 8/11/25.
//

import UIKit

class RestauranteDetalleViewController: UIViewController {

    var negocio: Business?
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantCategory: UILabel!
    @IBOutlet weak var restaurantPhone: UILabel!
    @IBOutlet weak var restaurantPrice: UILabel!
    @IBOutlet weak var restaurantRating: UILabel!
    @IBOutlet weak var restaurantEstate: UILabel!
    @IBOutlet weak var restaurantImage: UIImageView!
    
    var restaurant: Business?
    
    private let accentColor = UIColor(red: 128/255, green: 0/255, blue: 32/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configUI()
        
        guard let restaurant = negocio else { return }
        
        restaurantName.text = restaurant.name
        
        if let alias = restaurant.categories.first?.alias, let nombre = FiltrosManager.obtenerNombre(para: alias){
            restaurantCategory.text = nombre
        } else {
            restaurantCategory.text = restaurant.categories.first?.title ?? "Restaurant"
        }
        
        restaurantPrice.text = restaurant.price ?? "N/A"
        
        if let rating = restaurant.rating, let reviews = restaurant.review_count {
            restaurantRating.text = "\(rating) ⭐ (\(reviews) reviews)"
        } else {
            restaurantRating.text = "No ratings"
        }
        
        restaurantPhone.text = restaurant.display_phone ?? "Phone not available"
        
        
        if let estaCerrado = restaurant.is_closed {
            restaurantEstate.text = estaCerrado ? "Closed" : "Open"
            restaurantEstate.backgroundColor = estaCerrado ? .red : .systemGreen
        } else {
            restaurantEstate.text = "Unknown state"
        }
        
        
        if let urlString = restaurant.image_url {
            cargarImagen(from: urlString)
        }
    }
    
    
    @IBAction func volverPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func cargarImagen(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self.restaurantImage.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func setupLayout() {

        view.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor (red: 0.7, green: 0.35, blue: 0.35, alpha: 1)
            : UIColor (red: 0.72, green: 0.4, blue: 0.45, alpha: 1)
        }

        restaurantImage.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            restaurantImage.topAnchor.constraint(equalTo: view.topAnchor),
            restaurantImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            restaurantImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            restaurantImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),

        
        ])
    }
    private let goldAccent = UIColor(red: 0.88, green: 0.70, blue: 0.38, alpha: 1)
    private let softWhite = UIColor.white.withAlphaComponent(0.9)
    
    private func configUI() {
        restaurantImage.contentMode = .scaleAspectFill
        restaurantImage.clipsToBounds = true
        restaurantImage.layer.cornerRadius = 0

        restaurantName.font = .preferredFont(forTextStyle: .title1)
        restaurantName.adjustsFontForContentSizeCategory = true
        restaurantName.textColor = .label
        restaurantName.numberOfLines = 0

        restaurantCategory.font = .preferredFont(forTextStyle: .subheadline)
        restaurantCategory.adjustsFontForContentSizeCategory = true
        restaurantCategory.textColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.lightText : UIColor.darkGray
        }

        let infoLabels = [restaurantPhone, restaurantPrice, restaurantRating]
        infoLabels.forEach {
            $0?.font = .preferredFont(forTextStyle: .body)
            $0?.adjustsFontForContentSizeCategory = true
            $0?.textColor = UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.lightText
            }
            $0?.numberOfLines = 0
        }

        restaurantEstate.font = .preferredFont(forTextStyle: .footnote)
        restaurantEstate.adjustsFontForContentSizeCategory = true
        restaurantEstate.textAlignment = .center
        restaurantEstate.layer.cornerRadius = 10
        restaurantEstate.clipsToBounds = true
        restaurantEstate.textColor = .white
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
