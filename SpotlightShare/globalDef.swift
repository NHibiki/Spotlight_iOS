//
//  globalDef.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import Foundation

let appSuperBarController = AppNavigationController(rootViewController: mainViewController())
let myMainColor = rgba(0, 1, 0.686, 1)
let myNavKey = "1b107a7401f4b8c38bca072abadca001"

public var myPosition: Position = Position()
public var documentPath = NSHomeDirectory() + "/Documents/"
public var ApiBase = "http://steins.xin:8080/"

public var Username = ""
public var Password = ""
public var UserId = ""
public var UserToken = ""

public var AllowAutoAr = true
