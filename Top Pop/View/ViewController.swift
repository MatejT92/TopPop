//
//  ViewController.swift
//  Top Pop
//
//  Created by Matej Terek on 09/03/2021.
//

import UIKit
import RSSelectionMenu

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    let cellReuseIdentifier = "tableCell"
    
    var topTracksList = [TrackData]()

    // Sorting Types for top tracks data
    let sortArray = [sortType.normal, sortType.sortASC, sortType.sortDESC]
    var sortArrayActive = [sortType.normal]
    enum sortType: String {
        case normal = "normal", sortASC = "sort asc", sortDESC = "sort desc"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize loading HUD
        activityIndicator()
        //Show loading HUD
        indicator.startAnimating()
        //Start fetching and loading top tracks
        loadTableViewContent()
        //Add pull to refresh to table view
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    func loadTableViewContent(){
        FetchModal().getTopTracksData(parameter: "") {
            (newList, status,message) in
            if status{
                // Fetcing successful show new data
                DispatchQueue.main.async {
                    self.topTracksList = newList
                    self.tableView.reloadData()
                    //Remove Loading Hud
                    self.indicator.stopAnimating()
                }
            }
            else
            {
                //Show Error message
                self.showAlertFailed(title: "Error", message: "Something went wrong, check your internet connection and try again.", controller: self)
                self.indicator.stopAnimating()
            }
        }
    }

    @objc func reloadData(refreshControl: UIRefreshControl) {
        //Show main loading HUD
        indicator.startAnimating()
        //Clear all data
        topTracksList.removeAll()
        tableView.reloadData()
        sortArrayActive = [sortType.normal]
        // Load all data
        loadTableViewContent()
        // Stop refresing animation
        refreshControl.endRefreshing()
    }

    // Number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topTracksList.count
    }

    // Create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrackTableCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TrackTableCell
        //Load cell at index with data
        let currentItem = topTracksList[indexPath.item]
        cell.positionLabel?.text = String(format: "%02d", currentItem.position!)
        cell.trackNameLabel?.text = currentItem.trackName
        cell.autorNameLabel?.text = currentItem.authorName
        cell.durationLabel?.text = currentItem.duration?.convertToMMSS()
        cell.imgPlaceholder?.loadImageUsingCache(imagePath: currentItem.authorImgString! , completionHandler: {
            _ in
        })
        return cell
    }

    // Method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Uncheck clicked row
        tableView.deselectRow(at: indexPath, animated: true)
        //Present Detail View
        let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailViewController
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.trackData = topTracksList[indexPath.row]
        //Transition Animation and presentation
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(detailsVC, animated: false)
    }

    @IBAction func changeSortType(){
        //Load active value for Sorting Type
        let selectionMenu = RSSelectionMenu(dataSource: sortArray) {
            (cell, item, indexPath) in
            cell.textLabel?.text = item.rawValue
        }
        // User picked Sorting Type
        selectionMenu.onDismiss = {
            [weak self] items in
            self?.sortArrayActive = items
            self?.sortTrackArray()
            self?.tableView.reloadData()
        }
        //  Present Sorting Type Picker
        selectionMenu.show(style: .actionSheet(title: "Sort as:", action: "Done", height: nil), from: self)
        selectionMenu.setSelectedItems(items: sortArrayActive) {
            (text, index, isSelected, selectedItems) in
        }
    }

    //  Sort Array depending on picked sorting type
    func sortTrackArray(){
        switch (sortArrayActive.first) {
            case .sortASC: self.topTracksList = self.topTracksList.sorted(by: {
                $0.duration! < $1.duration!
            })
            case .sortDESC: self.topTracksList = self.topTracksList.sorted(by: {
                $0.duration! > $1.duration!
            })
            default: self.topTracksList = self.topTracksList.sorted(by: {
                $0.position! < $1.position!
            })
        }
    }

    //  Initialization of Loading HUD
    var indicator = UIActivityIndicatorView()
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        indicator.color = UIColor.white
        indicator.layer.cornerRadius = 10
        self.view.addSubview(indicator)
    }

}
