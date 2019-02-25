//
//  ViewController.swift
//  Symmetry
//
//  Created by Allam on 11/3/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import UIKit

enum SettingsKeys: String {
    case isGrid
    case lineWidth
    case lineColor
    case numberOfColumns
    case numberOfRows
    case numberOfCircles
    case showCenterLines
    case showCrossLines
    case showDashedLines
}


class SettingsTableViewController: UITableViewController{
    static let storyboardID = "settingsTableViewController"
    private final let gridSectionID = 2
    private final let circleSectionID = 3
    
    let defaults = UserDefaults.standard
    var isGridSelected: Bool = false
    
    @IBOutlet weak var lineWidthStepper: UIStepper!
    @IBOutlet weak var columnsStepper: UIStepper!
    @IBOutlet weak var rowsStepper: UIStepper!
    @IBOutlet weak var circlesStepper: UIStepper!
    
    @IBOutlet weak var centerLinesSwitch: UISwitch!
    @IBOutlet weak var crossedLinesSwitch: UISwitch!
    @IBOutlet weak var dashedLineSwitch: UISwitch!
    @IBOutlet weak var lineColorView: RoundedCornerView!
    @IBOutlet weak var lineWidthTextField: UITextField!
    @IBOutlet weak var columnsTextField: UITextField!
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var circlesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Settings"
        configureSettingStartWithUserDefaults()
    }
 

    // Configure previous settings and configure current setting views with them
    func configureSettingStartWithUserDefaults() {
        isGridSelected = defaults.bool(forKey: SettingsKeys.isGrid.rawValue)
        var lineWidth = defaults.integer(forKey: SettingsKeys.lineWidth.rawValue)
        lineWidth = lineWidth > 0 ? lineWidth : 1
        let lineColor = defaults.string(forKey: SettingsKeys.lineColor.rawValue) ?? "white"
        var columns = defaults.integer(forKey: SettingsKeys.numberOfColumns.rawValue)
        columns = columns > 0 ? columns : 3
        var rows = defaults.integer(forKey: SettingsKeys.numberOfRows.rawValue)
        rows = rows > 0 ? rows : 3
        var circles = defaults.integer(forKey: SettingsKeys.numberOfCircles.rawValue)
        circles = circles > 0 ? circles : 5
        let centeredLines = defaults.bool(forKey: SettingsKeys.showCenterLines.rawValue)
        let crossedLines = defaults.bool(forKey: SettingsKeys.showCrossLines.rawValue)
        let dashedLines = defaults.bool(forKey: SettingsKeys.showDashedLines.rawValue)
        
        lineWidthStepper.value = Double(lineWidth)
        columnsStepper.value = Double(columns)
        rowsStepper.value = Double(rows)
        circlesStepper.value = Double(circles)
        lineWidthTextField.text = String(lineWidth)
        lineColorView.backgroundColor = lineColor.color()
        columnsTextField.text = String(columns)
        rowsTextField.text = String(rows)
        circlesTextField.text = String(circles)
        centerLinesSwitch.setOn(centeredLines , animated: false)
        crossedLinesSwitch.setOn(crossedLines, animated: false)
        dashedLineSwitch.setOn(dashedLines, animated: false)
    }
    
    @IBAction func doneSettingsAction(_ sender: UIBarButtonItem) {
        //get Current settings before return and save to defaults
        let lineWidth = Int(lineWidthTextField.text!)
        let color = defaults.string(forKey: SettingsKeys.lineColor.rawValue) ?? "white"
        let columns = Int(columnsTextField.text!)
        let rows = Int(rowsTextField.text!)
        let circles = Int(circlesTextField.text!)
        let isCentered = centerLinesSwitch.isOn
        let isCrossed = crossedLinesSwitch.isOn
        let isDashed = dashedLineSwitch.isOn
        
        defaults.set(isGridSelected, forKey: SettingsKeys.isGrid.rawValue)
        defaults.setValue(color, forKey: SettingsKeys.lineColor.rawValue)
        defaults.set(lineWidth, forKey: SettingsKeys.lineWidth.rawValue)
        defaults.set(columns, forKey: SettingsKeys.numberOfColumns.rawValue)
        defaults.set(rows, forKey: SettingsKeys.numberOfRows.rawValue)
        defaults.set(circles, forKey: SettingsKeys.numberOfCircles.rawValue)
        defaults.set(isCentered, forKey: SettingsKeys.showCenterLines.rawValue)
        defaults.set(isCrossed, forKey: SettingsKeys.showCrossLines.rawValue)
        defaults.set(isDashed, forKey: SettingsKeys.showDashedLines.rawValue)
        // notify CameraViewController that done button was pressed
        NotificationCenter.default.post(name: NSNotification.Name.didChangeOverlaySettings, object: nil)
        //return to Camera
        navigationController?.popViewController(animated: true)
    }
    
    
    
    //Mark: - overlay choices (grid or circle)
    // put checkmark on user previous choise
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isGrid = defaults.bool(forKey: SettingsKeys.isGrid.rawValue)
        if let identifier = cell.reuseIdentifier{
            switch identifier{
            case "gridCell":
                cell.accessoryType = isGrid ? .checkmark : .none
            case "circlesCell":
                cell.accessoryType = isGrid ? .none : .checkmark
            default:
                return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            isGridSelected = indexPath.row == 0 ? true : false
            configureOverlayViewCheckmark()
        }
        tableView.reloadSections(IndexSet(integersIn: 2...3), with: .none)
    }
    
    // put checkmark on user choice cell
    func configureOverlayViewCheckmark() {
        let gridCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let circleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        
        if (isGridSelected){
            gridCell?.accessoryType = .checkmark
            circleCell?.accessoryType = .none
        }else{
            circleCell?.accessoryType = .checkmark
            gridCell?.accessoryType = .none
        }
        
    }
    
    // MARK: - Stepper Actions
    @IBAction func lineWidthStepper(_ sender: UIStepper) {
        lineWidthTextField.text = String(Int(sender.value))
    }
    
    @IBAction func columnsStepper(_ sender: UIStepper) {
        columnsTextField.text = String(Int(sender.value))
    }
    @IBAction func circlesStepper(_ sender: UIStepper) {
        circlesTextField.text = String(Int(sender.value))
    }
    @IBAction func rowsStepper(_ sender: UIStepper) {
        rowsTextField.text = String(Int(sender.value))
    }
    

    //    MARK:- Hide sections based on select settings
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHideSection(section) ?
            0.1 : super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return shouldHideSection(section) ?
            0.1 : super.tableView(tableView, heightForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if shouldHideSection(section){
            if let headerView = view as? UITableViewHeaderFooterView{
                headerView.textLabel?.textColor = UIColor.clear
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if it should hide circle or grid return 0
        if  shouldHideSection(section){
            return 0
        }else if section == 0 || section == 1{ // if first or second section return 2
            return 2
        }else{ //return 3 if circle or grid that is not hidden
            return 3
        }
        
    }
    
    
    private func shouldHideSection(_ section: Int) -> Bool{
        if isGridSelected {
            //            if user choose grid settings then hide the circle section
            if section == circleSectionID{
                return true
            }
        }else{
            //            if user choose circle settings then hide the grid section
            
            if section == gridSectionID{
                return true
            }
        }
        return false
    }
}

