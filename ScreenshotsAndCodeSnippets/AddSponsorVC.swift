
import UIKit

class AddSponsorVC: UIViewController {

    @IBOutlet weak var sponsor: UITextField!
    @IBOutlet weak var aboutSponsor: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    var photoSelected = false
    var typeSelected = false
    @IBOutlet weak var sponsoTypeButton: UIButton!
    let globalPicker = GlobalPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
    @IBAction func onType(_ sender: Any) {
        openSponsorTypeSelector()
    }
    
    
    func openSponsorTypeSelector() {
        
        self.view.endEditing(true)
        
        globalPicker.stringArray = sponsorTypes
        
        globalPicker.modalPresentationStyle = .overCurrentContext
        
        globalPicker.onDone = { index in
            self.typeSelected = true
            self.sponsoTypeButton.setTitle( sponsorTypes[index], for: .normal)
        }
       
        present(globalPicker, animated: true, completion: nil)
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
    @IBAction func onAddSponsor(_ sender: Any) {
        
        
        self.view.endEditing(true)
        
       
        if(self.sponsor.text!.isEmpty) {
            showAlert(message: "Please enter Sponsor name")
            return
        }
        
        if(self.aboutSponsor.text!.isEmpty) {
            showAlert(message: "Please enter Sponsor details")
            return
        }
        
        if(!typeSelected) {
            showAlert(message: "Please add Sponsor Type")
            return
        }
        
         
        if(!photoSelected) {
            showAlert(message: "Please add Sponsor photo")
            return
        }
        
        
        
        FireStoreManager.shared.saveImage(image: selectedImage.image!) { imageUrl in

            
            print(self.sponsoTypeButton.title(for: .normal)!)
            
            FireStoreManager.shared.addSponsor(name: self.sponsor.text! , details: self.aboutSponsor.text!, type: self.sponsoTypeButton.title(for: .normal)!, url: imageUrl) {
                
                self.navigationController?.popViewController(animated: true)
                
            }

        }
    }
    
    
}
