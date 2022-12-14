//
//  PlayerViewController.swift
//  YTDemo
//
//  Created by Gabriel Theodoropoulos on 27/6/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AVFoundation

class PlayerViewController: UIViewController, AVAudioPlayerDelegate  {

    @IBOutlet weak var playerView: YTPlayerView!
    
    var videoID: String!
    var soundFileURLRef: NSURL!
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var banner: GADBannerView!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        playerView.loadWithVideoId(videoID)
        
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        banner.adUnitID = "ca-app-pub-2242167988124353/7544440627"
        banner.rootViewController = self
        banner.loadRequest(GADRequest())
        
        
        //audio 
        
        player?.delegate = self
        player?.prepareToPlay()
        
        
        //
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
        }
        catch {
            // report for an error
            print("Cant play Audio")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
