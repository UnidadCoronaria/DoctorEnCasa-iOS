//
//  RoundedBorderButton.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 11/01/2019.
//  Copyright © 2019 Agustin. All rights reserved.
//

import UIKit

class RoundedBorderButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1.0
        layer.borderColor = tintColor.cgColor
        layer.cornerRadius = 5.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setTitleColor(tintColor, for: [])
        setTitleColor(UIColor.white, for: .highlighted)
    }
}
