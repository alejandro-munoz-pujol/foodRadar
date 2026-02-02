//
//  GooglePlacesResponse.swift
//  foodRadar
//
//  Created by Pol on 8/11/25.
//

import Foundation

struct GooglePlacesResponse: Codable {
    let results: [Place]
}

struct Place: Codable {
    let name: String
    let geometry: Geometry
    let types: [String]
}

struct Geometry: Codable {
    let location: PlaceLocation
}

struct PlaceLocation: Codable {
    let lat: Double
    let lng: Double
}
