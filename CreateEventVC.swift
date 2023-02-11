
import UIKit

class CreateEventVC: UIViewController {

    var conferenceId = ""
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var speaker: UITextField!
    @IBOutlet weak var aboutSpeaker: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    
    let datePicker = UIDatePicker()
    var photoSelected = false
    var dateSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
 
    @IBAction func onDateAndTime(_ sender: Any) {
        
        let vc = GlobalDatePickerVC(nibName: "GlobalDatePickerVC", bundle: nil)
          vc.isModalInPresentation = true
        self.present(vc, animated: true, completion: nil)
        vc.modalPresentationStyle = .overCurrentContext
        vc.completionHandler = { [self] date,selectedDate in
            dateTime.text = selectedDate
            dateSelected = true
        }
        
    }
 
    @IBAction func onPhoto(_ sender: Any) {
        self.view.endEditing(true)
        let sourceType: UIImagePickerController.SourceType = .photoLibrary

        presentImagePickerController(sourceType: sourceType) { (selectedImage) in
            
            if let image = selectedImage {
                self.selectedImage.image = image
                self.photoSelected = true
            }
        }
    }
    @IBAction func onCreateEvent(_ sender: Any) {
        
        
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
        
        if(!dateSelected) {
            showAlert(message: "Please enter date")
            return
        }
        
        if(!photoSelected) {
            showAlert(message: "Please add event image")
            return
        }
        
        FireStoreManager.shared.saveImage(image: selectedImage.image!) { imageUrl in
             
            let dateTime = self.dateTime.text!.components(separatedBy: " ")
            
            let date = dateTime[0]
            let time = dateTime[1]
            
            FireStoreManager.shared.createEvent(conferenceId: self.conferenceId, eventName: self.eventName.text!, eventDescription: self.eventDescription.text!, speaker: self.speaker.text!, aboutSpeaker: self.aboutSpeaker.text!, location: self.location.text!, date: date, time: time, imageUrl: imageUrl) {
                self.dismiss(animated: true)
            }
            

        }
    }
    
    
}
