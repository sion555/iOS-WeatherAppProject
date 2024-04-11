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
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
