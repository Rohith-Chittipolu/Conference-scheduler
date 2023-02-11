
import UIKit

class EventDetailsVC: UIViewController {
    
    var event : EventModel!
    
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var speaker: UITextField!
    @IBOutlet weak var aboutSpeaker: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var speakerNameView: DesignableView!
    @IBOutlet weak var speakerDetailsView: DesignableView!
    
    override func viewDidLoad() {
        
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.speakerDetails))
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector(self.speakerDetails))
        self.speakerNameView.addGestureRecognizer(gesture)
        self.speakerDetailsView.addGestureRecognizer(gesture2)
        
    }
    
    @objc func speakerDetails(sender : UITapGestureRecognizer) {
       
        
        let speakerDetailsPopupViewController = SpeakerDetailsPopupViewController()
        speakerDetailsPopupViewController.modalPresentationStyle = .overFullScreen
        speakerDetailsPopupViewController.modalTransitionStyle = .crossDissolve
        present(speakerDetailsPopupViewController, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         
        
        self.eventName.text = event.eventName
        self.eventDescription.text = event.eventDescription
        self.speaker.text = event.speaker
        self.aboutSpeaker.text = event.aboutSpeaker
        self.location.text = event.location
        self.dateTime.text = event.date + " " + event.time
        
        let eventImageUrl = event.imageUrl
        
        if(eventImageUrl.count > 5) {
          
            let imageURL = URL(string: eventImageUrl)
            let imageData = try? Data(contentsOf: imageURL!)
            if let imageData = imageData {
                let image = UIImage(data: imageData)
                self.eventImage.image = image
            }
        }
        
    }
  
    
}

 
