//
//  HomeController.swift
//  foodRadar
//
//  Created by Pol Cuadriello Bravo on 24/10/25.
//

import UIKit
import MapKit
import CoreLocation

class HomeController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var mail: String?
    
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var filtroButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var negociosActuales: [Business] = []
    
    let gradientLayer = CAGradientLayer()
        
    let categoriasFiltro = FiltrosManager.categorias
        
    private var lastSearchLocation: CLLocation?
    private var didInitialSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        setupFiltroMenu()
        mapView.delegate = self
        configUI()
        setupMapBackground()
    }
    
    func configUI() {

            mapView.showsUserLocation = true
            mapView.pointOfInterestFilter = .excludingAll

            filtroButton.layer.cornerRadius = 22
            filtroButton.backgroundColor = UIColor (red: 0.72, green: 0.4, blue: 0.45, alpha: 1)
            filtroButton.setTitleColor(.white, for: .normal)
            filtroButton.titleLabel?.font = .boldSystemFont(ofSize: 16)

            filtroButton.layer.shadowColor = UIColor.black.cgColor
            filtroButton.layer.shadowOpacity = 0.25
            filtroButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            filtroButton.layer.shadowRadius = 6

            mailLabel.font = .systemFont(ofSize: 16, weight: .medium)
            mailLabel.textColor = .label
            mailLabel.clipsToBounds = true
            mailLabel.textAlignment = .center

            filtroButton.transform = CGAffineTransform(translationX: 0, y: 20)
            filtroButton.alpha = 0

            UIView.animate(withDuration: 0.6, delay: 0.2) {
                self.filtroButton.alpha = 1
                self.filtroButton.transform = .identity
            }
        }
    private func setupMapBackground() {

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    func setupFiltroMenu() {
        
        let accionesMenu = categoriasFiltro.map { (categoria) -> UIAction in
            
            return UIAction(title: categoria.nombre) { [weak self] (action) in

                self?.filtroButton.setTitle(categoria.nombre, for: .normal)
                
                if let userLocation = self?.locationManager.location?.coordinate {
                    self?.buscarEnYelp(at: userLocation, termino: categoria.alias)
                }
            }
        }
        
        filtroButton.menu = UIMenu(title: "Choose a category", children: accionesMenu)
        filtroButton.showsMenuAsPrimaryAction = true
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
            
        manager.stopUpdatingLocation()
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters:1000,longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // 1. Obtenemos la nueva ubicación del centro del mapa
        let newCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        let distance: CLLocationDistance
        
        if let lastLocation = lastSearchLocation {
            distance = newCenter.distance(from: lastLocation)
        } else {
            distance = 0
        }
        
        if !didInitialSearch || distance > 500 {

            self.didInitialSearch = true
            self.lastSearchLocation = newCenter

            let aliasActual = FiltrosManager.categorias.first { $0.nombre == filtroButton.title(for: .normal) }?.alias ?? "restaurants"

            buscarEnYelp(at: newCenter.coordinate, termino: aliasActual)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ubication error: \(error.localizedDescription)")
    }
    
    func symbolName(for categories: [String]) -> String {
        if categories.contains(where: { $0.contains("bar") || $0.contains("pub") }) {
            return "wineglass.fill"
        }
        if categories.contains(where: { $0.contains("coffee") || $0.contains("cafe") }) {
            return "cup.and.saucer.fill"
        }
        if categories.contains(where: { $0.contains("mexican") || $0.contains("taco") }) {
            return "flame.circle.fill"
        }
        if categories.contains(where: { $0.contains("japanese") || $0.contains("sushi") || $0.contains("ramen") }) {
            return "fish.circle.fill"
        }
        if categories.contains(where: { $0.contains("burger") || $0.contains("hotdog") || $0.contains("american") }) {
            return "takeoutbag.and.cup.and.straw.fill"
        }
        if categories.contains(where: { $0.contains("italian") || $0.contains("pizza") }) {
            return "fork.knife.circle.fill"
        }
        return "fork.knife.circle.fill"
    }
    
    class FoodAnnotation: MKPointAnnotation {
            var categoryAliases: [String] = []
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "FoodPin"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        annotationView.annotation = annotation
        annotationView.canShowCallout = true

        guard let foodAnnotation = annotation as? FoodAnnotation else {
            return annotationView
        }

        let symbol = symbolName(for: foodAnnotation.categoryAliases)

        annotationView.image = UIImage(systemName: symbol)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        annotationView.frame.size = CGSize(width: 32, height: 32)

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let annotation = view.annotation else { return }

        let negocioSeleccionado = self.negociosActuales.first {
            $0.name == annotation.title && $0.coordinates.latitude == annotation.coordinate.latitude
        }

        guard let negocio = negocioSeleccionado else { return }

        performSegue(withIdentifier: "mostrarDetalleRestaurante", sender: negocio)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let email = mail {
            let name = email.components(separatedBy: "@").first ?? email
            self.mailLabel.text = "Welcome \(name)!"
        } else {
            self.mailLabel.text = "Welcome!"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "mostrarDetalleRestaurante" {
            if let negocioEnviado = sender as? Business,
               let destinoVC = segue.destination as? RestauranteDetalleViewController {
                destinoVC.negocio = negocioEnviado
            }
        }

        if segue.identifier == "mostrarInfoUsuario" {
            if let destinoVC = segue.destination as? InfoUserViewController {
                destinoVC.mail = self.mail
            }
        }
    }

}

extension HomeController {
    

    func buscarEnYelp(at coordinate: CLLocationCoordinate2D, termino: String = "restaurants") {

        let apiKey = "Qdclh1p9Vd0JmIHdIv6EcVRcagqLzpRKzm4NUtAND6qPedDVQreLqv31LtsA2pvmQZT5diBVMzWmEC3blMrszXelHs8ET_jX31wgD4SOVaTmlJxZ7zqa8s8fb-hfaXYx"

        var urlComponents = URLComponents(string: "https://api.yelp.com/v3/businesses/search")!

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "longitude", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "term", value: termino),
            URLQueryItem(name: "radius", value: "2000"),
            URLQueryItem(name: "limit", value: "20")
        ]

        guard let url = urlComponents.url else { return }

        var request = URLRequest(url: url)

        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            guard let data = data, error == nil else {
                print("Error on calling the Yelp API: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let yelpResponse = try JSONDecoder().decode(YelpSearchResponse.self, from: data)

                DispatchQueue.main.async {
                    self?.actualizarMapa(con: yelpResponse.businesses)
                }
            } catch {
                print("Error decoding Yelp JSON: \(error)")
            }

        }.resume()
    }
    
    func actualizarMapa(con businesses: [Business]) {
        self.negociosActuales = businesses
        mapView.removeAnnotations(mapView.annotations)

        for business in businesses {
            let annotation = FoodAnnotation()
            annotation.title = business.name

            annotation.subtitle = business.categories.first?.title
            annotation.categoryAliases = business.categories.map {$0.alias.lowercased()}
            let location = CLLocationCoordinate2D(latitude: business.coordinates.latitude, longitude: business.coordinates.longitude)
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        }
    }
    
}


