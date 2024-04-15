//
//  SearchDetailViewController.swift
//  iosProject-5
//
//  Created by 한범석 on 4/9/24.
//

import UIKit
import Kingfisher

class SearchDetailViewController: UIViewController {

    var temp: String?
    var tempMin: String?
    var tempMax: String?
    var city: String?
    var weatherImageUrl: String?
    
    var location: (latitude: Double, longitude: Double)?
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var cityName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cityName.text = city
        currentTemp.text = temp
        minTemp.text = tempMin
        maxTemp.text = tempMax
        guard let weatherImageUrl else { return }
        weatherImage.kf.setImage(with: URL(string: weatherImageUrl))
        
    }
    
    
    
   
    @IBAction func addCityPage(_ sender: Any) {
        
        //        let rootViewController = sceneDelegate.window?.rootViewController as? MainPageViewController {
        //            // rootViewController를 사용한 코드
        //
        //
        //            rootViewController.addWeatherViewController(forLocation: location, city: nil)
        //        }
        
        // 이렇게 하면 navigation controller에 연결된 뷰에는 접근할 수 없음, 좀 더 깊게 접근하는 방식을 사용해야 함
        
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let navigationController = sceneDelegate.window?.rootViewController as? UINavigationController,
           let mainPageViewController = navigationController.viewControllers.first as? MainPageViewController {
            
            mainPageViewController.addWeatherViewController(forLocation: location, city: nil)
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
