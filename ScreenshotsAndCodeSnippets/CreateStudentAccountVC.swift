import UIKit


class CreateStudentAccountVC: UIViewController {
    
    @IBOutlet weak var confirmPass: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    
    override func viewDidLoad() {
       super.viewDidLoad()
       
   }

    @IBAction func onSignup(_ sender: Any) {
        
        
        if(self.validate()) {
            
            FireStoreManager.shared.signUp(userType: .STUDENT, name: self.name.text!, email:  self.email.text!, password: self.pass.text!)
        
        
//        let story = UIStoryboard(name: "Main", bundle:nil)
//        let vc = story.instantiateViewController(withIdentifier: "ConferenceListAdmin") as! ConferenceListAdmin
//        UIApplication.shared.keyWindow!.rootViewController = vc
//        UIApplication.shared.keyWindow!.makeKeyAndVisible()
    }
    
}
    
    func validate() ->Bool {
        
        if(self.name.text!.isEmpty) {
             showAlertAnyWhere(message: "Please enter name.")
            return false
        }
        
        
        if(!isValidEmail(testStr: email.text!)) {
             showAlertAnyWhere(message: "Please enter valid email.")
            return false
        }
        
       
        if(self.pass.text!.isEmpty) {
             showAlertAnyWhere(message: "Please enter password.")
             return false
        }
        
        if(self.pass.text! != self.confirmPass.text!) {
             showAlertAnyWhere(message: "Password doesn't match")
             return false
        }
        
        if(self.pass.text!.count < 4 || self.pass.text!.count > 10 ) {
            
            showAlertAnyWhere(message: "Password  length shoud be 4 to 10")
            return false
        }
        
        if !self.pass.text!.contains(where: { $0.isUppercase }) {
            showAlertAnyWhere(message: "Password should contain at least one uppercase letter.")
            return false
        }
        
        
        
        if !self.pass.text!.hasSpecialCharacters() {
           showAlertAnyWhere(message: "Password should contain at least one special character.")
           return false
       }
        
        return true
    }
}

