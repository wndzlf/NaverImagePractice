//
//  NaverImageTableViewCell.swift
//  TableViewPractice
//
//  Created by admin on 2019/12/10.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

class NaverImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var naverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton?
    
    var cellModel: NaverImageCellModel?
    
    func configure(_ imageURLString: String, _ titleLabel: String, _ vc: imageCachingDelegate) {
        self.cellModel = NaverImageCellModel(imageURLString)
        self.titleLabel.text = titleLabel
        self.cellModel?.imageDicDelegate = vc
        
        guard let linkButton = linkButton else {
            return
        }
        linkButton.setTitle(imageURLString, for: .normal)
        
        cellModel?.downloadImage() { [weak self] image in
            self?.naverImage.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEditing = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellModel?.prepareForReuse()
        naverImage.image = nil
        titleLabel.text = nil
    }
    
    deinit {
        print("NaverImageTableViewCell deinit")
    }
}
