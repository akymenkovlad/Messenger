//
//  NewConversationCell.swift
//  Messenger
//
//  Created by Valados on 11.11.2021.
//

import UIKit
import SDWebImage

class NewConversationCell: UITableViewCell {

    static let identifier = "NewConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel:UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         
        userImageView.frame = CGRect(x: 10,
                                   y: 10,
                                   width: 50,
                                   height: 50)
        userNameLabel.frame = CGRect(x: userImageView.rigth+10,
                                   y: 20,
                                     width: contentView.width-20-userImageView.width,
                                     height: 30)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func configure(with model:SearchResult){
        userNameLabel.text = model.name
        
        let path = "images/\(model.email)_profile_picture_png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url:\(error)")
            }
        })
    }
    
}
