//
//  WeatherDetailModel.swift
//  iosProject-5
//
//  Created by 조다은 on 4/12/24.
//

import Foundation

struct WeatherDetailRoot: Codable {
    let cod: String
    let cnt: Int
    let list: [WeatherDetailModel]
}

struct WeatherDetailModel: Codable {
    let dt: TimeInterval
    let main: WeatherDetailMain
    let weather: [WeatherDetail]
//    let clouds: CloudsModel
//    let wind: WindModel
    let visibility: Int
//    let pop: Double
//    let sys: SysModel
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, visibility
        case dtTxt = "dt_txt"
    }
}

struct WeatherDetailMain: Codable {
    let temp: Double
    let tempFeel: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let seaLevel: Int
    let grndLevel: Int
    let humidity: Int
    let tempKf: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case tempFeel = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}

struct WeatherDetail: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

//struct CloudsModel: Codable {
//    let all: Int
//}
//
//struct WindModel: Codable {
//    let speed: Double
//    let deg: Int
//    let gust: Double
//}
//
//struct SysModel: Codable {
//    let pod: String
//}
