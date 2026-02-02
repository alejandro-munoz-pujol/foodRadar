//
//  YelpData.swift
//  foodRadar
//
//  Created by Pol on 8/11/25.
//
import Foundation

struct YelpSearchResponse: Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let name: String
    let coordinates: BusinessCoordinates
    let categories: [BusinessCategory]
    let rating: Double?
    let review_count: Int?
    let price: String?
    let location: BusinessLocation?
    let display_phone: String?
    let image_url: String?
    let is_closed: Bool?
}

struct BusinessLocation: Codable {
    let display_address: [String]?
}

struct BusinessCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct BusinessCategory: Codable {
    let title: String
    let alias: String
}
