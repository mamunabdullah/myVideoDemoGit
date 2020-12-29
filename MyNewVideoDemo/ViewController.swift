//
//  ViewController.swift
//  MyNewVideoDemo
//
//  Created by Abdullah Al Mamun on 24/12/20.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var videoPreviewLayer: UIView!
    var player: AVPlayer!
    var avpController = AVPlayerViewController()
    var activityIndicator = UIActivityIndicatorView()
    var attemptLabel = PaddingLabel(withInsets: 4,4,16,16)
    var recordAgainLabel = PaddingLabel(withInsets: 4,4,4,4)
    
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(urlString != ""){
            playVideoFromLocal(downloadedFilePath: urlString)
            
        }else{
            print("mon chaise")
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func pushAction(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vIRecordVideoVC = storyBoard.instantiateViewController(withIdentifier: "CaptureVideoViewController") as! CaptureVideoViewController
        
        self.navigationController?.pushViewController(vIRecordVideoVC, animated: true)
    }
    
    
    
    func  playVideoFromLocal(downloadedFilePath: String){
        //let urlString = downloadedFilePath
        //let url =  URL(string: urlString)
        
        let urlString = "file://" + downloadedFilePath
        let url =  URL(string: urlString)
        print("playVideoFromLocal URL :\(String(describing: url))")
        
       // print("playVideoFromLocal URL :\(String(describing: url))")
        self.player = AVPlayer(url: url!)
        self.avpController = AVPlayerViewController()
        self.avpController.player = self.player
        self.avpController.view.frame = videoPreviewLayer.frame
        self.addChild(avpController)
        self.view.addSubview(avpController.view)
        self.avpController.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
        self.player.play()
    }
}

