//
//  DetailViewController.swift
//  iosProject-5
//
//  Created by 한범석 on 4/9/24.
//

import UIKit
import Alamofire
import Kingfisher

class DetailViewController: UIViewController {
    

    @IBOutlet weak var hourView: UIView!
    @IBOutlet weak var hourHeaderView: UILabel!
    @IBOutlet weak var hourCollectionView: UICollectionView!
    @IBOutlet weak var dayTableView: UITableView!
    
    var appId = "3417b713d03a02adc31f056700235bb2"
    var lat: Double?
    var lon: Double?
    var weatherDetails: [WeatherDetailModel] = []
    var location: (latitude: Double, longitude: Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerXib()
        hourCollectionView.dataSource = self
        hourCollectionView.delegate = self
        dayTableView.dataSource = self
        dayTableView.delegate = self
        
        hourView.layer.cornerRadius = 15
        hourCollectionView.layer.cornerRadius = 15
        dayTableView.layer.cornerRadius = 15
        dayTableView.sectionHeaderTopPadding = 10
        
        hourHeaderView.text = "🕙 시간별 예보"
        
        lat = 37.7749
        lon = -122.4194
         
        if let latitude = lat, let longitude = lon {
            search(lat: latitude, lon: longitude)
        }
    }
    
    // MARK: Xib 등록
    
    private func registerXib() {
        let nibHour = UINib(nibName: "HourCollectionViewCell", bundle: nil)
        let nibDay = UINib(nibName: "DayTableViewCell", bundle: nil)
        
        hourCollectionView.register(nibHour, forCellWithReuseIdentifier: "hourCell")
        dayTableView.register(nibDay, forCellReuseIdentifier: "dayCell")
    }
    
    @IBAction func actBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: Date 객체를 받아서 요일 값을 반환하는 메서드
    
    static func getDayOfWeek(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        let dateStr = formatter.string(from: date)
        return dateStr
    }
    
    // MARK: - 날씨 정보 불러오기 search 메서드
    
    func search(lat: Double, lon: Double) {
        let endPoint = "https://api.openweathermap.org/data/2.5/forecast"
        let params: Parameters = ["lat": lat, "lon": lon, "lang": "kr", "units": "metric", "appid": appId]
        
        AF.request(endPoint, method: .get, parameters: params).responseDecodable(of: WeatherDetailRoot.self) { response in
            switch response.result {
            case .success(let root):
                self.weatherDetails = root.list
                DispatchQueue.main.async {
                    self.hourCollectionView.reloadData()
                    self.dayTableView.reloadData()
                }
                print(self.weatherDetails)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: Collection view Data source
extension DetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(weatherDetails.count, 13)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourCell", for: indexPath) as! HourCollectionViewCell
        
        let weatherDetail = weatherDetails[indexPath.item]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"

        let hourString = dateFormatter.string(from: Date(timeIntervalSince1970: weatherDetail.dt))
        cell.lblHour.text = indexPath.row == 0 ? "지금" : hourString
        cell.lblTemp.text = "\(Int(weatherDetail.main.temp))º"
        
//        if let icon = weatherDetail.weather.first?.icon {
//            cell.imgWeather.image = UIImage(named: icon)
//        }
        
        if let icon = weatherDetail.weather.first?.icon {
            let iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            cell.imgWeather.kf.setImage(with: URL(string: iconURL))
        }
        
        return cell
    }
}

// MARK: Collection view Delegate
extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/6 + 3
        
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
}

// MARK: Table view Delegate, Data Source
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(weatherDetails.count / 8, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! DayTableViewCell
        
        let startIndex = indexPath.row * 8
        let endInedx = min(startIndex + 8, weatherDetails.count)
        let dayWeatherDetails = Array(weatherDetails[startIndex..<endInedx])
        
        let date = Date(timeIntervalSince1970: dayWeatherDetails[0].dt)
        let dayOfWeek = DetailViewController.getDayOfWeek(date: date)
        
        cell.lblDate.text = indexPath.row == 0 ? "오늘" : dayOfWeek
        
        var minTemp = Double.greatestFiniteMagnitude
        var maxTemp = -Double.greatestFiniteMagnitude
        
        for weatherDetail in dayWeatherDetails {
            minTemp = min(minTemp, weatherDetail.main.tempMin)
            maxTemp = max(maxTemp, weatherDetail.main.tempMax)
        }
        
        let roundedMinTemp = Int(round(minTemp))
        let roundedMaxTemp = Int(round(maxTemp))
        
        cell.lblMinTemp.text = "\(roundedMinTemp)º"
        cell.lblMaxTemp.text = "\(roundedMaxTemp)º"
        
//        if let icon = dayWeatherDetails.first?.weather.first?.icon {
//            cell.imgWeather.image = UIImage(named: icon)
//        }
        
        if let icon = dayWeatherDetails.first?.weather.first?.icon {
            let iconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            cell.imgWeather.kf.setImage(with: URL(string: iconURL))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "🗓️ 5일 예보 \n"
    }
}
