//
//  ImageCollectionViewCell.swift
//  Dating
//
//  Created by David Kababyan on 06/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var countryCityLabel: UILabel!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var backgroundPlaceholder: UIView!
    
    let gradientLayer = CAGradientLayer()
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if indexPath.row == 0 {
            backgroundPlaceholder.isHidden = false
            setGradientBackground()
        } else {
            backgroundPlaceholder.isHidden = true
        }
    }


    
    func setupCell(image: UIImage, countryCity: String, nameAge: String, indexPath: IndexPath) {
        self.indexPath = indexPath
        imageView.image = image
        
        countryCityLabel.text = indexPath.row == 0 ? countryCity : ""
        nameAgeLabel.text = indexPath.row == 0 ? nameAge : ""
        
    }
    
    func setGradientBackground() {
        gradientLayer.removeFromSuperlayer()

//        self.backgroundPlaceholder.frame.size.width += 10 //to cover 10 point margin

        let colorTop =  UIColor.clear.cgColor
        let colorBottom = UIColor.black.cgColor

        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        
        gradientLayer.cornerRadius = 5
        gradientLayer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        gradientLayer.frame = self.backgroundPlaceholder.bounds

        self.backgroundPlaceholder.layer.insertSublayer(gradientLayer, at:0)
    }
    
}
