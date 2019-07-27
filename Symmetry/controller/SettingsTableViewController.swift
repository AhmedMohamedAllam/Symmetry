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
    case isSquared
    case lineWidth
    case lineColor
    case numberOfColumns
    case numberOfRows
    case numberOfCircles
    case showCenteredDashedLines
    case showCrossLines
    case showDashedLines
    case showGridNumbers
    case showCircleNumbers
}

protocol SettingsTableViewControllerDelegate {
    func didChangeSettings()
}

class SettingsTableViewController: UITableViewController{
    static let storyboardID = "settingsTableViewController"
    
    
    @IBOutlet weak var lineWidthStepper: UIStepper!
    @IBOutlet weak var columnsStepper: UIStepper!
    @IBOutlet weak var rowsStepper: UIStepper!
    @IBOutlet weak var circlesStepper: UIStepper!
    
    @IBOutlet weak var gridNumbersSwitch: UISwitch!
    @IBOutlet weak var circleNumbersSwitch: UISwitch!
    @IBOutlet weak var squaredFrameSwitch: UISwitch!
    @IBOutlet weak var gridCenterdDashedLineSwitch: UISwitch!
    @IBOutlet weak var circleCenteredDashedLinesSwitch: UISwitch!
    @IBOutlet weak var circleCrossedLinesSwitch: UISwitch!

    @IBOutlet weak var lineWidthTextField: UITextField!
    @IBOutlet weak var columnsTextField: UITextField!
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var circlesTextField: UITextField!
    
    @IBOutlet weak var lineColorView: RoundedCornerView!

    private final let gridSectionID = 2
    private final let circleSectionID = 3
    
    let defaults = UserDefaults.standard
    var isGridSelected: Bool = false
    var delegate: SettingsTableViewControllerDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Settings"
        configureSettingStartWithUserDefaults()
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "colorPopUpSegue", let colorVC = segue.destination as? ColorsViewController{
            colorVC.delegate = self
            colorVC.previousColor = lineColorView.backgroundColor ?? .yellow
        }
    }

    // Configure previous settings and configure current setting views with them
    func configureSettingStartWithUserDefaults() {
        isGridSelected = (defaults.value(forKey: SettingsKeys.isGrid.rawValue) as? Bool) ?? true
        
        var lineWidth = defaults.integer(forKey: SettingsKeys.lineWidth.rawValue)
        lineWidth = lineWidth > 0 ? lineWidth : 1
        let lineColor = defaults.color(forKey: SettingsKeys.lineColor.rawValue)
        var columns = defaults.integer(forKey: SettingsKeys.numberOfColumns.rawValue)
        columns = columns > 0 ? columns : 7
        var rows = defaults.integer(forKey: SettingsKeys.numberOfRows.rawValue)
        rows = rows > 0 ? rows : 9
        var circles = defaults.integer(forKey: SettingsKeys.numberOfCircles.rawValue)
        circles = circles > 0 ? circles : 5
        let centeredDashedLines = defaults.bool(forKey: SettingsKeys.showCenteredDashedLines.rawValue)
        let crossedLines = defaults.bool(forKey: SettingsKeys.showCrossLines.rawValue)
        let gridDashedLines = defaults.bool(forKey: SettingsKeys.showDashedLines.rawValue)
        let gridNumbers = (defaults.value(forKey: SettingsKeys.showGridNumbers.rawValue) as? Bool) ?? true
        let circleNumbers = (defaults.value(forKey: SettingsKeys.showCircleNumbers.rawValue) as? Bool) ?? true
        let isSquared = defaults.bool(forKey: SettingsKeys.isSquared.rawValue)
        
        
        lineWidthStepper.value = Double(lineWidth)
        columnsStepper.value = Double(columns)
        rowsStepper.value = Double(rows)
        circlesStepper.value = Double(circles)
        lineWidthTextField.text = String(lineWidth)
        lineColorView.backgroundColor = lineColor
        columnsTextField.text = String(columns)
        rowsTextField.text = String(rows)
        circlesTextField.text = String(circles)
        circleCenteredDashedLinesSwitch.setOn(centeredDashedLines , animated: false)
        circleCrossedLinesSwitch.setOn(crossedLines, animated: false)
        squaredFrameSwitch.setOn(isSquared, animated: false)
        gridCenterdDashedLineSwitch.setOn(gridDashedLines, animated: false)
        gridNumbersSwitch.setOn(gridNumbers, animated: false)
        circleNumbersSwitch.setOn(circleNumbers, animated: false)
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressDone(_ sender: UIBarButtonItem) {
        //get Current settings before return and save to defaults
        let lineWidth = Int(lineWidthTextField.text!)
        let color = lineColorView.backgroundColor
        let columns = Int(columnsTextField.text!)
        let rows = Int(rowsTextField.text!)
        let circles = Int(circlesTextField.text!)
        let isCenteredDashedLined = circleCenteredDashedLinesSwitch.isOn
        let isCrossed = circleCrossedLinesSwitch.isOn
        let isGridDashedLines = gridCenterdDashedLineSwitch.isOn
        let isGridNumbersShown = gridNumbersSwitch.isOn
        let isCircleNumbersShown = circleNumbersSwitch.isOn
        let isSquared = squaredFrameSwitch.isOn
        
        
        defaults.set(isGridSelected, forKey: SettingsKeys.isGrid.rawValue)
        defaults.set(color, forKey: SettingsKeys.lineColor.rawValue)
        defaults.set(lineWidth, forKey: SettingsKeys.lineWidth.rawValue)
        defaults.set(columns, forKey: SettingsKeys.numberOfColumns.rawValue)
        defaults.set(rows, forKey: SettingsKeys.numberOfRows.rawValue)
        defaults.set(circles, forKey: SettingsKeys.numberOfCircles.rawValue)
        defaults.set(isCenteredDashedLined, forKey: SettingsKeys.showCenteredDashedLines.rawValue)
        defaults.set(isCrossed, forKey: SettingsKeys.showCrossLines.rawValue)
        defaults.set(isGridDashedLines, forKey: SettingsKeys.showDashedLines.rawValue)
        defaults.set(isGridNumbersShown, forKey: SettingsKeys.showGridNumbers.rawValue)
        defaults.set(isCircleNumbersShown, forKey: SettingsKeys.showCircleNumbers.rawValue)
        defaults.set(isSquared, forKey: SettingsKeys.isSquared.rawValue)

        // notify CameraViewController that done button was pressed
        delegate?.didChangeSettings()
        //return to Camera
        navigationController?.popViewController(animated: true)
    }
    
    
    
    //Mark: - overlay choices (grid or circle)
    // put checkmark on user previous choise
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isGrid = (defaults.value(forKey: SettingsKeys.isGrid.rawValue) as? Bool) ?? true
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
        }else if section == 0{
            return 2
        }else if section == 1{
            return 3
        }else{ //return 3 if circle or grid that is not hidden
            return 4
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


extension SettingsTableViewController: ColorsViewControllerDelegate{
    func didPickColor(_ color: UIColor) {
        lineColorView.backgroundColor = color
    }
}
