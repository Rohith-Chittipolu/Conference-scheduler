 
import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alreadyHaveAccountLabel = view.viewWithTag(11) as! ClickableLabel
        
        let text = "Don't have an account? SignUp"

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: AppColors.primary, range: NSRange(location: text.count - 7, length: 7))
        alreadyHaveAccountLabel.attributedText = attributedString
        alreadyHaveAccountLabel.isUserInteractionEnabled = true
        alreadyHaveAccountLabel.onClick = {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC") as! CreateStudentAccountVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
         }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        
        let email = email.text!.lowercased()
        
        if( email == Constant.Super_ADMIN_EMAIL) {
            
            if(password.text! != Constant.Super_ADMIN_PASS) {
                self.showAlert(message: AlertMessages.WrongPassword)
            }else {
                
                UserDefaultsManager.shared.saveData(documentID: "Head", name: Constant.Super_ADMIN_Name, email: Constant.Super_ADMIN_EMAIL, userType: UserType.SUPER_ADMIN.rawValue)
                SceneDelegate.shared?.checkLogin()
            }
        }else {

            FireStoreManager.shared.login(email: email, password: self.password.text!)
        }
        
        
              
    }
    

    func showSessionExpireAlert() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showAlert(message:  "Session expired")
        }
        
    }
   
    
}

