//
//  ColorsViewController.swift
//  Symmetry
//
//  Created by Ahmed Allam on 3/30/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol ColorsViewControllerDelegate {
    func didPickColor(_ color: UIColor)
}

class ColorsViewController: UIViewController{
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var colorPickerView: UIView!
    private var colorPicker: ChromaColorPicker!
    var previousColor: UIColor!
    
    var delegate: ColorsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.layer.cornerRadius = 25
        doneButton.layer.cornerRadius = 25
        createColorPicker()
        
    }

    
    private func createColorPicker(){
        colorPickerView.layer.cornerRadius = 15
        colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        colorPicker.delegate = self //ChromaColorPickerDelegate
        colorPicker.padding = 10
        colorPicker.stroke = 10
        colorPicker.hexLabel.isHidden = true
        colorPicker.adjustToColor(previousColor)
        colorPicker.supportsShadesOfGray = true
        colorPickerView.addSubview(colorPicker)
        addColorPickerConstraints()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        let color = colorPicker.currentColor
        delegate?.didPickColor(color)
        dismiss(animated: true, completion: nil)
    }
    
    private func addColorPickerConstraints(){
        NSLayoutConstraint.activate([
            colorPicker.centerXAnchor.constraint(equalTo: colorPickerView.centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: colorPickerView.centerYAnchor),
            ])
    }
}

extension ColorsViewController: ChromaColorPickerDelegate{
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        //let it empthy to disable add  button press
    }
}

