//
//  FetchModal.swift
//  Top Pop
//
//  Created by Matej Terek on 09/03/2021.
//

import Foundation
import UIKit
import SystemConfiguration

let TRACKURL = "https://api.deezer.com/chart"
let ALBUMURL = "https://api.deezer.com/album/"

struct TrackData {
    var trackName: String?
    var authorName: String?
    var authorImgString: String?
    var duration: Int?
    var albumName: String?
    var albumID: Int?
    var position: Int?
}

struct AlbumData {
    var coverImgString: String?
    var trackName: [String]?
}

class FetchModal: NSObject{
    //Method for fetching top tracks data
    func getTopTracksData(parameter : String ,completion:(([TrackData],(Bool),(String))->())?){
        //Network check
        if !isInternetAvailable(){
            completion!([TrackData](), false,"NO Internet Connection")
            return
        }
        var wholeList = [TrackData]()
        webserviceFetchGet(parameters: parameter)
        {
            (fetchedData,error,httpResponse) in
            //Fetching Successful
            if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
                //Load recived data
                if let dict = fetchedData as? NSDictionary{
                    let tracks = dict["tracks"] as? NSDictionary
                    let dataArray = tracks!["data"] as? NSArray
                    var track = TrackData()
                    for info in dataArray!{
                        if let data = info as? NSDictionary{
                            let artist = data["artist"] as? NSDictionary
                            track.authorName = artist?["name"] as? String  ?? "Unknown"
                            track.authorImgString = artist?["picture"] as? String ?? "Unknown"
                            let album = data["album"] as? NSDictionary
                            track.albumID = album?["id"] as? Int
                            track.albumName = album?["title"] as? String  ?? "Unknown"
                            track.trackName = data["title"] as? String ?? "Unknown"
                            track.position = data["position"] as? Int
                            track.duration = data["duration"] as? Int
                            wholeList.append(track)
                        }
                    }
                }
                completion!(wholeList, true, "Success")
            }
            //handle error
            else if httpResponse.statusCode >= 400{
                completion!([TrackData](), false,"error occurred")
            }
        }
    }

    //Method for fetching all track for specific album
    func getAlbumTracksData(parameter : String ,completion:((AlbumData,(Bool),(String))->())?){
        //Network check
        if !isInternetAvailable(){
            completion!(AlbumData(), false,"NO Internet Connection")
            return
        }
        var wholeList = AlbumData()
        webserviceFetchGet(parameters: parameter)
        {
            (fetchedData,error,httpResponse) in
            //Fetching Successful
            if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300{
                //Load recived data
                var tracksArray = [String]()
                if let dict = fetchedData as? NSDictionary{
                    let tracks = dict["tracks"] as? NSDictionary
                    let dataArray = tracks!["data"] as? NSArray
                    for info in dataArray!{
                        if let data = info as? NSDictionary{
                            tracksArray.append(data["title"] as? String ?? "Unknown")
                        }
                    }
                    wholeList.coverImgString = dict["cover"] as? String
                    wholeList.trackName = tracksArray
                }
                completion!(wholeList, true, "Success")
            }
            //handle error
            else if httpResponse.statusCode >= 400{
                completion!(AlbumData(), false,"error occurred")
            }
        }
    }

    // Web Service
    private func webserviceFetchGet( parameters: String, completion: ((Any?,(Bool),(HTTPURLResponse))->())?) {
        var url = URL(string: TRACKURL)
        //Check if needed album tracks
        if parameters != "" {
            url = URL(string: ALBUMURL.appending(parameters))
        }
        let request = URLRequest(url: url! as URL)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            let httpResponse = response as? HTTPURLResponse
            if error != nil {
                print("error \(String(describing: httpResponse?.statusCode))")
                DispatchQueue.main.async {
                    //return parsed data
                    let parsedData = NSArray()
                    completion?(parsedData , true, HTTPURLResponse())
                }
            }
            guard let data = data, error == nil else {
                print(error!)                                 // some fundamental network error
                return
            }
            do {
                //parse received data
                let parsedData = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    completion?(parsedData, false,httpResponse!)
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }

    //Check if User is connected to internet
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

}
