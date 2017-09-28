//
//  InputViewController.swift
//  taskapp
//
//  Created by Ryo KnoableJP on 2017/09/20.
//  Copyright © 2017年 Ryo KnoableJP. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var categoryTextField: UITextField!
    
    var task: Task! //taskを定義画面遷移用
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture) //viewをタップした時にジェスチャーが起動
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date as Date
        categoryTextField.text = task.category //カテゴリー追加
    } //背景をタップしたら下記のdismissKeyboardメソッドを呼び出す //taskはViewcontrollerから遷移してきた
    
    func dismissKeyboard(){
        view.endEditing(true)
    } //キーボードを閉じる

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date as NSDate
            self.realm.add(self.task, update: true)
            self.task.category = self.categoryTextField.text! //カテゴリー追加
        } //入力されたものを保存する処理
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated) //viewWillDisappearとセットで入れる構文
    }
    
    func setNotification(task: Task) { //taskのローカル通知を設定
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.contents //bodyが空だと音しか出ず通知が出ないので注意
        content.sound = UNNotificationSound.default()
        
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false) //通知の発動するトリガーを設定
        
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        //identifier, content, triggerから通知を作成
        
        let center = UNUserNotificationCenter.current() //今いる場所の時間を含むカレンダーを取得
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録　OK") //errorがnilならローカル通知の登録に成功したことを表示、errorが存在すればerrorと表示
        }
        
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/-------------")
                print(request)
                print("-------------/")
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
