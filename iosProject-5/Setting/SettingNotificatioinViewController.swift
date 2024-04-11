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
    var toggleSwitch = UISwitch()
    var isToggleOn = false
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
    
    
    // MARK: - Push Notification Methods

    func requestAuthNotification() {
        let notificationAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        center.requestAuthorization(options: notificationAuthOptions) { success, error in
            if let error {
                print("Noti Error: \(error.localizedDescription)")
            }
        }
    }
    
    func requestSendNotification(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "오늘의 날씨입니다"
        content.body = "바람이 많이 부니 조심하세요."
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Noti error: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - PickerView Methods

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
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

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
            
            cell.lblTitle.text = "On / Off"
//            cell.switchToggle.isOn = false
            cell.switchToggle.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
            
            return cell
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! TimePickerTableViewCell
                cell.lblTitle.text = "Delivery Time"
                cell.tfButton.tintColor = .clear
                createPickerView(for: cell.tfButton)

                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
                cell.lblTitle.text = "Location"
                cell.btn.setTitle("Fixed Location", for: .normal)
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
                cell.lblTitle.text = "Type"
                cell.btn.setTitle("On specific conditions", for: .normal)
                return cell

            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell
                cell.lblTitle.text = "default"
                
                return cell
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
