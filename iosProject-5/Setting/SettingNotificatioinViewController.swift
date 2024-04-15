//
//  SettingNotificatioinViewController.swift
//  iosProject-5
//
//  Created by 조다은 on 4/11/24.
//

import UIKit

class SettingNotificatioinViewController: UITableViewController {
    let center = UNUserNotificationCenter.current()
    
    var tfButton: UITextField?
    let toggleStateKey = "toggleState"
    var isToggleOn = UserDefaults.standard.bool(forKey: "toggleState")
    let pickerView = UIPickerView()
    var hours = Array(0..<24)
    var minutes = Array(0..<60)
    var pickedHour: Int?
    var pickedMinute: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerXib()
        requestAuthNotification()
    }

    private func registerXib() {
        let nibToggle = UINib(nibName: "ToggleTableViewCell", bundle: nil)
        let nibLabel = UINib(nibName: "LabelTableViewCell", bundle: nil)
        let nibPicker = UINib(nibName: "TimePickerTableViewCell", bundle: nil)
        
        tableView.register(nibToggle,  forCellReuseIdentifier: "toggleCell")
        tableView.register(nibLabel,  forCellReuseIdentifier: "labelCell")
        tableView.register(nibPicker,  forCellReuseIdentifier: "pickerCell")
    }
    
    
    // MARK: - Push 알림 관련 메서드
    // 1. Push 알림 권한
    func requestAuthNotification() {
        let notificationAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        center.requestAuthorization(options: notificationAuthOptions) { success, error in
            if let error {
                print("Noti Error: \(error.localizedDescription)")
            }
        }
    }
    // 2. Push 알림 요청
    func requestSendNotification(hour: Int, minute: Int) {
        let identifier = "Noti_ID"
        
        let content = UNMutableNotificationContent()
        content.title = "좋은 아침이에요! 🌈"
        content.body = "오늘의 날씨를 알려드릴게요!"
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        if isToggleOn {
            print("noti is on")
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("Noti error: \(error.localizedDescription)")
                }
            }
        } else {
            print("noti is off")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Noti_ID"])
        }
    }

    
    // MARK: - Picker view 생성 메서드

    func createPickerView(for textField: UITextField) {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
        
        toolBar.setItems([btnCancel, space, btnDone], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
        
        tfButton = textField
    }
    
    @objc func onPickDone(for textField: UITextField) {
        requestSendNotification(hour: pickedHour ?? 0, minute: pickedMinute ?? 0)
        tfButton?.text = "\(pickedHour!):\(pickedMinute!)"
        tfButton?.resignFirstResponder()
    }
    
    
    @objc func onPickCancel(for textField: UITextField) {
        tfButton?.resignFirstResponder()
    }
    
    @objc func toggleSwitchChanged(_ sender: UISwitch) {
        isToggleOn = sender.isOn
        requestSendNotification(hour: pickedHour ?? 0, minute: pickedMinute ?? 0)
        UserDefaults.standard.set(isToggleOn, forKey: toggleStateKey)
        tableView.reloadData()
    }
    
    
    // MARK: - Table view Data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isToggleOn ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return isToggleOn ? 3 : 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! ToggleTableViewCell
            
            cell.lblTitle.text = "알림 받기"
            // 토글의 value가 변경됨에 따라 처리를 해주기 위해 addTarget으로 메서드 연결
            cell.switchToggle.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
            // 토글의 value를 UserDafault에 저장된 값을 가져옴
            cell.switchToggle.isOn = UserDefaults.standard.bool(forKey: toggleStateKey)
            
            return cell
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! TimePickerTableViewCell
                cell.lblTitle.text = "시간"
                cell.tfButton.tintColor = .clear
                // 버튼을 누르면 picker뷰를 띄울 수 있도록 textField를 넘겨주고 호출
                createPickerView(for: cell.tfButton)

                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
                cell.lblTitle.text = "위치"
                cell.btn.setTitle("실시간 위치", for: .normal)
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
                cell.lblTitle.text = "조건"
                cell.btn.setTitle("매일 받기", for: .normal)
                return cell

            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
                cell.lblTitle.text = "default"
                
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}


// MARK: Picker view Delegate 및 DataSource

extension SettingNotificatioinViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(hours[row])"
        case 1:
            return "\(minutes[row])"
        default:
            return "0"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            pickedHour = hours[row]
        case 1:
            pickedMinute = minutes[row]
        default:
            pickedHour = 0
            pickedMinute = 0
        }
    }
}
