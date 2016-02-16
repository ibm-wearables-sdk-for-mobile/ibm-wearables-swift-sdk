//
//  ResultCell.swift
//  RecordApp
//
//  Created by Cirill Aizenberg on 2/3/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit


class ResultCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var sensitivity: UILabel!
    
    func setData(data:ResultData){
        name.text = data.name
        sensitivity.text = "\(data.sensitivity)"
        score.text = "\(data.score)"
    }
}