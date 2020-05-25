//
//  RecentChatTableViewCell.swift
//  Dating
//
//  Created by David Kababyan on 09/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

protocol RecentChatTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}


class RecentChatTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var unreadMessageBackground: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    
    //MARK: - Vars
    let tapGesture = UITapGestureRecognizer()
    var delegate: RecentChatTableViewCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadMessageBackground.layer.cornerRadius = unreadMessageBackground.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func generateCell(recentChat: RecentChat) {
        
        nameLabel.text = recentChat.receiverName
        lastMessageLabel.text = recentChat.lastMessage
        
        //set counter if available
        if recentChat.unreadCounter != 0 {
            self.unreadMessageCountLabel.text = "\(recentChat.unreadCounter)"
            self.unreadMessageBackground.isHidden = false
            self.unreadMessageCountLabel.isHidden = false
        } else {
            self.unreadMessageBackground.isHidden = true
            self.unreadMessageCountLabel.isHidden = true
        }
    
        setAvatar(avatarLink: recentChat.avatarLink)
        dateLabel.text = timeElapsed(recentChat.date)
    }
    
    private func setAvatar(avatarLink: String) {
        
        FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            self.avatarImageView.image = avatarImage?.circleMasked
        }
    }
        
    func timeElapsed(_ date: Date) -> String {
        
        let seconds = Date().timeIntervalSince(date)

        var elapsed = ""
        
        if (seconds < 60) {
            elapsed = "Just now"
        } else if (seconds < 60 * 60) {
            let minutes = Int(seconds / 60)
            
            var minText = "min"
            if minutes > 1 {
                minText = "mins"
            }
            elapsed = "\(minutes) \(minText)"
            
        } else if (seconds < 24 * 60 * 60) {
            
            let hours = Int(seconds / (60 * 60))
            var hourText = "hour"
            if hours > 1 {
                hourText = "hours"
            }
            
            elapsed = "\(hours) \(hourText)"
            
        } else {
            
            elapsed = date.longDate()
        }
        
        return elapsed
    }
}
