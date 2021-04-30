//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Mohsin Ali Ayub on 24.04.21.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    
    // properties
    let categories = ["No Category", "Apple Store", "Bar", "Bookstore", "Club",
                      "Grocery Store", "Historic Building", "House", "Icecream Vendor",
                      "Landmark", "Park"]
    var selectedCategoryName = ""
    var selectedIndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for (index, categoryName) in categories.enumerated() {
            if categoryName == selectedCategoryName {
                selectedIndexPath = IndexPath(row: index, section: 0)
                break
            }
        }
    }
    
    // MARK:- Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel?.text = categoryName
        cell.accessoryType = categoryName == selectedCategoryName ? .checkmark : .none
        
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        cell.selectedBackgroundView = selection
        
        return cell
    }
    
    // MARK:- Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if user taps same cell that has already been selected, do nothing
        guard indexPath.row != selectedIndexPath.row else {
            return
        }
        
        // if user selects a different cell, then remove checkmark from old cell and put it
        // on newly selected cell
        if let newCell = tableView.cellForRow(at: indexPath) {
            newCell.accessoryType = .checkmark
        }
        
        if let oldCell = tableView.cellForRow(at: indexPath) {
            oldCell.accessoryType = .none
        }
        
        // save this information
        selectedIndexPath = indexPath
        
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }

}
