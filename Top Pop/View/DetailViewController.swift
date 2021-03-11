//
//  DetailViewController.swift
//  Top Pop
//
//  Created by Matej Terek on 10/03/2021.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var autorNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var albumTracksTextView: UITextView!
    //assigned data from parent controller
    var trackData = TrackData()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableViewContent()
    }

    func loadTableViewContent(){
        //Load content sended from parent controller
        self.navigationBar.topItem?.title =  trackData.trackName!.capitalizeFirstLetter()
        trackNameLabel.text = trackData.trackName
        autorNameLabel.text = trackData.authorName
        albumNameLabel.text = trackData.albumName
        //Fetch album cover image and all album tracks
        FetchModal().getAlbumTracksData(parameter: String(trackData.albumID!)) {
            (newList, status,message) in
            if status{
                //fetching succeeded setup content
                DispatchQueue.main.async {
                    self.headerImageView.loadImageUsingCache(imagePath: newList.coverImgString! , completionHandler: {
                        _ in
                    })
                    self.albumTracksTextView.text = newList.trackName?.joined(separator: "\n")
                }
            }
            else
            {
                //Error handling
                self.showAlertFailed(title: "Error", message: "Something went wrong, check your internet connection and try again.", controller: self)
            }
        }
    }

    //Closing View Controller with animation
    @IBAction func backButtonAction() {
        //Transition Animation
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }

}

