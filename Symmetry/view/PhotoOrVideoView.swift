//
//  PhotoOrVideoView.swift
//  StoryMateCamera
//
//  Created by Ahmed Allam on 2/26/19.
//  Copyright © 2019 TheD. GmbH. All rights reserved.
//

import UIKit

protocol PhotoVideoViewDelegate {
    func didTapPhoto()
    func didTapVideo()
    func didTapSquare()
}

class ImageTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    let selectedColor = UIColor(red: 254/255, green: 228/255, blue: 38/255, alpha: 1)
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override var isSelected: Bool{
        didSet{
            let color = isSelected ? selectedColor : .white
            label.textColor = color
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.textColor = .white
    }
    
    
}

class PhotoOrVideoView: UIView {
    
    

    @IBOutlet weak var collectionView: UICollectionView!

    let types = ["VIDEO", "PHOTO", "SQUARE"]
    
    var delegate: PhotoVideoViewDelegate?
    var currentIndex: Int = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        selectItem(at: currentIndex)
    }
    
    func scrollRight() {
        guard currentIndex > 0 else {
            return
        }
        deselectItem(at: currentIndex)
        selectItem(at: currentIndex - 1)
        currentIndex -= 1
    }
    
    func scrollLeft(){
        guard currentIndex < types.count - 1 else {
            return
        }
        deselectItem(at: currentIndex)
        selectItem(at: currentIndex + 1)
        currentIndex += 1
    }
    
    private func selectItem(at index: Int){
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    private func deselectItem(at index: Int){
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
}


extension PhotoOrVideoView: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageTypeCollectionViewCell", for: indexPath) as! ImageTypeCollectionViewCell
        cell.label.text = types[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageTypeCollectionViewCell", for: indexPath) as! ImageTypeCollectionViewCell
        cell.label.textColor = UIColor(red: 254/255, green: 228/255, blue: 38/255, alpha: 1)
        
        switch indexPath.row {
        case 0:
            delegate?.didTapVideo()
        case 1:
            delegate?.didTapPhoto()
        case 2:
            delegate?.didTapSquare()
        default:
            print("Check your array")
        }
    }
    
    
}
