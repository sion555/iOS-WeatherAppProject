//
//  SearchTableViewController.swift
//  iosProject-5
//
//  Created by 한범석 on 4/9/24.
//

import UIKit
import MapKit
import Alamofire

class SearchTableViewController: UITableViewController {

    
    let appId = "9e237b4900f0bd4d5f48ee8ad2b4dd09"
    
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var isSearchStarted = false   // searchBar의 검색 조건을 다양화시키기 위한 변수
    var hasSearchResults = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchCompleter.delegate = self
        
        self.view.addSubview(searchBar)
        
        if searchResults.isEmpty {
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        } else {
            tableView.tableFooterView = UIView(frame: .zero)
        }

    }
    
    
    // MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if searchResults.isEmpty {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        // 검색 결과의 유무에 따라 화면 스크롤을 활성화하는 메서드
        // - "검색 결과 없음" 셀 출력 시 셀 경계 바깥 여백 공간을 줄일 수 있는 방법이 없어 스크롤 자체를 막는 방법을 사용했음
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.isEmpty ? 1 : searchResults.count
    }
    
    // 테이블 뷰의 "검색 결과 없음" 셀이 눌리는 것을 방지하는 메서드!!
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return searchResults.isEmpty ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return searchResults.isEmpty ? tableView.bounds.height : UITableView.automaticDimension
        if searchResults.isEmpty {
                // Only one cell which says "No results"
//            return tableView.bounds.height / 1.25
            return 361.5
            } else {
                // Normal cell height
                return UITableView.automaticDimension
            }
        
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResults.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoResultsCell", for: indexPath)
            
            
            // 이미지와 레이블을 수직 스택 뷰에 추가합니다.
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.spacing = 15 // 이미지와 텍스트 사이의 간격
            
            // 이미지 뷰를 생성하고 스택 뷰에 추가합니다.
            let imageView = UIImageView(image: UIImage(named: "noResultImage"))
            imageView.contentMode = .scaleAspectFit
            imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true // 이미지 높이 설정
            stackView.addArrangedSubview(imageView)
            
            // 레이블을 생성하고 스택 뷰에 추가합니다.
            let label = UILabel()
            label.text = "검색 결과 없음"
            label.font = UIFont.systemFont(ofSize: 28)
            label.textColor = .gray
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
            
            // 스택 뷰를 셀의 contentView에 추가합니다.
            cell.contentView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                stackView.leadingAnchor.constraint(greaterThanOrEqualTo: cell.contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(lessThanOrEqualTo: cell.contentView.trailingAnchor)
            ])
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
            let searchResult = searchResults[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = searchResult.title
            cell.contentConfiguration = content
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            guard let self = self, let response = response, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let coordinate = response.mapItems[0].placemark.coordinate
            if let searchDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchDetailViewController") as? SearchDetailViewController {
                searchDetailVC.location = (latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        
            
            print("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
            // 이제 위에서 받은 좌표를 이용해 아래 메서드로 날씨 정보 API를 호출하기
            
            self.searchAdd(forLocation: (latitude: coordinate.latitude, longitude: coordinate.longitude), city: completion.title)
            
            
        }
    }
    
    func searchAdd(forLocation location: (latitude: Double, longitude: Double)?, city: String?) {
        
        let endPoint = "https://api.openweathermap.org/data/2.5/weather"
        
        let params: Parameters = ["lat": location?.latitude ?? "", "lon": location?.longitude ?? "", "lang": "kr", "units": "metric", "appid": appId]
        
        AF.request(endPoint, method: .get, parameters: params).responseDecodable(of: Root.self) { response in
            switch response.result {
                case .success(let root):
                    let weather = root.weather[0]
                    let main = root.main
                    let iconURL = "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"
                    

                    
                    if let searchDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchDetailViewController") as? SearchDetailViewController {
                        
                        searchDetailVC.city = city
                        searchDetailVC.temp = "\(Int(main.temp))"
                        searchDetailVC.tempMax = "\(Int(main.tempMax))"
                        searchDetailVC.tempMin = "\(Int(main.tempMin))"
                        searchDetailVC.weatherImageUrl = iconURL
                        
                        searchDetailVC.location = location
                        
                        self.present(searchDetailVC, animated: true)
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
        
    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

    // MARK: -  MKLocalSearchCompleterDelegate 메서드

extension SearchTableViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // 검색 결과 업데이트
        searchResults = completer.results
        hasSearchResults = !searchResults.isEmpty // 검색 결과의 유무에 따라 변수 값을 변경
        
        // 검색 결과를 표시하는 UI 업데이트
        // 예를 들어 여기서는 테이블 뷰 리로드로 처리함
        tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // 에러 처리
        print(error.localizedDescription)
    }
}

    // MARK: - SearchBar Delegate 메서드 모음

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // searchText가 비어있지 않을 때 true값을 받는 isSearchStarted
        isSearchStarted = !searchText.isEmpty
        
        // 사용자 입력이 바뀔 때마다 자동완성 검색 실행
        searchCompleter.queryFragment = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 키보드 올렸다 내렸다 하는 거
        searchBar.resignFirstResponder()
    }
    
    
}
