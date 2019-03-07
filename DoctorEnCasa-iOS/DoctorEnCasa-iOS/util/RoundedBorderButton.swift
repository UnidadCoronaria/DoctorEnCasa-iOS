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
        self.applyGradient()
        layer.borderWidth = 1.0
        layer.borderColor = tintColor.cgColor
        layer.cornerRadius = 5.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setTitleColor(tintColor, for: [])
        setTitleColor(UIColor.white, for: .highlighted)
        
    }
    
    func applyGradient() -> Void {
      /*  let gradientColors: [CGColor] = [UIColor.init(red: 200, green: 114, blue:122).cgColor, UIColor.init(red: 244, green: 122, blue:126).cgColor]
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = gradientColors
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0.7, y: 0)
        self.layer.addSublayer(gradient)*/
    }
}
