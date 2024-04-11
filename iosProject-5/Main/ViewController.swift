//
//  ViewController.swift
//  iosProject-5
//
//  Created by 한범석 on 4/7/24.
//

import UIKit
import Alamofire
import Kingfisher
import CoreLocation

class ViewController: UIViewController {

    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        print("tokki")
        print("tokki2")
        
        print("tokki3")
        print("tokki4")
        
        print("tokki5")
        print("tokki6")
        
        configureLocationManager()
        
    // MARK: - 오늘의 날짜를 보여주는 dateFormatter
        
        let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어로 설정
            dateFormatter.dateFormat = "M월 d일(E)" // 원하는 날짜 형식 설정
            let formattedDate = dateFormatter.string(from: now)

            todaysDate.text = formattedDate

    }
    
    
    
    @IBAction func actDetailWeather(_ sender: Any) {
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // DetailViewController에 전달할 데이터 설정 (옵션)
            
            // 모달 프레젠테이션 스타일 설정
            detailVC.modalPresentationStyle = .fullScreen // 또는 .overFullScreen 등 원하는 스타일 선택
            detailVC.modalTransitionStyle = .coverVertical // 아래에서 위로 올라오는 스타일
            
            detailVC.isModalInPresentation = false
            // 모달을 스와이프로 닫을 수 있게 함
            
            // DetailViewController 표시
            self.present(detailVC, animated: true, completion: nil)
            
            
            
        }

        
    }
    
    
    
    // MARK: - 날씨 정보 불러오기 search 메서드 (api 변경 가능, 변경 시 json 모델링 파일 추가해야 함)
    

    func search(lat: Double, lon: Double) {
        let endPoint = "https://api.openweathermap.org/data/2.5/weather"
//        let params: Parameters = ["q":"\(city)", "lang":"kr", "units":"metric", "appid": appId]
        let params: Parameters = ["lat": lat, "lon": lon, "lang": "kr", "units": "metric", "appid": appId]
        
        
        AF.request(endPoint, method: .get, parameters: params).responseDecodable(of: Root.self) { response in
            switch response.result {
                case .success(let root):
                    let weather = root.weather[0]
                    let main = root.main
                    let iconURL = "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"
                    self.weatherImage.kf.setImage(with: URL(string: iconURL))
                    
                    self.currentTemp.text = "\(Int(main.temp))"
                    self.minTemp.text = "\(Int(main.tempMin))"
                    self.maxTemp.text = "\(Int(main.tempMax))"
                    
                    // MARK: - 같은 레이블 내에서 강조 표시할 텍스트 설정하기
                    
//                    self.weatherDetail.text = "\(root.name)시의 날씨는 \(weather.description)!"
                    
                    let cityName = "\(root.name)"
                    let weatherDescription = "\(weather.description)"
                    let fullText = "\(cityName)시의 날씨는 \(weatherDescription)!"

                    let attributedString = NSMutableAttributedString(string: fullText)

                    // cityName 부분의 색상을 변경
                    let range = (fullText as NSString).range(of: cityName)
                    attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: range)

                    // NSAttributedString을 UILabel에 적용
                    self.weatherDetail.attributedText = attributedString
                    
                    // MARK: - 날씨 업데이트 시점 포맷해서 텍스트로 출력하기
                    
                    let updateTime = root.dt
                    let updateTime1 = Date(timeIntervalSince1970: updateTime)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm:ss"
                    
                    self.weatherUpdateTime.text = "\(formatter.string(from: updateTime1))에 업데이트됨"
                    
                    // 날씨별 일러스트를 변경하는 메서드
                    self.setWeatherIllustration(for: weather.main)
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - 날씨별 일러스트 분기 처리 메서드 (search - request - 클로저 내부에 weather.main을 아규먼트로 메서드 호출)
    
    func setWeatherIllustration(for weatherCondition: String) {
            switch weatherCondition {
            case "Clear":
                self.weatherIllust.image = UIImage(named: "sunnyOutfit")
            case "Clouds":
                self.weatherIllust.image = UIImage(named: "cloudyOutfit")
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

extension ViewController: CLLocationManagerDelegate {
    
    func configureLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                locationManager.stopUpdatingLocation()
                search(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            }
        }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("위치 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
        }
    
}

