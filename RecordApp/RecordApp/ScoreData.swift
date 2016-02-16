//
//  ScoreData.swift
//  RecordApp
//
//  Created by Cirill Aizenberg on 2/3/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation


class ResultData {
    
    var name:String
    var sensitivity:Double
    var score:Double
    
    init(name:String, withScore score:Double, withSensativity sensativity:Double){
        self.name = name
        self.sensitivity = sensativity
        self.score = score
    }
}