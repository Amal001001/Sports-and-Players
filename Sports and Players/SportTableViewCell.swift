//  SportTableViewCell.swift
//  Sports and Players

import UIKit

protocol imagePickerDelegate{
    func imagePick(cellIndexPath : Int)
}

class SportTableViewCell: UITableViewCell {

    var delegate : imagePickerDelegate?
    var cellindexpath : Int?
    
    @IBOutlet weak var sportNameLabel: UILabel!
    
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var addImageView: UIImageView!
    
    @IBAction func addImageButton(_ sender: UIButton) {
        delegate?.imagePick(cellIndexPath: cellindexpath!)
    }
    
}
