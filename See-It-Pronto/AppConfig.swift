//
//  Config.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/7/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import Foundation

struct AppConfig {
    
    static var APP_URL        = "http://oauthtest-nyxent.rhcloud.com"
    static var GRANT_TYPE     = "client_credentials"
    //0 en espera, 1 aceptado, 2 rechazado, 3 completado, 4 cancelado
    static var SHOWING_CANCELED_STATUS = "4"
    static var SHOWING_WAIT_SECONDS = 15

    
}

