 
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Firebase
import FirebaseFirestoreSwift
 

class FireStoreManager {

    var departments = [String]()
    
    public static let shared = FireStoreManager()
  
    var dbRefUsers : CollectionReference!
    var dbReConferences : CollectionReference!
    var db: Firestore!
    let conferenceImagesStorage : StorageReference!
   
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        dbRefUsers = db.collection("Users")
        dbReConferences = db.collection("Conferences")
        conferenceImagesStorage = Storage.storage().reference().child("ConferenceImages")
    }
    
    
    func signUp(userType: UserType,name:String,email:String,password:String) {
       
        self.checkAlreadyExistAndSignup(userType: userType, name: name, email: email.lowercased(), password: password)
    }
    
    func getConferences(completion: @escaping ([ConferencesModel])->()) {
        
        self.dbReConferences.addSnapshotListener { querySnapshot, err in
             
            if let _ = err {
                completion([])
            }else {
                
                var list: [ConferencesModel] = []
                for document in querySnapshot!.documents {
                    do {
                        let data = try document.data(as: ConferencesModel.self)
                        list.append(data)
                    }catch let error {
                        print(error)
                    }
                }
                completion(list)
            }
        }
    }
    
    func getEvents(conferenceId:String,completion: @escaping ([EventModel])->()) {
        
        showLoading()
        
        dbReConferences.document(conferenceId).collection("Events").addSnapshotListener { querySnapshot, err in
       
             hideLoading()
         
            if let _ = err {
                
                 completion([])
            }
            
            
            if let querySnapshot = querySnapshot {
                
                if(querySnapshot.count == 0) {
                    completion([])
                }else {
                    
                    var list: [EventModel] = []
                    
                    for document in querySnapshot.documents {
                        do {
                            let data = try document.data(as: EventModel.self)
                            list.append(data)
                        }catch let error {
                            print(error)
                        }
                    }
                    completion(list)
                }
                
            }else {
                completion([])
            }
            
        }
        
    }
    
    func checkAlreadyExistAndSignup(userType:UserType,name:String,email:String,password:String) {
        
        if(email.lowercased() == Constant.Super_ADMIN_EMAIL) {
            showAlertAnyWhere(message: AlertMessages.EmailAlreadyExist)
            return
        }else {
            
          showLoading()
            
            getQueryFromFirestore(field: "email", compareValue: email) { querySnapshot in
                 
                
                if(querySnapshot.count > 0) {
                    hideLoading()
                    showAlertAnyWhere(message: AlertMessages.EmailAlreadyExist)
                }else {
                    
                    // Signup
                    
                    let data = ["userType" : userType.rawValue,"name":name , "email" : email ,"password" : password]
                    
                    self.addDataToFireStore(data: data) { _ in
                        hideLoading()
                        
                        showOkAlertAnyWhereWithCallBack(message: "Registration Success!!") {
                           
                            SceneDelegate.shared?.checkLogin()
                            
//                            if(userType == .ADMIN) {
//                                SceneDelegate.shared?.checkLogin()
//                            }else {
//                                DispatchQueue.main.async {
//                                    UIApplication.topViewController()!.navigationController?.popViewController(animated: true)
//                                }
//                            }
                            
                        }
                        
                    }
                   
                }
            }
            
        }
        

}

}


extension FireStoreManager {
    
    func login(email:String,password:String) {
        
        showLoading()
        
        getQueryFromFirestore(field: "email", compareValue: email) { querySnapshot in
             hideLoading()
         
            if(querySnapshot.count == 0) {
                showAlertAnyWhere(message: "Email id not found!!")
            }else {
                
                let document = querySnapshot.documents.first!
                
                    if let pwd = document.data()["password"] as? String{
                    
                        if(pwd == password) {
                            
                            let name = document.data()["name"] as? String ?? ""
                            let email = document.data()["email"] as? String ?? ""
                            let userType = document.data()["userType"] as? String ?? ""
                            let documentID = document.documentID
                            
                            UserDefaultsManager.shared.saveData(documentID: documentID, name: name, email: email, userType: userType)

                            SceneDelegate.shared?.checkLogin()
                            
                            
                        }else {
                            showAlertAnyWhere(message: "Password doesn't match")
                        }
                    }
                
            }
         
        }
                   
    }
                
}

extension FireStoreManager {
    
    
    
    func addDataToFireStore(data:[String:Any] ,completionHandler:@escaping (Any) -> Void){
        
        dbRefUsers.addDocument(data: data) { err in
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       completionHandler("success")
        }
     }
    }
    
    
    func getQueryFromFirestore(field:String,compareValue:String,completionHandler:@escaping (QuerySnapshot) -> Void){
         
        dbRefUsers.whereField(field, isEqualTo: compareValue).getDocuments { querySnapshot, err in
            
            if let err = err {
                
                showAlertAnyWhere(message: "Error getting documents: \(err)")
                            return
            }else {
                
                if let querySnapshot = querySnapshot {
                    return completionHandler(querySnapshot)
                }else {
                    showAlertAnyWhere(message: "Something went wrong!!")
                }
               
            }
        }
        
    }
    
    
    
}

extension FireStoreManager {
    
 
    func createEvent(conferenceId:String,eventName:String,eventDescription:String,speaker:String,aboutSpeaker:String,location:String,date:String,time:String,imageUrl:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbReConferences.document(conferenceId).collection("Events").document()
        let autoId = docRef.documentID

        let data = ["conferenceId":conferenceId,"key" : autoId, "eventName":eventName, "eventDescription" : eventDescription,"speaker" :speaker ,"aboutSpeaker" : aboutSpeaker , "location" : location ,  "date" :date, "time" : time , "imageUrl" : imageUrl , "speakerkey" : UserDefaultsManager.shared.getKey() ]
        
        docRef.setData(data){ err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Event added!!") {
                          completion()
                           
                }
        }
      }
    }
    
    func saveConference(name:String,url:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbReConferences.document()
        let autoId = docRef.documentID

        let data = ["key" : autoId, "name":name , "imageUrl" : url]
        
        docRef.setData(data) { err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Conference added!!") {
                          
                          completion()
                           
                }
        }
      }
    }
    
    func saveImage(image: UIImage,completion: @escaping (String)->()) {
        
        showLoading()
        
        let imageName = "\(Int(Date().timeIntervalSince1970)).jpg"
        
        if let data = image.jpegData(compressionQuality: 0.3) {
            let storageRef = Storage.storage().reference().child("images/\(imageName)")
        
            let _ = storageRef.putData(data, metadata: nil) { (metadata, error) in
                hideLoading()
                if let error = error {
                    print(error)
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let _ = error {
                           completion("")
                        } else {
                            print(url!.path)
                            print(url!.description)
                            completion(url!.description)
                        }
                    }
                }
            }
        }
        
    }
}
 
