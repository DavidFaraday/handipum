//
//  LikeTableViewCell.swift
//  Dating
//
//  Created by David Kababyan on 12/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class LikeTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(user: FUser) {
        
        nameLabel.text = user.username
        setAvatar(avatarLink: user.avatarLink)
    }

    
    private func setAvatar(avatarLink: String) {
        
        FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            self.avatarImageView.image = avatarImage?.circleMasked
        }
    }
}

