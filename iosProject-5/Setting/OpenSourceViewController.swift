//
//  OpenSourceViewController.swift
//  iosProject-5
//
//  Created by 조다은 on 4/12/24.
//

import UIKit
import WebKit

class OpenSourceViewController: UIViewController {
    var strURL: String?
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        strURL = "https://mint-cupcake-e59.notion.site/d21531522cca4594b8ace4ff6091721f?pvs=25"
        
        guard let strURL, let url = URL(string: strURL) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
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
