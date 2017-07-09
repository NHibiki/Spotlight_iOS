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

public class Point {
    public var x: Double = 0
    public var y: Double = 0
    
    init(_ X: Double, _ Y: Double) {
        x = X
        y = Y
    }
    
    public func inView() -> Bool {
        if x >= 0 && x <= Double(globalSize.width) &&
            y >= 0 && y <= Double(globalSize.height) {
            return true
        }
        return false
    }
    
    public func add(_ p: Point) {
        x += p.x
        y += p.y
    }
}

public class Spot {
    public var dataType: Int = 0
    // 0 Text 1 Picture 2 Video
    public var data: String = ""
    public var id: Int = 0
    public var timeStamp: Int = 0
    public var position: Position = Position()
    
    init() {
        dataType = 0
        data = ""
        id = 0
        timeStamp = getTimeStamp()
        position = Position()
    }
    
    public func parse(_ json: JSON) {
        if let datatype = json["datatype"].int,
           let mydata = json["data"].string,
           let myid = json["id"].int,
           let timestamp = json["timestamp"].int {
            dataType = datatype
            data = mydata
            id = myid
            timeStamp = timestamp
            position.parse(json["position"])
        }
    }
    
    public func getDataString() -> String {
        return "{\"datatype\":\(dataType), \"data\":\"\(data)\", \"id\":\(id), \"timestamp\":\(timeStamp), \"position\":\(position.getDataString())}"
    }
    
    public func getData() -> JSON {
        return JSON(parseJSON: getDataString())
    }
    
    public func transPosition() -> Point {
        let myp = Point(position.lo - myPosition.lo, position.la - myPosition.la)
        myp.add(transL(position.ve))
        let myf = transL(myPosition.ve)
        var myAngle = rotateAngle(myp, myf)
        if myAngle > 0.5 {
            myAngle -= 1.0
        }
        
        
        if fabs(myAngle) < 0.08 && fabs(position.ho - myPosition.ho) < 0.5 {
            return Point(map(-0.08, 0.08, 0, Double(globalSize.width), myAngle), map(0.5, -0.5, 0, Double(globalSize.height), position.ho - myPosition.ho))
        }
        
        return Point(-1, -1)
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

public func transL(_ ve: Double) -> Point {
    return Point(sin(Double.pi * 2.0 * ve) * visionLen, cos(Double.pi * 2.0 * ve) * visionLen)
}

public func rotateAngle(_ p1: Point, _ p2: Point) -> Double{
    let epsilon = 1.0e-6;
    var angle: Double = 0
    var degree: Double = 0
    var dist: Double = 0
    var dot: Double = 0
    
    dist = sqrt(p1.x * p1.x + p1.y * p1.y)
    p1.x = p1.x / dist
    p1.y = p1.y / dist
    dist = sqrt(p2.x * p2.x + p2.y * p2.y)
    p2.x = p2.x / dist
    p2.y = p2.y / dist
    
    dot = p1.x * p2.x + p1.y * p2.y
    if fabs(dot - 1.0) <= epsilon {
        angle = 0.0;
    } else if fabs(dot + 1.0) <= epsilon {
        angle = Double.pi
    } else {
        var cross: Double = 0
        angle = acos(dot);
        cross = p1.x * p2.y - p2.x * p1.y;
        if cross < 0 {
            angle = 2 * Double.pi - angle
        }
    }
    degree = angle / Double.pi / 2.0
    return degree
}

public func map(_ x1: Double, _ x2: Double, _ y1: Double, _ y2: Double, _ v: Double) -> Double {
    return (v - x1) / (x2 - x1) * (y2 - y1) + y1
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
    UserId = id
    debugPrint(parameters)
    
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
                                debugPrint("Login Success!")
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

public func getPosts(_ radius: Double = 0.0005, _ completed: @escaping (_ data: [Spot]) -> ()) {
    
    let urlString: String! = ApiBase + "get"
    let parameters: Parameters = [
        "token": UserToken,
        "id": UserId,
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
                                    if let theString = theArray[i]["data"].string {
                                        let json2 = JSON(parseJSON: theString)
                                        let theSpot = Spot()
                                        theSpot.parse(json2)
                                        theSpot.id = theArray[i]["mid"].int ?? 0
                                        debugPrint(theSpot)
                                        mySpots.append(theSpot)
                                    }
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
    }/*
    let json = JSON(parseJSON: "{\"status\":true, \"data\":[{\"position\":\(myPosition.getDataString()),\"datatype\":0, \"data\":\"你好 这是一个留言\", \"id\":1, \"timestamp\": 1923814}]}")
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
    }*/
}

public func sendPosts(_ myPost: Spot, _ completed: @escaping (_ status: Bool) -> ()) {
    
    let urlString: String! = ApiBase + "add"
    let parameters: Parameters = [
        "token": UserToken,
        "id": UserId,
        "position": myPosition.getData(),
        "data": myPost.getData()
    ]
    
    Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
        .responseJSON { response in
            switch response.result {
            case .success:
                if let res = response.data {
                    let json = JSON(data: res)
                    if let status = json["status"].bool {
                        if status {
                            completed(true)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
    }
}
