 
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
    var dbSpeakers : CollectionReference!
    var db: Firestore!
    let conferenceImagesStorage : StorageReference!
   
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        dbRefUsers = db.collection("Users")
        dbReConferences = db.collection("Conferences")
        dbSpeakers = db.collection("Speakers")
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
    /*
    func getScheduledEventsAsync(conferenceId: String) async -> [EventModel] {
        let ref = dbReConferences.document(conferenceId).collection("Events")
        
        do {
            let querySnapshot = try await ref.getDocuments()

            var list: [EventModel] = []
            for event in querySnapshot.documents {
                let eventRef = event.reference.collection("Subscriber").whereField("email", isEqualTo: UserDefaultsManager.shared.getEmail().lowercased())
                let eventQuerySnapshot = try await eventRef.getDocuments()
                
                if !eventQuerySnapshot.isEmpty {
                    do {
                        var data = try event.data(as: EventModel.self)
                        data.mySubscribeDocumentID = eventQuerySnapshot.documents.first?.documentID ?? "11"
                        list.append(data)
                    } catch let error {
                        print(error)
                    }
                }
            }
            return list
        } catch let error {
            print(error)
            return []
        }
    }
  */
    
    func getScheduledEvents(conferenceId:String,completion: @escaping ([EventModel])->()) {
        
        let ref = dbReConferences.document(conferenceId).collection("Events")

           ref.getDocuments { (querySnapshot, err) in
               if let _ = err {
                   completion([])
               } else {
                   var list: [EventModel] = []
                   for event in querySnapshot!.documents {
                       let eventRef = event.reference.collection("Subscriber").whereField("email", isEqualTo: UserDefaultsManager.shared.getEmail().lowercased())
                       eventRef.getDocuments { (querySnapshot, error) in
                           if let error = error {
                               print(error)
                           } else {
                               if !querySnapshot!.isEmpty {
                                   do {
                                       var data = try event.data(as: EventModel.self)
                                       data.mySubscribeDocumentID = querySnapshot?.documents.first?.documentID ?? "11"
                                       list.append(data)
                                   } catch let error {
                                       print(error)
                                   }
                               }
                           }
                           completion(list)
                       }
                   }
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
                    
                    let data = ["userType" : userType.rawValue,"name":name , "email" : email ,"password" : password.encrypt()]
                    
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
        
        let password = password.encrypt()
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
    
 
    func createEvent(speakerkey:String,conferenceId:String,eventName:String,eventDescription:String,speaker:String,aboutSpeaker:String,location:String,date:String,time:String,imageUrl:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbReConferences.document(conferenceId).collection("Events").document()
        let autoId = docRef.documentID

        let data = ["conferenceId":conferenceId,"key" : autoId, "eventName":eventName, "eventDescription" : eventDescription,"speaker" :speaker ,"aboutSpeaker" : aboutSpeaker , "location" : location ,  "date" :date, "time" : time , "imageUrl" : imageUrl , "speakerkey" :  speakerkey]
        
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
    
    func addSpeaker(name:String,details:String,url:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbSpeakers.document()
        let autoId = docRef.documentID

        let data = ["key" : autoId, "name":name , "imageUrl" : url , "details" : details]
        
        docRef.setData(data) { err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Speaker added!!") {
                          
                          completion()
                           
                }
        }
      }
    }
    
    func scheduleEvent(event:EventModel) {
        
        showLoading()
        
        let docRef = dbReConferences.document(event.conferenceId).collection("Events").document(event.key).collection("Subscriber")
      
        
        docRef.whereField("email", isEqualTo: UserDefaultsManager.shared.getEmail().lowercased()).getDocuments { (querySnapshot, error) in
            hideLoading()
            
            if let _ = error {
                showAlertAnyWhere(message: "Error getting documents")
            } else {
                if querySnapshot?.isEmpty == false {
                    showAlertAnyWhere(message: "Event Already Scheduled")
                    
                } else {
                    print("Not subscribed")
                    self.subscirbe(docRef: docRef)
                }
            }
        }
    }
    
    func subscirbe(docRef:CollectionReference) {
        
        let data = ["email" : UserDefaultsManager.shared.getEmail().lowercased() , "token" : UserDefaultsManager.shared.getFirebaseToken()]
        
        showLoading()
        
        docRef.addDocument(data: data) { err in
            hideLoading()
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       showAlertAnyWhere(message: "Event added to your schedule list")
            }
        }
    }
    
    func getSpeakers(completion: @escaping ([SpeakersModel])->()) {
        
        self.dbSpeakers.addSnapshotListener { querySnapshot, err in
             
            if let _ = err {
                completion([])
            }else {
                
                var list: [SpeakersModel] = []
                for document in querySnapshot!.documents {
                    do {
                        let data = try document.data(as: SpeakersModel.self)
                        list.append(data)
                    }catch let error {
                        print(error)
                    }
                }
                completion(list)
            }
        }
    }
    
    func getSpeaker(key:String,completion: @escaping ([SpeakersModel])->()) {
        
        showLoading()
        
        let ref = dbSpeakers.document(key)
        
        ref.getDocument { snap, error in
            hideLoading()
           if let _ = error {
                completion([])
            }else {
                
                var list: [SpeakersModel] = []
                 
                    do {
                        let data = try snap!.data(as: SpeakersModel.self)
                        list.append(data)
                    }catch let error {
                        print(error)
                    }
                
                completion(list)
            }
        }
    }
    
    
    func updateEvent(event: EventModel, completion: @escaping (Error?) -> Void) {
      
        showLoading()
        do {
            try dbReConferences.document(event.conferenceId).collection("Events").document(event.key).setData(from: event) { error in
              hideLoading()
            if let error = error {
              completion(error)
            } else {
                showOkAlertAnyWhereWithCallBack(message: "Event Updated") {
                    completion(nil)
                }
            }
          }
        } catch {
          completion(error)
        }
     }
   
    
  
    
    func getSpeakersNoListen(completion: @escaping ([SpeakersModel])->()) {
        showLoading()
        self.dbSpeakers.getDocuments { querySnapshot, err in
         hideLoading()
            if let _ = err {
                completion([])
            }else {
                
                var list: [SpeakersModel] = []
                for document in querySnapshot!.documents {
                    do {
                        let data = try document.data(as: SpeakersModel.self)
                        list.append(data)
                    }catch let error {
                        print(error)
                    }
                }
                completion(list)
            }
        }
    }
    
    func updateConference(key:String,name:String,url:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbReConferences.document(key)
        
        let data = ["key" : key, "name":name , "imageUrl" : url]
        
        docRef.setData(data) { err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Conference Updated!!") {
                          
                          completion()
                           
                }
        }
      }
    }
    
    
    func deleteConference(key:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbReConferences.document(key)
        let eventRef = dbReConferences.document(key).collection("Events")
        
        docRef.delete(){ err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error deleting document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Conference Deleted!!") {
                          
                          completion()
                          eventRef.parent?.delete()
                           
                }
        }
      }
    }
    
    func removeSchedule(event:EventModel, completion: @escaping ()->()) {
        
        showLoading()
       
       let docRef = dbReConferences.document(event.conferenceId).collection("Events").document(event.key).collection("Subscriber").document(event.mySubscribeDocumentID!)
        
        docRef.delete { err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error deleting document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Schedule Deleted!!") {
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
 
