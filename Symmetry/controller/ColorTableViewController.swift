//
//  ColorTableViewController.swift
//  Symmetry
//
//  Created by Allam on 11/4/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import UIKit

class ColorTableViewController: UITableViewController {

    let colors: [String] = ["white", "black", "red", "green", "blue", "yellow"]
    var lineColor: String!
    var previousSelectedIndexPath:IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Colors"
         self.lineColor = UserDefaults.standard.string(forKey: SettingsKeys.lineColor.rawValue) ?? "white"
        let colorIndex = colors.firstIndex(of: lineColor) ?? 0
        previousSelectedIndexPath = IndexPath(row: colorIndex, section: 0)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
        if let identifier = cell.reuseIdentifier, identifier == lineColor{
            cell.accessoryType = .checkmark
        }
        else{
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //remove previous checkmark
        let previousSelectedCell = tableView.cellForRow(at: previousSelectedIndexPath)
        previousSelectedCell?.accessoryType = .none
        let selectedRow = tableView.cellForRow(at: indexPath)
        selectedRow?.accessoryType = .checkmark
        let colorString = colors[indexPath.row]
        UserDefaults.standard.set(colorString, forKey: SettingsKeys.lineColor.rawValue)
        previousSelectedIndexPath = indexPath
    }

    private func postColorChanged(with color: UIColor){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.colorChanged.rawValue), object: nil, userInfo: ["color": color])
    }
}

