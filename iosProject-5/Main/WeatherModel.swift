//
//  weatherModel.swift
//  iosProject-5
//
//  Created by 한범석 on 4/8/24.
//

import Foundation


struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let tempFeel: Double
    let tempMin: Double
    let tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case tempFeel = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case temp
    }
}

struct Sys: Codable {
    let sunrise: Double
}

struct Root: Codable {
    let weather: [Weather]
    let main: Main
    let sys: Sys
    let dt: Double
    let name: String
}
