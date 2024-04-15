//
//  WeatherViewController.swift
//  iosProject-5
//
//  Created by 한범석 on 4/7/24.
//

import UIKit
import MapKit
import Alamofire
import Kingfisher
import CoreLocation

class WeatherViewController: UIViewController {


    
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
//    var location: (latitude: Double, longitude: Double)?
    
    @IBOutlet weak var testSymbol: UILabel!
    
    @IBOutlet weak var todaysDate: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var weatherDetail: UILabel!
    @IBOutlet weak var weatherUpdateTime: UILabel!
    @IBOutlet weak var weatherIllust: UIImageView!
    
    let appId = "9e237b4900f0bd4d5f48ee8ad2b4dd09"
    let locationManager = CLLocationManager()
    var location: (latitude: Double, longitude: Double)?
    
    var currentTemperature: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // MARK: - 오늘의 날짜를 보여주는 dateFormatter
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어로 설정
        dateFormatter.dateFormat = "M월 d일(E)" // 원하는 날짜 형식 설정
        let formattedDate = dateFormatter.string(from: now)
        
        //
        
        todaysDate.text = formattedDate
        
        
    }
    
    
    // MARK: - actUpdate 액션 버튼: 날씨 정보를 최신으로 업데이트하고 search 메서드 호출로 시간도 최신으로 표시됨
    
    
    
    @IBAction func actUpdate(_ sender: Any) {
        
        if let location = self.location {
            search(lat: location.latitude, lon: location.longitude, city: nil)
        }
        
    }
    
    
    
    
    
    
    @IBAction func actDetailWeather(_ sender: Any) {
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // DetailViewController에 전달할 데이터 설정 (옵션)
            
            detailVC.location = location
            
            // 모달 프레젠테이션 스타일 설정
            detailVC.modalPresentationStyle = .fullScreen // 또는 .overFullScreen 등 원하는 스타일 선택
            detailVC.modalTransitionStyle = .coverVertical // 아래에서 위로 올라오는 스타일
            
            detailVC.isModalInPresentation = false
            // 모달을 스와이프로 닫을 수 있게 함
            
            // DetailViewController 표시
            self.present(detailVC, animated: true, completion: nil)
            
            
            
        }

        
    }
    
    
    
    // MARK: - search 메서드: 위치 좌표를 입력받고 MapKit의 기능을 이용해 역 지오코딩으로 한글 지역명을 받아오고, API가 정의된 fetchWeatherInfo() 메서드를 호출하여 날씨 정보까지 받아오는 통합 메서드
    
    func search(lat: Double?, lon: Double?, city: String?) {
        guard let latitude = lat, let longitude = lon else { return }
        
        // 역 지오코딩으로 한글 지역 이름을 먼저 얻습니다.
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("역 지오코딩 에러: \(error)")
                return
            }
            
            var locationName = city
            
            if let placemark = placemarks?.first {
                let locality = placemark.locality ?? "" // 도시
                let subLocality = placemark.subLocality ?? "" // 구
                let thoroughfare = placemark.thoroughfare ?? "" // 동
                let subThoroughfare = placemark.subThoroughfare ?? "" // 번지
                
                locationName = [locality, subLocality].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
            }
                    
                    
            
           
            // 역 지오코딩 결과를 바탕으로 날씨 정보 API를 호출합니다.
            
            strongSelf.fetchWeatherInfo(lat: latitude, lon: longitude, cityName: locationName)
            
            // 날씨 정보를 가져옵니다.
            
        }
    }
    
    // MARK: - fetchWeatherInfo 메서드: 입력된 좌표를 바탕으로 OpenWeatherMap API를 호출하고, 뷰의 요소들마다 각 데이터를 할당하는 메서드

    func fetchWeatherInfo(lat: Double, lon: Double, cityName: String?) {
        let endPoint = "https://api.openweathermap.org/data/2.5/weather"
        let params: Parameters = ["lat": lat, "lon": lon, "lang": "kr", "units": "metric", "appid": appId]
        
        AF.request(endPoint, method: .get, parameters: params).responseDecodable(of: Root.self) { [weak self] response in
            guard let strongSelf = self else { return }
            
            switch response.result {
                case .success(let root):
                    let weather = root.weather[0]
                    let main = root.main
                    let iconURL = "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"
                    
                    DispatchQueue.main.async {
                        strongSelf.weatherImage.kf.setImage(with: URL(string: iconURL))
                        strongSelf.currentTemp.text = "\(Int(main.temp))"
                        strongSelf.minTemp.text = "\(Int(main.tempMin))"
                        strongSelf.maxTemp.text = "\(Int(main.tempMax))"
                        
    // MARK: - 같은 레이블 내에서 강조 표시할 텍스트 설정하기
                        
                        let imageAttachment = NSTextAttachment()
                        imageAttachment.image = UIImage(systemName: "paperplane")
                        
                        let fullString = NSMutableAttributedString(string: "")
                        
                        fullString.append(NSAttributedString(attachment: imageAttachment))
                        
                        fullString.append(NSAttributedString(string: " \(cityName ?? "")의 날씨는"))
                        
                        fullString.append(NSAttributedString(string: " \(weather.description)!"))
                        
//                        let rangeBlue = (fullString as NSString).range(of: <#T##String#>)
                        
                        strongSelf.testSymbol.attributedText = fullString
                        
                        // 여기서 'cityName'을 사용하여 레이블에 표시합니다.
                        let weatherDescription = weather.description
                        let fullText = "🌈 \(cityName ?? "")의 날씨는 \(weatherDescription)!"
                        let attributedString = NSMutableAttributedString(string: fullText)
                        
//                        attributedString.append(NSAttributedString(attachment: imageAttachment))
//                        attributedString.append(NSAttributedString(string: " \(cityName ?? "")의 날씨는 \(weatherDescription)!"))
                        // 'cityName' 부분의 색상을 변경합니다.
                        let range = (fullText as NSString).range(of: cityName ?? "")
                        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: range)
                        strongSelf.weatherDetail.attributedText = attributedString
                        
    // MARK: - 날씨 업데이트 시점을 원하는 시간 형태로 포맷해서 출력하는 과정
                        
                        let updateTime = root.dt
                        let updateTimeDate = Date(timeIntervalSince1970: updateTime)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "hh:mm:ss a" // "a"는 AM/PM 표기를 위해 추가
//                        formatter.amSymbol = "오전"
//                        formatter.pmSymbol = "오후"
//                        formatter.locale = Locale(identifier: "ko_KR") // 한국어 AM/PM 표기를 사용, 로케일 설정
                        
                        formatter.amSymbol = "AM" // 오전을 나타내는 문자열 설정
                        formatter.pmSymbol = "PM" // 오후를 나타내는 문자열 설정
                        formatter.locale = Locale(identifier: "en_US") // 미국식 AM/PM 표기를 사용하려면 로케일 설정

                        strongSelf.weatherUpdateTime.text = "\(formatter.string(from: updateTimeDate)) 에 업데이트됨"
                        
                        
                        strongSelf.currentTemperature = main.temp
                        
                        strongSelf.setWeatherIllustration(for: weather.main, temp: main.temp)
                    }
                    
                case .failure(let error):
                    print("날씨 정보 요청 에러: \(error.localizedDescription)")
            }
        }
    }

    
    // MARK: - 날씨별 일러스트 분기 처리 메서드 (search - request - 클로저 내부에 weather.main을 아규먼트로 메서드 호출)
    
    func setWeatherIllustration(for weatherCondition: String, temp: Double) {
            switch weatherCondition {
                case "Clear":
                    if temp > 25 {
                        self.weatherIllust.image = UIImage(named: "hotOutfit")
                    } else if temp > 15 {
                        self.weatherIllust.image = UIImage(named: "sunnyOutfit")
                    } else if temp > 5 {
                        self.weatherIllust.image = UIImage(named: "cloudyOutfit")
                    } else {
                        self.weatherIllust.image = UIImage(named: "winterOutfit")
                    }
            case "Clouds":
                    if temp > 25 {
                        self.weatherIllust.image = UIImage(named: "hotOutfit")
                    } else {
                        self.weatherIllust.image = UIImage(named: "cloudyOutfit")
                    }
            case "Rain":
                self.weatherIllust.image = UIImage(named: "rainyOutfit")
            case "Snow":
                self.weatherIllust.image = UIImage(named: "snowyOutfit")
            default:
                self.weatherIllust.image = UIImage(named: "defaultOutfit")
            }
        }
    
}

    // MARK: - Extension 위치 정보 불러오기 델리게이트 메서드 : Location Manager Delegate Methods

extension WeatherViewController: CLLocationManagerDelegate {
    
    func configureLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                locationManager.stopUpdatingLocation()
                search(lat: location.coordinate.latitude, lon: location.coordinate.longitude, city: nil)
            }
        }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("위치 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
        }
    
}

