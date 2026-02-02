//
//  FiltrosManager.swift
//  foodRadar
//
//  Created by Pol on 15/11/25.
//

import Foundation

struct FiltrosManager {
    
    static let categorias: [(nombre: String, alias: String)] = [
        ("Restaurants (All)", "restaurants"),
        ("Cafe", "cafe"),
        ("Pizza", "pizza"),
        ("Mexican", "mexican"),
        ("Sushi", "sushi"),
        ("Chinese", "chinese"),
        ("Italian", "italian"),
        ("Bars", "bars"),
        ("Fast food", "hotdogs")
    ]
    
    static func obtenerNombre(para alias: String) -> String? {
        return categorias.first { $0.alias == alias }?.nombre
    }
}
