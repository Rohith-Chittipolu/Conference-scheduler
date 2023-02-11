
import UIKit

class AddSpeaker: UIViewController {

    @IBOutlet weak var speaker: UITextField!
    @IBOutlet weak var aboutSpeaker: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    var photoSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    @IBAction func onAddSpeaker(_ sender: Any) {
        
        
        self.view.endEditing(true)
        
       
        if(self.speaker.text!.isEmpty) {
            showAlert(message: "Please enter speaker name")
            return
        }
        
        if(self.aboutSpeaker.text!.isEmpty) {
            showAlert(message: "Please enter speaker details")
            return
        }
        
         
        if(!photoSelected) {
            showAlert(message: "Please add speaker photo")
            return
        }
        
        FireStoreManager.shared.saveImage(image: selectedImage.image!) { imageUrl in
             
//            let dateTime = self.dateTime.text!.components(separatedBy: " ")
//
//            let date = dateTime[0]
//            let time = dateTime[1]
//
//            FireStoreManager.shared.createEvent(conferenceId: self.conferenceId, eventName: self.eventName.text!, eventDescription: self.eventDescription.text!, speaker: self.speaker.text!, aboutSpeaker: self.aboutSpeaker.text!, location: self.location.text!, date: date, time: time, imageUrl: imageUrl) {
//                self.dismiss(animated: true)
//            }
            

        }
    }
    
    
}
