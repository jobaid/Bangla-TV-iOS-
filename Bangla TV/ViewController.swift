//
//  ViewController.swift
//  YTDemo
//
//  Created by Gabriel Theodoropoulos on 27/6/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import GoogleMobileAds
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADInterstitialDelegate, UIAlertViewDelegate {
 
    @IBOutlet weak var banner: GADBannerView!
    
    @IBOutlet weak var tblVideos: UITableView!
    
    
     var interstitial: DFPInterstitial?
    
    
    @IBOutlet weak var viewWait: UIView!
    

    
    
    
    
    var channelsDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    var apikey = "AIzaSyDuHaFZiqAm6fN1aTbKArPfW9j460Yzuts"
    var playlist = "PL0VCasrK-xZABhtPS3Nx3EtIWYFr5VEvm"
    
    var selectedVideoIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if connectedToNetwork() == true {
            
            tblVideos.delegate = self
            tblVideos.dataSource = self
            
            getChannelDetails(false)
              loadInterstitial()
            print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
            banner.adUnitID = "ca-app-pub-2242167988124353/7544440627"
            banner.rootViewController = self
            banner.loadRequest(GADRequest())
            //
            
         
            
        }
            
        else {
            showEventsAcessDeniedAlert()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let playerViewController = segue.destinationViewController as! PlayerViewController
        playerViewController.videoID = channelsDataArray[selectedVideoIndex]["videoID"] as! String
        
    }
    
    
    // MARK: IBAction method implementation
    
    
    //setting
    func showEventsAcessDeniedAlert() {
        let alertController = UIAlertController(title: "No Internet Connection",
            message: "Please Connect Your Mobile Data or WIFI Connection",
            preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (alertAction) in
            
            // THIS IS WHERE THE MAGIC HAPPENS!!!!
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: UITableView method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return channelsDataArray.count
        
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        
        cell = tableView.dequeueReusableCellWithIdentifier("idCellChannel", forIndexPath: indexPath)
        
        let channelTitleLabel = cell.viewWithTag(10) as! UILabel
        
        let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
        
        let channelDetails = channelsDataArray[indexPath.row]
        channelTitleLabel.text = channelDetails["title"] as? String
        
        thumbnailImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (channelDetails["thumbnail"] as? String)!)!)!)
        
        let nativeExpressAdView = cell.viewWithTag(13) as! GADNativeExpressAdView
        nativeExpressAdView.adUnitID = "ca-app-pub-2242167988124353/5892043027"
        nativeExpressAdView.rootViewController = self
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        nativeExpressAdView.loadRequest(request)
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300.0
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedVideoIndex = indexPath.row
        performSegueWithIdentifier("idSeguePlayer", sender: self)
        if (interstitial!.isReady) {
            interstitial!.presentFromRootViewController(self)
        }
        loadInterstitial()
        
    }
    
    
    
    
    //iad
    
    
    
    
    // MARK: UITextFieldDelegate method implementation
    
    
    
    // MARK: Custom method implementation
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
    }
    
    
    func getChannelDetails(useChannelIDParam: Bool) {
        var urlString: String!
        if !useChannelIDParam {
            urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(playlist)&key=\(apikey)"
        }
        
        
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                
                do {
                    // Convert the JSON data to a dictionary.
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all playlist items ("items" array).
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0 ..< items.count {
                        let snippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Get the snippet dictionary that contains the desired data.
                        
                        
                        // Create a new dictionary to store only the values we care about.
                        var desiredValuesDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
                        desiredValuesDict["title"] = snippetDict["title"]
                        
                        desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["high"] as! Dictionary<NSObject, AnyObject>)["url"]
                        desiredValuesDict["videoID"] =  (snippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>) ["videoId"]
                        
                        
                        // Save the channel's uploaded videos playlist ID.
                        
                        
                        
                        // Append the desiredValuesDict dictionary to the following array.
                        self.channelsDataArray.append(desiredValuesDict)
                        
                        
                        // Reload the tableview.
                        self.tblVideos.reloadData()
                        
                        // Load the next channel data (if exist).
                        
                        
                    }
                } catch {
                    print(error)
                }
                
            } else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
            self.viewWait.hidden = true
        })
    }
    
    
    
    
    //inter
    
    private func loadInterstitial() {
        interstitial = DFPInterstitial(adUnitID: "ca-app-pub-2242167988124353/2974640222")
        interstitial!.delegate = self
        
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        interstitial!.loadRequest(DFPRequest())
    }
    
    // MARK: UIAlertViewDelegate implementation
    
  
    
    // MARK: GADInterstitialDelegate implementation
    
    func interstitialDidFailToReceiveAdWithError (
        interstitial: DFPInterstitial,
        error: GADRequestError) {
        print("interstitialDidFailToReceiveAdWithError: %@" + error.localizedDescription)
    }
    
    func interstitialDidDismissScreen (interstitial: GADInterstitial) {
        print("interstitialDidDismissScreen")
        
    }
    
    
    
    
}

