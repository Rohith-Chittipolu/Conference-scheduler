 
 
import UIKit

class EditEventVC: UIViewController {
    
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
    let globalPicker = GlobalPicker()
    var dateSelected = false
    var data = [SpeakersModel]()
    var selectedSpaker : SpeakersModel!
  
    
    @IBOutlet weak var editButton: UIButton!
    override func viewDidLoad() {
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.speakerDetails))
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector(self.speakerDetails))
        self.speakerNameView.addGestureRecognizer(gesture)
        self.speakerDetailsView.addGestureRecognizer(gesture2)
        
    }
    
    
    @IBAction func onDateAndTime(_ sender: Any) {
        
        let vc = GlobalDatePickerVC(nibName: "GlobalDatePickerVC", bundle: nil)
          vc.isModalInPresentation = true
        self.present(vc, animated: true, completion: nil)
        vc.modalPresentationStyle = .overCurrentContext
        vc.completionHandler = { [self] date,selectedDate in
            dateTime.text = selectedDate
            let dateTime = self.dateTime.text!.components(separatedBy: " ")
            let date = dateTime[0]
            let time = dateTime[1]
            self.event.date = date
            self.event.time = time
        }
        
    }
    
    
    @IBAction func onEditSpeaker(_ sender: Any) {
    
       
        self.view.endEditing(true)
        
        FireStoreManager.shared.getSpeakersNoListen { speakers in
            self.data = speakers
            self.openSpeakerSelector()
            
        }
        
    }
    
    func openSpeakerSelector() {
        
        globalPicker.stringArray = self.data.map{$0.name}
        
        globalPicker.modalPresentationStyle = .overCurrentContext
        
        globalPicker.onDone = { index in
            let data =  self.data[index]
            self.speaker.text = data.name
            self.aboutSpeaker.text = data.details
            self.selectedSpaker = data
            self.event.speakerkey = data.key
            self.event.speaker = data.name
            self.event.aboutSpeaker = data.details
        }
       
        present(globalPicker, animated: true, completion: nil)
    }
    
 
    @IBAction func onSave(_ sender: Any) {
      
        self.view.endEditing(true)
        
        if(self.eventName.text!.isEmpty) {
            showAlert(message: "Please enter event name")
            return
        }
        
        if(self.eventDescription.text!.isEmpty) {
            showAlert(message: "Please enter event description")
            return
        }
        
        if(self.speaker.text!.isEmpty) {
            showAlert(message: "Please enter speaker name")
            return
        }
        
        if(self.aboutSpeaker.text!.isEmpty) {
            showAlert(message: "Please enter speaker details")
            return
        }
        
        if(self.location.text!.isEmpty) {
            showAlert(message: "Please enter event location")
            return
        }
        
      
        
        self.event.eventName = self.eventName.text!
        self.event.eventDescription = self.eventDescription.text!
        self.event.location = location.text!
        
        
        
            FireStoreManager.shared.updateEvent(event: self.event) { error in
                 
                self.dismiss(animated: true)
            }
     
            
        
//            FireStoreManager.shared.saveImage(image: selectedImage.image!) { imageUrl in
//
//                let dateTime = self.dateTime.text!.components(separatedBy: " ")
//
//                let date = dateTime[0]
//                let time = dateTime[1]
//
//                FireStoreManager.shared.createEvent(speakerkey: self.selectedSpaker.key, conferenceId: self.conferenceId, eventName: self.eventName.text!, eventDescription: self.eventDescription.text!, speaker: self.speaker.text!, aboutSpeaker: self.aboutSpeaker.text!, location: self.location.text!, date: date, time: time, imageUrl: imageUrl) {
//                    self.dismiss(animated: true)
//                }
//            }
     
    
        
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
        
        let eventImageUrl = event.imageUrl
        
       
            if let imageURL = URL(string:  eventImageUrl),  eventImageUrl.count > 5 {
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
  
    
    @IBAction func onDeleteEvent(_ sender: Any) {
        
        
        let confKey =  event.conferenceId
        let key =  event.key
        
        showConfirmationAlert(message: "Are you sure you want to delete?", yesHandler: { [weak self] _ in
            
            FireStoreManager.shared.deleteEvent(confKey: confKey, eventKey: key) {
                self?.dismiss(animated: true, completion: nil)
            }
            
        })
    
    }
    
}
