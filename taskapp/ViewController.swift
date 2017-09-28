//
//  ViewController.swift
//  taskapp
//
//  Created by Ryo KnoableJP on 2017/09/20.
//  Copyright © 2017年 Ryo KnoableJP. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm() //Realmのインスタンス取得
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    //日付が近い順でソート、以降は内容をアップデートすると自動的にリスト内は更新される。
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    } //セルの数を返すメソッド
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title //セルのタイトルにtaskから代入
        
    let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString // セルのサブタイトル
        
    return cell
    } //各セルの内容を返すメソッド　再利用可能なセルを得る,Cellに値を設定する
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) //SegueのIDを指定
    } //各セルを選択した時に実行されるメソッド
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    } //セルが削除可能であることを伝えるメソッド
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let task = self.taskArray[indexPath.row] //削除されたタスクを取得
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)]) //ローカル通知をキャンセル
            
            
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            } //データベースから削除する
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/-------------")
                    print(request)
                    print("-------------/")
                }
            }
        }
        
    } //Deleteボタンが押された時に呼ばれるメソッド
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        } else {
            taskArray = try! Realm().objects(Task.self).filter("name CONTAINS[c] %@", searchText).sorted(byKeyPath: "date", ascending: false)
        }
        
        tableView.reloadData()
    } //検索機能メソッド 画面をリロード

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
            
        }
    } //segue画面遷移用構文
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() //画面を更新する
    }
    
    
}

