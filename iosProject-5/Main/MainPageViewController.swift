//
//  MainPageViewController.swift
//  iosProject-5
//
//  Created by 한범석 on 4/13/24.
//

import UIKit
import CoreLocation

class MainPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    
    var weatherViewControllers = [WeatherViewController]()
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
//        let navigationBar = UINavigationBar()
//        self.view.addSubview(navigationBar)

        
        // 초기 위치의 날씨 뷰 컨트롤러를 추가
        configureLocationManager()
        
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = weatherViewControllers.firstIndex(of: viewController as! WeatherViewController), index > 0 else { return nil }
        return weatherViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = weatherViewControllers.firstIndex(of: viewController as! WeatherViewController), index < weatherViewControllers.count - 1 else { return nil }
        return weatherViewControllers[index + 1]
    }

    func addWeatherViewController(forLocation location: (latitude: Double, longitude: Double)?, city: String?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let weatherVC = storyboard.instantiateViewController(withIdentifier: "WeatherViewController") as? WeatherViewController {
            weatherVC.location = location
            weatherVC.search(lat: location?.latitude, lon: location?.longitude, city: city)
            weatherViewControllers.append(weatherVC)
            setViewControllers([weatherVC], direction: .forward, animated: true, completion: nil)
            print(weatherVC)
        }
    }
    
}



extension MainPageViewController: LocationSelectionDelegate {
    
    func locationSelected(_ location: (latitude: Double, longitude: Double)) {
        addWeatherViewController(forLocation: location, city: nil)
    }
    
}


extension MainPageViewController: CLLocationManagerDelegate {
    
    func configureLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                locationManager.stopUpdatingLocation()
                addWeatherViewController(forLocation: (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), city: nil)
            }
        }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("위치 정보를 가져오는 데 실패했습니다: \(error.localizedDescription)")
        }
}
