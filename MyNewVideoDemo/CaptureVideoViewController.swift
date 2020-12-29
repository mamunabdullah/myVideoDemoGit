//
//  CaptureVideoViewController.swift
//  MyNewVideoDemo
//
//  Created by Abdullah Al Mamun on 24/12/20.
//

    import UIKit
    import CameraKit_iOS
    import AVKit

    class CaptureVideoViewController: UIViewController, CKFSessionDelegate{
        
        //data
        var userId = ""
        var decodeId = ""
        var jobId = ""
        var applyId = ""
        var totalQuestion = ""
        var questionSerialNo = ""
        var questionId = "3495"
        var questionText = "What is the difference between UI design and UX design?"
        var questionDuration = "40"
        var formattedDuration = "3600"
        var index = 0
        
        //UI properties
        let session = CKFVideoSession()
        let previewView = CKFPreviewView()
        var backblurPreview = UIView()
        var actionButton = UIButton()
        var questionTitleLabel = UILabel()
        var questionLabel = UILabel()
        var durationLabel = PaddingLabel(withInsets: 4, 4, 16, 16)
        
        var startProcessBackground = UIView()
        var startProcessLabel = UILabel()
        
        
        //    after start inter
        var recordAnimationBackground = UIView()
        var recordAnimationLabel = UILabel()
        
        var timerBackgroundUI = UIView()
        var timerTitleLabel = UILabel()
        var timerDurationLabel = UILabel()
        var timerSlider = UISlider()
        var dIndex: Float = 0.0
        var iIndex: Float = 0.0
        
        var recordDoneBackground = UIView()
        var recordDoneLabel =  UILabel()
        
        var recordUploadingLabel = UILabel()
        
        var nstimer : Timer?
        
        var wentToNextVC = false
        
        func didChangeValue(session: CKFSession, value: Any, key: String) {
            
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            NotificationCenter.default.addObserver(self, selector:#selector(appMovedToBackground), name: .NSExtensionHostDidEnterBackground, object: nil)
            
            formattedDuration = self.questionDuration.replacingOccurrences(of: " Sec", with: "", options: [.regularExpression, .caseInsensitive])
            prepareView()
        }
        
        
        @objc func appMovedToBackground() {
            print("App moved to background!")
            if(nstimer != nil){
                nstimer!.invalidate()
                
            }
            stopVideoRecording()
            wentToNextVC = true
            print("Back to details")
           
        }
        
        override func viewWillDisappear(_ animated: Bool) {
               stopVideoRecording()
           }
        
        func createNavBar(){
            self.title = "Record Answer"
            self.navigationController?.navigationBar.barTintColor = UIColor.blue
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Roboto", size: 18)!]
            
            let backBTN = UIBarButtonItem(image: UIImage(named: "back_arrow_pdf"), style: .plain, target: self, action: #selector(self.goToPreviousView))
            self.navigationItem.leftBarButtonItem  = backBTN
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        @objc func goToPreviousView(){
            if(nstimer != nil){
                nstimer!.invalidate()
            }
            stopVideoRecording()
            wentToNextVC = true
            print("Back to details")
        }
        
        
        func prepareView(){
            //navigation
            self.navigationItem.title = "Record Answer"
            
            // preview
            self.view.addSubview(previewView)
            previewView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                previewView.topAnchor.constraint(equalTo: self.view.topAnchor),
                
            ])
            
            
            previewView.session = session
            previewView.session?.session.sessionPreset = AVCaptureSession.Preset.low
    

            if AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) != nil {
                print("Front camera found")
                session.cameraPosition = .front
            }else{
                print("showing back camera")
                session.cameraPosition = .back
            }
            
            previewView.previewLayer?.videoGravity = .resizeAspectFill
            previewView.session?.start()
            
            
            
            //back blur view
            previewView.addSubview(backblurPreview)
            backblurPreview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                backblurPreview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                backblurPreview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                backblurPreview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                backblurPreview.topAnchor.constraint(equalTo: self.view.topAnchor),
                
            ])
            backblurPreview.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            backblurPreview.isOpaque = false
            
            //Question Title Label
            createQuestionUI()
            
            // start process BTN like UI
            createStartProcessBTNLikeUI()
            
            //duration label
            createDurationUI()
            
            //record animation UI
            createBlinkRecordUI()
            
            //timer slider UI
            createTimerSliderUI()
            
            // done record BTN like UI
            createDoneRecordBTNLikeUI()
            
            // record upload toast like UI
            createRecordUploadingLabelUI()
            
        }
        
        @objc func startProcessTapped(_ sender: UITapGestureRecognizer? = nil){
            postVideoInterviewStartProcessToServer(userId: self.userId, decodeId: self.decodeId, applyId: self.applyId, deviceName: "IOS")
        }
        
        func processStarted(){
            
            self.title = "Recording Question " + questionSerialNo
            //hide start process UI
            startProcessBackground.removeFromSuperview()
            questionTitleLabel.removeFromSuperview()
            questionLabel.removeFromSuperview()
            durationLabel.removeFromSuperview()
            backblurPreview.removeFromSuperview()
            
            //show recording UI
            recordAnimationBackground.isHidden = false
            //  recordDoneBackground.isHidden = false
            timerBackgroundUI.isHidden = false
            
            session.record({ (url) in
                self.recordDoneBackground.isHidden = true
                self.recordUploadingLabel.isHidden = false
                
                print("session.record userdId : \(self.userId)")
                print("session.record decodeId : \(self.decodeId)")
                print("session.record jobId : \(self.jobId)")
                print("session.record applyId : \(self.applyId)")
                print("session.record questionId : \(self.questionId)")
                print("session.record questionSerialNo : \(self.questionSerialNo)")
                print("session.record questionDuration : \(self.formattedDuration)")
                print("session.record videoUrl: \(url)")
                print("session.record wentToNextVC : \(self.wentToNextVC)")
                if(!self.wentToNextVC){
                    self.postSingleVideoToServer(userId: self.userId, decodeId: self.decodeId, jobId: self.jobId, applyId: self.applyId, quesId: self.questionId, duration: self.formattedDuration, questionSerialNo: self.questionSerialNo, videoUrl: url)
                }
                
            }) { (_) in
            }
            
            //start timer
            timerSlider.value = 0.0
            dIndex = Float(formattedDuration)!
            nstimer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerSliderUpdate), userInfo: nil, repeats: true)
            
            
            
        }
        
        @objc func timerSliderUpdate()
        {
            iIndex = Float(timerSlider.value + 1)
            timerSlider.setValue(iIndex, animated: true)
            print("increase index \(iIndex)")
            
            if timerSlider.value > self.timerSlider.maximumValue {
                nstimer!.invalidate()
            }
            
            print("decrease index \(dIndex)")
            
            let seconds: Int = Int(dIndex) % 60
            let minutes: Int = (Int(dIndex) / 60) % 60
            if(minutes <= 0){
                if(seconds>9){
                    timerDurationLabel.text = "00:\(seconds)"
                }else{
                    timerDurationLabel.text = "00:0\(seconds)"
                }
            }else{
                if(seconds>9){
                    timerDurationLabel.text = "0\(minutes):\(seconds)"
                    
                }else{
                    timerDurationLabel.text = "0\(minutes):0\(seconds)"
                }
            }
            
            dIndex = dIndex - 1
            
            if(dIndex < 0.0) {
                dIndex = 0.0
                recordVideoSubmit()
            }
            
            //making done button visible after a while
            if((Float(formattedDuration)!-dIndex) >= (Float(formattedDuration)!/3)  &&  self.recordDoneBackground.isHidden == true){
                self.recordDoneBackground.isHidden = false
            }
            
            
        }
        
        @objc func recordDoneTapped(_ sender: UITapGestureRecognizer? = nil){
            recordVideoSubmit()
        }
        
        func recordVideoSubmit(){
            print("recordVideoSubmit called")
            if(nstimer != nil){
                nstimer!.invalidate()
            }
            print("nstimer Stopped")
            
            timerBackgroundUI.removeFromSuperview()
            recordAnimationBackground.removeFromSuperview()
            stopVideoRecording()
        }
        
        
        func stopVideoRecording(){
            if(session.isRecording){
                session.stopRecording()
            }
            previewView.session?.stop()
        }
        
        func postSingleVideoToServer(userId:String, decodeId:String, jobId:String, applyId:String, quesId:String, duration:String, questionSerialNo:String, videoUrl: URL) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let vIRecordVideoVC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let path:String = videoUrl.path
            vIRecordVideoVC.urlString = path
           self.navigationController?.pushViewController(vIRecordVideoVC, animated: true)
           
        }
        
        func postVideoInterviewStartProcessToServer(userId:String, decodeId:String, applyId:String, deviceName:String) {
            self.processStarted()
            print("post videos")
        }
        

        
        func createQuestionUI(){
            previewView.addSubview(questionTitleLabel)
            questionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                questionTitleLabel.leadingAnchor.constraint(equalTo: self.previewView.leadingAnchor, constant: 16),
                questionTitleLabel.trailingAnchor.constraint(equalTo: self.previewView.trailingAnchor, constant: -16),
                questionTitleLabel.topAnchor.constraint(equalTo: self.previewView.topAnchor, constant: 16)
            ])
            
            questionTitleLabel.textAlignment = .left
            questionTitleLabel.textColor = .white
            questionTitleLabel.font = UIFont(name:"Roboto-Bold",size:18)
            questionTitleLabel.numberOfLines = 0
            questionTitleLabel.lineBreakMode = .byWordWrapping
            questionTitleLabel.sizeToFit()
            questionTitleLabel.text = "Question \(questionSerialNo) of \(totalQuestion)"
            
            
            //question label
            previewView.addSubview(questionLabel)
            questionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                questionLabel.leadingAnchor.constraint(equalTo: self.previewView.leadingAnchor, constant: 16),
                questionLabel.trailingAnchor.constraint(equalTo: self.previewView.trailingAnchor, constant: -16),
                questionLabel.topAnchor.constraint(equalTo: self.questionTitleLabel.bottomAnchor, constant: 8)
            ])
            
            questionLabel.textAlignment = .left
            questionLabel.textColor = .white
            questionLabel.font = UIFont(name:"Roboto",size:16)
            questionLabel.numberOfLines = 0
            questionLabel.lineBreakMode = .byWordWrapping
            questionLabel.sizeToFit()
            questionLabel.text = questionText
            
        }
        
        func createStartProcessBTNLikeUI(){
            previewView.addSubview(startProcessBackground)
            startProcessBackground.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                startProcessBackground.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
                startProcessBackground.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),
                startProcessBackground.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -32),
                startProcessBackground.heightAnchor.constraint(equalToConstant: 50),
            ])
            
            startProcessBackground.layer.cornerRadius = 25
            startProcessBackground.layer.masksToBounds = true
            startProcessBackground.backgroundColor = UIColor.red
            startProcessBackground.isOpaque = false
            
            
            //start process label
            startProcessBackground.addSubview(startProcessLabel)
            startProcessLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                startProcessLabel.centerXAnchor.constraint(equalTo: self.startProcessBackground.centerXAnchor),
                startProcessLabel.centerYAnchor.constraint(equalTo: self.startProcessBackground.centerYAnchor),
                
            ])
            
            startProcessLabel.backgroundColor = UIColor.red
            startProcessLabel.isOpaque = false
            startProcessLabel.textAlignment = .center
            startProcessLabel.textColor = .white
            startProcessLabel.font = UIFont(name:"Roboto-Medium",size:20)
            startProcessLabel.sizeToFit()
            
            //set data
            let attachment: NSTextAttachment = NSTextAttachment()
            attachment.image = UIImage(named: "ic_round_white_double_circle")
            if let image = attachment.image{
                let y = -(startProcessLabel.font.ascender-startProcessLabel.font.capHeight/2-image.size.height/2)
                attachment.bounds = CGRect(x: 0, y: y, width: image.size.width, height: image.size.height).integral
            }
            
            
            let startProcessText = NSMutableAttributedString(string: "")
            startProcessText.append(NSAttributedString(attachment: attachment))
            startProcessText.append(NSMutableAttributedString(string: "   Start Recording"))
            startProcessLabel.attributedText = startProcessText
            
            let startProcessBackgroundTap = UITapGestureRecognizer(target: self, action: #selector(self.startProcessTapped(_:)))
            startProcessBackground.addGestureRecognizer(startProcessBackgroundTap)
        }
        
        func createDurationUI(){
            previewView.addSubview(durationLabel)
            durationLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                durationLabel.bottomAnchor.constraint(equalTo: startProcessBackground.topAnchor, constant: -8),
                durationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                durationLabel.heightAnchor.constraint(equalToConstant: 50),
                
            ])
            
            durationLabel.layer.cornerRadius = 25
            durationLabel.layer.masksToBounds = true
            durationLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            durationLabel.isOpaque = false
            durationLabel.textAlignment = .center
            durationLabel.textColor = .black
            durationLabel.font = UIFont(name:"Roboto-Bold",size:16)
            durationLabel.numberOfLines = 0
            durationLabel.lineBreakMode = .byWordWrapping
            durationLabel.sizeToFit()
            
            //set data
            let attachment: NSTextAttachment = NSTextAttachment()
            attachment.image = UIImage(named: "notificationTime")
            if let image = attachment.image{
                let y = -(durationLabel.font.ascender-durationLabel.font.capHeight/2-image.size.height/2)
                attachment.bounds = CGRect(x: 0, y: y, width: image.size.width, height: image.size.height).integral
            }
            
            let text = NSMutableAttributedString(string: "")
            text.append(NSAttributedString(attachment: attachment))
            let seconds: Int = Int(formattedDuration)! % 60
            let minutes: Int = (Int(formattedDuration)! / 60) % 60
            if(minutes <= 0){
                text.append(NSMutableAttributedString(string: " Time: 00:\(seconds)"))
            }else{
                if(seconds>9){
                    text.append(NSMutableAttributedString(string: " Time: 0\(minutes):\(seconds)"))
                    
                }else{
                    text.append(NSMutableAttributedString(string: " Time: 0\(minutes):0\(seconds)"))
                }
            }
            durationLabel.attributedText = text
        }
        
        func createBlinkRecordUI(){
            
            previewView.addSubview(recordAnimationBackground)
            recordAnimationBackground.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                recordAnimationBackground.leadingAnchor.constraint(equalTo: self.previewView.leadingAnchor, constant: 16),
                recordAnimationBackground.topAnchor.constraint(equalTo: self.previewView.topAnchor, constant: 16),
                recordAnimationBackground.heightAnchor.constraint(equalToConstant: 40),
                recordAnimationBackground.widthAnchor.constraint(equalToConstant: 80),
                
                
            ])
            
            recordAnimationBackground.layer.cornerRadius = 20
            recordAnimationBackground.layer.masksToBounds = true
            recordAnimationBackground.backgroundColor = UIColor.red
            recordAnimationBackground.isOpaque = false
            
            
            //record animation label
            recordAnimationBackground.addSubview(recordAnimationLabel)
            recordAnimationLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                recordAnimationLabel.centerXAnchor.constraint(equalTo: self.recordAnimationBackground.centerXAnchor),
                recordAnimationLabel.centerYAnchor.constraint(equalTo: self.recordAnimationBackground.centerYAnchor),
                
            ])
            
            recordAnimationLabel.backgroundColor = UIColor.red
            recordAnimationLabel.isOpaque = false
            recordAnimationLabel.textAlignment = .center
            recordAnimationLabel.textColor = .white
            recordAnimationLabel.font = UIFont(name:"Roboto-Bold",size:16)
            recordAnimationLabel.numberOfLines = 0
            recordAnimationLabel.lineBreakMode = .byWordWrapping
            recordAnimationLabel.sizeToFit()
            
            recordAnimationLabel.alpha = 0;
            UIView.animate(
                withDuration: 0.5,
                delay: 0.2,
                options: [.curveLinear,.repeat,.autoreverse],
                animations: {
                    self.recordAnimationLabel.alpha = 1
            },
                completion:nil)
            
            //set data
            let attachmentImage: NSTextAttachment = NSTextAttachment()
            attachmentImage.image = UIImage(named: "ic_white_round_icon")
            if let imageRecord = attachmentImage.image{
                let y = -(durationLabel.font.ascender-durationLabel.font.capHeight/2-imageRecord.size.height/2)
                attachmentImage.bounds = CGRect(x: 0, y: y, width: imageRecord.size.width, height: imageRecord.size.height).integral
            }
            
            let textRecord = NSMutableAttributedString(string: "")
            textRecord.append(NSAttributedString(attachment: attachmentImage))
            textRecord.append(NSMutableAttributedString(string: "  REC"))
            
            recordAnimationLabel.attributedText = textRecord
            
            recordAnimationBackground.isHidden = true
            
        }
        
        func createTimerSliderUI(){
            
            //create timer background
            previewView.addSubview(timerBackgroundUI)
            timerBackgroundUI.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                timerBackgroundUI.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: -20),
                timerBackgroundUI.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 20),
                timerBackgroundUI.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0),
                timerBackgroundUI.heightAnchor.constraint(equalToConstant: 50),
            ])
            timerBackgroundUI.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            timerBackgroundUI.isOpaque = false
            
            //Create timer label
            timerBackgroundUI.addSubview(timerTitleLabel)
            timerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                timerTitleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
                timerTitleLabel.centerYAnchor.constraint(equalTo: timerBackgroundUI.centerYAnchor),
                
            ])
            
            timerTitleLabel.textAlignment = .center
            timerTitleLabel.font = UIFont(name: "Roboto-Bold", size:14)
            timerTitleLabel.textColor = UIColor.white
            timerTitleLabel.text = "Time Remaining:"
            
            //create timer duration UI
            timerBackgroundUI.addSubview(timerDurationLabel)
            timerDurationLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                timerDurationLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -8),
                timerDurationLabel.centerYAnchor.constraint(equalTo: timerBackgroundUI.centerYAnchor),
                timerDurationLabel.widthAnchor.constraint(equalToConstant: 50),
            ])
            
            timerDurationLabel.textAlignment = .center
            timerDurationLabel.font = UIFont(name: "Roboto-Bold", size:14)
            timerDurationLabel.textColor = UIColor.white
            timerDurationLabel.text = "00:00"
            
            //Create timer Slider
            timerBackgroundUI.addSubview(timerSlider)
            timerSlider.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                timerSlider.leadingAnchor.constraint(equalTo: timerTitleLabel.trailingAnchor),
                timerSlider.trailingAnchor.constraint(equalTo: timerDurationLabel.leadingAnchor),
                timerSlider.centerYAnchor.constraint(equalTo: timerBackgroundUI.centerYAnchor),
            ])
            
            timerSlider.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            timerSlider.minimumValue = 0
            timerSlider.maximumValue = Float(formattedDuration)!
            timerSlider.isContinuous = true
            timerSlider.tintColor = UIColor.yellow
            
            timerBackgroundUI.isHidden = true
            
        }
        
        
        
        func createDoneRecordBTNLikeUI(){
            previewView.addSubview(recordDoneBackground)
            recordDoneBackground.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                recordDoneBackground.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
                recordDoneBackground.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),
                recordDoneBackground.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -80),
                recordDoneBackground.heightAnchor.constraint(equalToConstant: 50),
            ])
            
            recordDoneBackground.layer.cornerRadius = 25
            recordDoneBackground.layer.masksToBounds = true
            recordDoneBackground.backgroundColor = hexStringToUIColor(hex: "#13A10E")
            recordDoneBackground.isOpaque = false
            
            
            //start process label
            recordDoneBackground.addSubview(recordDoneLabel)
            recordDoneLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                recordDoneLabel.centerXAnchor.constraint(equalTo: self.recordDoneBackground.centerXAnchor),
                recordDoneLabel.centerYAnchor.constraint(equalTo: self.recordDoneBackground.centerYAnchor),
                
            ])
            
            recordDoneLabel.backgroundColor = hexStringToUIColor(hex: "#13A10E")
            recordDoneLabel.isOpaque = false
            recordDoneLabel.textAlignment = .center
            recordDoneLabel.textColor = .white
            recordDoneLabel.font = UIFont(name:"Roboto-Medium",size:20)
            recordDoneLabel.sizeToFit()
            
            //set data
            let attachment: NSTextAttachment = NSTextAttachment()
            attachment.image = UIImage(named: "ic_round_white_correct_green_mark")
            if let image = attachment.image{
                let y = -(startProcessLabel.font.ascender-startProcessLabel.font.capHeight/2-image.size.height/2)
                attachment.bounds = CGRect(x: 0, y: y, width: image.size.width, height: image.size.height).integral
            }
            
            
            let text = NSMutableAttributedString(string: "")
            text.append(NSAttributedString(attachment: attachment))
            text.append(NSMutableAttributedString(string: "   Done"))
            recordDoneLabel.attributedText = text
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.recordDoneTapped(_:)))
            recordDoneBackground.addGestureRecognizer(tap)
            
            recordDoneBackground.isHidden = true
        }
        
        
        func createRecordUploadingLabelUI(){
            previewView.addSubview(recordUploadingLabel)
            recordUploadingLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                recordUploadingLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                recordUploadingLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                recordUploadingLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8),
                recordUploadingLabel.heightAnchor.constraint(equalToConstant: 50),
                
            ])
            
            recordUploadingLabel.layer.cornerRadius = 25
            recordUploadingLabel.layer.masksToBounds = true
            recordUploadingLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            durationLabel.isOpaque = false
            recordUploadingLabel.textAlignment = .center
            recordUploadingLabel.textColor = .white
            recordUploadingLabel.font = UIFont(name:"Roboto",size:16)
            recordUploadingLabel.numberOfLines = 0
            recordUploadingLabel.lineBreakMode = .byWordWrapping
            recordUploadingLabel.sizeToFit()
            
            recordUploadingLabel.text = "Your recorded video is uploading, please wait.."
            
            recordUploadingLabel.isHidden = true
        }
    }


   

extension  CaptureVideoViewController{
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
}

class PaddingLabel: UILabel {
    
    var topInset: CGFloat
    var bottomInset: CGFloat
    var leftInset: CGFloat
    var rightInset: CGFloat
    
    required init(withInsets top: CGFloat, _ bottom: CGFloat,_ left: CGFloat,_ right: CGFloat) {
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}
