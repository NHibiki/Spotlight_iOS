//
//  globalFunc.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import Foundation
import Material
import SwiftyJSON
import UIKit
import Alamofire

public class Spot {
    public var dataType: Int = 0
    // 0 Text 1 Picture 2 Video
    public var data: String = ""
    public var timeStamp: Int = 0
    public var position: Position = Position()
    
    init() {
        dataType = 0
        data = ""
        timeStamp = getTimeStamp()
        position = Position()
    }
    
    public func parse(_ json: JSON) {
        if let datatype = json["datatype"].int,
           let mydata = json["data"].string,
           let timestamp = json["timestamp"].int {
            dataType = datatype
            data = mydata
            timeStamp = timestamp
            position.parse(json["position"])
        }
    }
    
    public func getDataString() -> String {
        return "\"datatype\":\(dataType), \"data\":\(data), \"timestamp\":\(timeStamp), \"position\":\(position.getDataString())"
    }
    
    public func getData() -> JSON {
        return JSON(parseJSON: getDataString())
    }
}

public class Position {
    public var lo: Double = 0.0
    public var la: Double = 0.0
    public var ho: Double = 0.0
    public var ve: Double = 0.0
    
    init() {
        lo = 0.0
        la = 0.0
        ho = 0.0
        ve = 0.0
    }
    
    public func savePos(_ loc: CLLocation!) {
        lo = loc.coordinate.longitude
        la = loc.coordinate.latitude
    }
    
    public func saveSens(_ accz: Double, _ dir: Double) {
        ho = dir
        ve = accz
    }
    
    public func getDataString() -> String {
        return "{\"lo\":\(lo), \"la\":\(la), \"ho\":\(ho), \"ve\":\(ve)}"
    }
    
    public func getData() -> JSON {
        return JSON(parseJSON: getDataString())
    }
    
    public func parse(_ json: JSON) {
        if let mylo = json["lo"].double,
           let myla = json["la"].double,
           let myho = json["ho"].double,
           let myve = json["ve"].double {
            lo = mylo
            la = myla
            ho = myho
            ve = myve
        }
    }
}

public func doOrder(_ order: String, _ window: UIWindow) {
    
}

public func getTimeStamp() -> Int {
    let now = NSDate()
    let timeInterval: TimeInterval = now.timeIntervalSince1970
    return Int(timeInterval)
}

public func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

public func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return Color.init(red: red, green: green, blue: blue, alpha: alpha)
}

public func saveUserInfoToFile() {
    let dic = [
        "token": UserToken,
        "id": UserId,
        "name": Username,
        "passwd": Password,
        ]
    let nsdic: NSDictionary = dic as NSDictionary
    nsdic.write(toFile: documentPath + "conf/user.plist", atomically: true)
}

public func readUserInfoFromFile() {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: documentPath + "conf/user.plist") {
        guard let nsdic = NSDictionary(contentsOfFile: documentPath + "conf/user.plist") else {
            return
        }
        let dic: Dictionary = nsdic as! [String:String]
        if dic.count != 4 {
            return
        } else {
            UserToken = dic["token"] ?? ""
            UserId = dic["id"] ?? ""
            Username = dic["name"] ?? ""
            Password = dic["passwd"] ?? ""
        }
    }
}

public func logout() {
    UserToken = ""
    Username = ""
    saveUserInfoToFile()
}

/* Network */

public func loginAction(_ action: String, _ id: String, _ passwd: String, _ urname: String = "", _ completed: @escaping (_ status: Bool) -> ()) {
    let urlString: String! = ApiBase + action
    let parameters: Parameters = [
        "username": urname,
        "email": id,
        "password": passwd
    ]
    
    Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
        .responseJSON { response in
            switch response.result {
            case .success:
                if let res = response.data {
                    let json = JSON(data: res)
                    if let status = json["status"].bool {
                        if status {
                            var isCompleted = true
                            if let token = json["token"].string {
                                UserToken = token
                            } else {
                                isCompleted = false
                            }
                            if let urname = json["username"].string {
                                Username = urname
                            } else {
                                isCompleted = false
                            }
                            if isCompleted {
                                saveUserInfoToFile()
                            }
                            completed(isCompleted)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                completed(false)
            }
    }
}

public func getPosts(_ radius: Double = 0.1, _ completed: @escaping (_ data: [Spot]) -> ()) {
    let urlString: String! = ApiBase + "get"
    let parameters: Parameters = [
        "token": UserToken,
        "position": myPosition.getData(),
        "radius": radius
    ]
    
    Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
        .responseJSON { response in
            switch response.result {
            case .success:
                if let res = response.data {
                    let json = JSON(data: res)
                    if let status = json["status"].bool {
                        if status {
                            if let theArray = json["data"].array {
                                var mySpots: [Spot] = []
                                
                                var i :Int = 0
                                while i < theArray.count {
                                    let theSpot = Spot()
                                    theSpot.parse(theArray[i])
                                    mySpots.append(theSpot)
                                    i += 1
                                }
                                
                                completed(mySpots)
                            }
                            
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
    }
}
