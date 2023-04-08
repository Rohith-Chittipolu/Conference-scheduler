import Foundation
import UIKit

class Constant {
    
    static let Super_ADMIN_EMAIL = "admin@gmail.com"
    static let Super_ADMIN_PASS =  "admin"
    static let Super_ADMIN_Name =  "Admin"
  
}

class AlertMessages {
    
   static let  WrongPassword = "Please enter correct password"
   static let  EmailAlreadyExist =  "This Email is Already Registerd!!"
    
}

enum UserType:String {
    case ADMIN = "ADMIN"
    case STUDENT = "STUDENT"
    case SUPER_ADMIN = "SUPER_ADMIN"
}



func isValidEmail(testStr:String) -> Bool {
// print("validate calendar: \(testStr)")
let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
return emailTest.evaluate(with: testStr)
}


func showLoading() {
    ProgressHUD.show()
}

func hideLoading() {
    ProgressHUD.dismiss()
}

 
struct AppColors {
    static let primary = UIColor(hexString: "F4B597")
}
