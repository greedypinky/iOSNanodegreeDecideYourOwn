
//
//  Cell.swift
//  MyTripDiary
//
//  Created by Naoto Motohashi on 2019/05/17.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit
protocol CustomCell:class{
    
    static var defaultReuseIdentifier: String { get }
    
}

extension CustomCell {
    
    static var defaultResueIdentifier: String {
        
        return ""
    }
}
