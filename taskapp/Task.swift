//
//  Task.swift
//  taskapp
//
//  Created by Ryo KnoableJP on 2017/09/21.
//  Copyright © 2017年 Ryo KnoableJP. All rights reserved.
//

import RealmSwift

class Task: Object {
    dynamic var id = 0
    // 管理用id
    
    dynamic var title = ""
    //タイトル
    
    dynamic var category = ""
    //カテゴリー追加
    
    dynamic var contents = ""
    //内容
    
    dynamic var date = NSDate()
    //日時
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
