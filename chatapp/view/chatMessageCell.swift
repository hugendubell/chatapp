//
//  chatMessageCell.swift
//  chatapp
//
//  Created by Joey Kraus on 10/08/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit
import  AVFoundation



class chatMessageCell: UICollectionViewCell {
   
    var message:Message?
    var chatLogController: ChatLogController?
    var playerLayer : AVPlayerLayer?
    var player: AVPlayer?
    
    var blackBackgroundView: UIView?
    var startingFrame: CGRect?
    
    
    
    lazy var pausePlayButtonVid: UIButton = {
       let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        button.addTarget(self, action: #selector(handlePauseVid), for: .touchUpInside)
        
        return button
    }()
    
    var isPlaying = false
    
    @objc func handlePauseVid(){
        print("pausing the video")
        
        if isPlaying{
            
            pausePlayButtonVid.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
            
            }else{
            
            pausePlayButtonVid.setImage(UIImage(named: "pause"), for: .normal)
            player?.play()
            
        }
        isPlaying = !isPlaying
        
      }
    
    
    let videoLengthLabel: UILabel = {
       let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .right
        return label
    }()
    
    lazy var videoSlider: UISlider = {
       let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        
        return slider
    }()
    
    //handling the slider
    @objc func handleSliderChange(){
        print(videoSlider.value)
        
        if let duration = player?.currentItem?.duration{
            
         let totalSeconds = CMTimeGetSeconds(duration)
        
        let value = Float64(videoSlider.value) * totalSeconds
        
        let seekTime = CMTime(value: Int64(value), timescale: 1)
        
        player?.seek(to: seekTime, completionHandler: { (completedSeek) in
            
        })
    }
    }
    
    
    let activityIndicatorViewVid: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    let controlsContainerViewVid:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
    
    //this is the waiting bar once we tap play
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        //aiv.startAnimating()
       
        return aiv
    }()
    
    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
  
    
    lazy var playButton : UIButton = {
        let button = UIButton(type: .system)
        //button.setTitle("Play video", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.tintColor = UIColor.white
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(performVideoZoom), for: .touchUpInside)
        return button
    }()
    
    lazy var pauseButton : UIButton = {
        let button = UIButton(type: .system)
        //button.setTitle("Play video", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "pause")
        button.tintColor = UIColor.white
        button.setImage(image, for: .normal)
        button.isHidden = true
        
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    lazy var zoomingImageView: UIImageView = {
        let zooming = UIImageView()
        
        zooming.backgroundColor = UIColor.red
        //this will place the image in the zoomingImageView
       
        zooming.isUserInteractionEnabled = true
        
        return zooming
    }()
    
    
   
    
    /*@objc func handlePlay(){
        //the first will check if message had videoUrl and than casts it in url as NSURL
        if let videoUrlString = message?.videoUrl, let url = NSURL(string: videoUrlString){
            player = AVPlayer(url: url as URL)
            
            
            
             playerLayer = AVPlayerLayer(player: player)
            //now we will see the clip
            playerLayer?.frame = bubbleView.bounds
            //will add the playerlayer into the bubbleView
            bubbleView.layer.addSublayer(playerLayer!)
            
            
            player?.play()
            //causing the spinnig render
            activityIndicatorView.startAnimating()
            //
            playButton.isHidden = true
            //pauseButton.isHidden = false
            
          pauseButton.isHidden = true
            
            print("Attempting to play video")
            
        }
        
        
    }*/
    
        
   
  
    
    @objc func handlePause(){
        
        activityIndicatorView.stopAnimating()
        if isPlaying{
            playButton.isHidden = false
              playButton.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
          
            
            
        }else{
            pauseButton.isHidden = false
             playButton.setImage(UIImage(named: "pause"), for: .normal)
            player?.play()
           
        }
        isPlaying = !isPlaying
       
    }
    //once we scroll the video will stop playing and stop sound too.basically stops any activity
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
        
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "sample text for now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        
        //with this we cannot edit the text
        tv.isEditable = false
        return tv
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    //the partner we are chatting with will show his or hers profileImage
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        //imageView.contentMode = .scaleAspectFill// this will
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        //imageView.contentMode = .scaleAspectFill// this will
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        //in any situation where
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
        
    }()
    @objc func handleZoomTap(tapGesture:UITapGestureRecognizer){
        //if the videoUrl is not nill return witout the function of zoom tap
        if message?.videoUrl != nil{
            
 
    
    performVideoZoom()
            
                return
            
            }
        
            
        
        if let imageView = (tapGesture.view as? UIImageView){
            self.chatLogController?.performZoomInForstartingImageView(startingImageView: imageView)
            
        }
        }
        
    
    
    
    var viewFrame: UIView?
    var viewVid: UIView?
    
    @objc func performVideoZoom(){
        
       print("showing video player animation..")
        if let keyWindow = UIApplication.shared.keyWindow{
            
           
            viewFrame = UIView(frame:keyWindow.frame)
            
            viewFrame?.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            //video aspect of all HD videos
            let height = keyWindow.frame.width * 9 / 16
            let videoPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            viewVid = UIView(frame: videoPlayerFrame)
            
            viewFrame?.addSubview(viewVid!)
            addSubview(controlsContainerViewVid)
            
            setUpPlayerView(play: viewVid!)
           
            viewVid?.backgroundColor = UIColor.black
            
            
            keyWindow.addSubview(viewFrame!)
           
            
            viewFrame?.backgroundColor =  UIColor.black
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.viewVid?.center = keyWindow.center
                self.viewFrame?.frame = keyWindow.frame
                
                
                
                
                self.viewFrame?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissVid)))
                
                
            }) { (completednimation) in
                self.chatLogController?.inputContainerView.alpha = 0
                
            }
        }
        
        
        
    }
    @objc func dismissVid(tapGesture: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            self.viewFrame?.alpha = 0
            self.player?.replaceCurrentItem(with: nil)
            
        }) { (Bool) in
             self.chatLogController?.inputContainerView.alpha = 1
            
        }
        
        
                
                
}
        
            
    var startVid: CGRect?
    private func setUpPlayerView(play: UIView){
       
        
        if let videoUrlString = message?.videoUrl, let url = NSURL(string: videoUrlString){
            
            player = AVPlayer(url: url as URL)
            
            playerLayer = AVPlayerLayer(player: player)
            play.layer.addSublayer(playerLayer!)
            playerLayer!.frame =  play.frame
            
            player?.play()
            
            
            controlsContainerViewVid.frame = play.frame
            play.addSubview(controlsContainerViewVid)
            controlsContainerViewVid.addSubview(activityIndicatorViewVid)
            
            
            activityIndicatorViewVid.centerXAnchor.constraint(equalTo:controlsContainerViewVid.centerXAnchor).isActive = true
            activityIndicatorViewVid.centerYAnchor.constraint(equalTo:controlsContainerViewVid.centerYAnchor).isActive = true
            controlsContainerViewVid.addSubview(pausePlayButtonVid)
            
            pausePlayButtonVid.centerXAnchor.constraint(equalTo:controlsContainerViewVid.centerXAnchor).isActive = true
            pausePlayButtonVid.centerYAnchor.constraint(equalTo:controlsContainerViewVid.centerYAnchor).isActive = true
            
            pausePlayButtonVid.widthAnchor.constraint(equalToConstant: 50).isActive = true
            pausePlayButtonVid.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            controlsContainerViewVid.addSubview(currentTimeLabel)
            currentTimeLabel.leftAnchor.constraint(equalTo: controlsContainerViewVid.leftAnchor).isActive = true
            currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerViewVid.bottomAnchor).isActive = true
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            controlsContainerViewVid.addSubview(videoLengthLabel)
            
            videoLengthLabel.rightAnchor.constraint(equalTo:
                controlsContainerViewVid.rightAnchor,constant: -8).isActive = true
    videoLengthLabel.bottomAnchor.constraint(equalTo:controlsContainerViewVid.bottomAnchor).isActive = true
            videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            
            
            
            controlsContainerViewVid.addSubview(videoSlider)
            videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
            videoSlider.bottomAnchor.constraint(equalTo: controlsContainerViewVid.bottomAnchor).isActive = true
            videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor,constant: 8).isActive = true
            videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
           
            
            
            
            //observer when the video will start moving playing
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            
            let interval = CMTime(value: 1, timescale: 2)
            //tracking the progress of the video
            player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                
                let seconds = CMTimeGetSeconds(progressTime)
                
                let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
                
                let minutesString = String(format: "%02d", Int(seconds / 60))
                
                self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
                
                if let duration = self.player?.currentItem?.duration{
                    let durationSeconds = CMTimeGetSeconds(duration)
                    
                    //move the slideThumb
                    
                    self.videoSlider.value = Float(seconds / durationSeconds)
                    
                    
                }
                
                
                })
            
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath ==  "currentItem.loadedTimeRanges"{
            //once the video will start playing
            activityIndicatorViewVid.stopAnimating()
            controlsContainerViewVid.backgroundColor = .clear
            pausePlayButtonVid.isHidden = false
            isPlaying = true
            
            
            if let duration = player?.currentItem?.duration{
            let seconds = CMTimeGetSeconds(duration)
                
                let secondsText = String(format: "%02d", Int(seconds) % 60)
                let mimutesText = String(format: "%02d", Int(seconds) / 60)
                
                videoLengthLabel.text = "\(mimutesText):\(secondsText)"
            }
        }
        
    }
    
    
    
    func performZoomForVideoTap(startingImageView: UIImageView){
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingImageView)
        //color
        zoomingImageView = UIImageView(frame: startingFrame!)
        
         zoomingImageView.image = startingImageView.image
        
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
       
        
        //the entire page window
        if let keyWindow = UIApplication.shared.keyWindow{
            //setting background to be black
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            //wiil add the blackbaground view to the window
            keyWindow.addSubview(blackBackgroundView!)
            //will add the picture in its size
            keyWindow.addSubview(zoomingImageView)
            
            
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
               
                //math?
                //h2/w1 = h1/w1
                //h2 = h1 / w1* w1
                //this will set the height
                self.blackBackgroundView!.alpha = 1
                //will make hte lower container fade away
               // inputContainerView.alpha = 0
                
                let  height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                self.zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                //this will the zoomingimage in the middle of the window
                self.zoomingImageView.center = keyWindow.center
                
                self.zoomingImageView.addSubview(self.playButton)
                
              
                
            }) { (completed) in
                //zoomOutImageView.removeFromSuperview()
            }
            
            
        }
        
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                //bringing back th input to visible
                //self.inputContainerView.alpha = 1
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.zoomingImageView.isHidden = false
                
            }
            
            
        }
    }
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
      addSubview(bubbleView)
      addSubview(textView)
    addSubview(profileImageView)
        addSubview(zoomingImageView)
        
        zoomingImageView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        bubbleView.addSubview(messageImageView)
        //constraints to place the sent image into the bubbleviews message
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
       messageImageView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        messageImageView.addSubview(pauseButton)
        pauseButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        pauseButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        pauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pauseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        messageImageView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
       
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
       bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -8)
       bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
       
        
        
        
        
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
