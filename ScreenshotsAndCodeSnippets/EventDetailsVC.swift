
import UIKit

class EventDetailsVC: UIViewController {
    
    var event : EventModel!
    
    @IBOutlet weak var survayLink: UILabel!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var speaker: UITextField!
    @IBOutlet weak var aboutSpeaker: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var speakerNameView: DesignableView!
    @IBOutlet weak var speakerDetailsView: DesignableView!
    @IBOutlet weak var editButton: UIButton!
    override func viewDidLoad() {
        
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.speakerDetails))
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector(self.speakerDetails))
        self.speakerNameView.addGestureRecognizer(gesture)
        self.speakerDetailsView.addGestureRecognizer(gesture2)
        
        
        if( UserDefaultsManager.shared.getUserType() == .STUDENT) {
            self.editButton.isHidden = true
        }
        
    }
    
    @IBAction func onLink(_ sender: Any) {
        
        if(self.survayLink.text!.count > 2) {
            
            var newUrl = self.survayLink.text!
            
            if(!self.survayLink!.text!.contains("http")) {
                newUrl = "http://" + self.survayLink!.text!
            }
            
            if let url = URL(string: newUrl),
               let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
               let match = detector.firstMatch(in:newUrl, options: [], range: NSRange(location: 0, length: newUrl.utf16.count)),
               match.range == NSRange(location: 0, length: newUrl.utf16.count)
            {
                // yourText is a valid URL, so you can open it
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else {
                showAlert(message: "Invalid Url")
            }
            
        }
      
    }
    @IBAction func onEdit(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditEventVC") as! EditEventVC
        vc.event = self.event
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        showLoading()
        self.dismiss(animated: true) {
            
            UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
            hideLoading()
        }
    
    }
    @objc func speakerDetails(sender : UITapGestureRecognizer) {
       
        FireStoreManager.shared.getSpeaker(key: event.speakerkey) { speakers in
        
            if(!speakers.isEmpty) {
                
                speakerData =  speakers.first
                let speakerDetailsPopupViewController = SpeakerDetailsPopupViewController()
                speakerDetailsPopupViewController.modalPresentationStyle = .overFullScreen
                speakerDetailsPopupViewController.modalTransitionStyle = .crossDissolve
                self.present(speakerDetailsPopupViewController, animated: true, completion: nil)
            }
        }
        
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         
        
        self.eventName.text = event.eventName
        self.eventDescription.text = event.eventDescription
        self.speaker.text = event.speaker
        self.aboutSpeaker.text = event.aboutSpeaker
        self.location.text = event.location
        self.dateTime.text = event.date + " " + event.time
        self.survayLink.text = event.surveyLink
        let eventImageUrl = event.imageUrl
        
        if let imageURL = URL(string: eventImageUrl), eventImageUrl.count > 5 {
            let session = URLSession.shared
            let task = session.dataTask(with: imageURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.eventImage.image = image
                    }
                }
            }
            task.resume()
        }

        
    }
  
    
}

 
