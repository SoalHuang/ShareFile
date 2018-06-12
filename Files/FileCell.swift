//
//  FileCell.swift
//  Files
//
//  Created by SoalHunag on 2018/6/11.
//  Copyright © 2018年 SoalHuang. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var fileTitle: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
        fileTitle.text = nil
        fileSize.text = nil
    }
}
