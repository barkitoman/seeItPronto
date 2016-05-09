//
//  Config.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/7/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import Foundation
import UIKit

struct AppConfig {
    static var APP_URL                 = "http://oauthtest-nyxent.rhcloud.com"
    static var GRANT_TYPE              = "client_credentials"
    //0 en espera, 1 aceptado, 2 rechazado, 3 completado, 4 cancelado
    static var SHOWING_CANCELED_STATUS = "4"
    static var SHOWING_WAIT_SECONDS    = 20
    static var MODE                    = "DEVELOP" //PROD, DEVELOP

}

//model for avoid repeat images no table lists
class Model {
    var property : JSON = []
    var im : UIImage!
    var picurl : String!
    var task : NSURLSessionTask!
    var reloaded = false
}

//struct for keep visible input fields
struct MoveKeyboard {
    static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
    static let MINIMUM_SCROLL_FRACTION : CGFloat = 0.2;
    static let MAXIMUM_SCROLL_FRACTION : CGFloat = 0.8;
    static let PORTRAIT_KEYBOARD_HEIGHT : CGFloat = 216;
    static let LANDSCAPE_KEYBOARD_HEIGHT : CGFloat = 162;
}

