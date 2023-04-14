 
import UIKit
import FirebaseFirestore
import FirebaseStorage
import Firebase
import FirebaseFirestoreSwift
import FirebaseMessaging
import UserNotifications

class FireStoreManager {

    var departments = [String]()
    
    public static let shared = FireStoreManager()
  
    var dbRefUsers : CollectionReference!
    var dbReConferences : CollectionReference!
    var dbSpeakers : CollectionReference!
    var dbSponsors : CollectionReference!
    var db: Firestore!
    let conferenceImagesStorage : StorageReference!
   
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        dbRefUsers = db.collection("Users")
        dbReConferences = db.collection("Conferences")
        dbSpeakers = db.collection("Speakers")
        dbSponsors = db.collection("Sponsors")
        conferenceImagesStorage = Storage.storage().reference().child("ConferenceImages")
    }
    
    func subscribeTopic(id:String) {
        Messaging.messaging().subscribe(toTopic: id)
    }
    
    func unSubscribeTopic(id:String) {
        Messaging.messaging().unsubscribe(fromTopic: id)
    }
    
    func signUp(userType: UserType,name:String,email:String,password:String) {
       
        self.checkAlreadyExistAndSignup(userType: userType, name: name, email: email.lowercased(), password: password)
    }
    
    func getConferences(completion: @escaping ([ConferencesModel])->()) {
        
        self.dbReConferences.order(by: "date", descending: true).addSnapshotListener { querySnapshot, err in
       
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
    
 
    func createEvent(speakerkey:String,conferenceId:String,eventName:String,eventDescription:String,speaker:String,aboutSpeaker:String,location:String,date:String,time:String,imageUrl:String,type:String,surveyLink:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbReConferences.document(conferenceId).collection("Events").document()
        let autoId = docRef.documentID
        let data = ["conferenceId":conferenceId,"key" : autoId, "eventName":eventName, "eventDescription" : eventDescription,"speaker" :speaker ,"aboutSpeaker" : aboutSpeaker , "location" : location ,  "date" :date, "time" : time , "imageUrl" : imageUrl , "speakerkey" :  speakerkey, "type":type , "surveyLink" : surveyLink , "eventTime" : FieldValue.serverTimestamp()] as [String : Any]
     
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

        let data = ["key" : autoId, "name":name , "imageUrl" : url, "date" :  FieldValue.serverTimestamp()] as [String : Any]
       
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
    
    func addSponsor(name:String,details:String,type:String,url:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbSponsors.document()
        let autoId = docRef.documentID

        let data = ["key" : autoId, "name":name , "type" : type, "imageUrl" : url , "details" : details]
        
        docRef.setData(data) { err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Sponsor added!!") {
                          
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
                    self.subscirbe(docRef: docRef,eventId:event.key)
                }
            }
        }
    }
    
    func subscirbe(docRef:CollectionReference,eventId:String) {
       
       
        let data = ["email" : UserDefaultsManager.shared.getEmail().lowercased() , "token" : UserDefaultsManager.shared.getFirebaseToken()]
        
        showLoading()
        
        docRef.addDocument(data: data) { err in
            hideLoading()
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       self.subscribeTopic(id: eventId)
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
    
    
    func getSposors(completion: @escaping ([SponsorModel])->()) {
        
        self.dbSponsors.addSnapshotListener { querySnapshot, err in
             
            if let _ = err {
                completion([])
            }else {
                
                var list: [SponsorModel] = []
                for document in querySnapshot!.documents {
                    do {
                        let data = try document.data(as: SponsorModel.self)
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
                self.sendNotification(topic: event.key, title: "Event updated", body: "The event has been updated.", listener: { responseBody, error in
                    if let error = error {
                        // Handle error
                        print("Error: \(error.localizedDescription)")
                    } else if let responseBody = responseBody {
                        // Handle response
                        print("Response: \(responseBody)")
                    }
                })

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
    
    
    func updateProfile(name:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let data = ["name" : name]
        
        dbRefUsers.document(UserDefaultsManager.shared.getKey()).updateData(data) { err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error adding document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Updated!!") {
                          
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
    
    func deleteEvent(confKey:String,eventKey:String,completion: @escaping ()->()) {
        
        showLoading()
        
        let docRef = dbReConferences.document(confKey).collection("Events").document(eventKey)
        
        docRef.delete(){ err in
            
            hideLoading()
            
                   if let err = err {
                       showAlertAnyWhere(message: "Error deleting document: \(err)")
                   } else {
                       showOkAlertAnyWhereWithCallBack(message: "Event Deleted!!") {
                          
                          completion()
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
                       self.unSubscribeTopic(id:event.key)
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
    
    func sendNotification(topic: String, title: String, body: String, listener: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        let apiKey = "AAAAF2z6Hlk:APA91bE6AWbm0V5pUHhPfh-a3NgILaXHbSTbIS8kXMaA9d6RKixZYX954Xp0wmo9SQIR9loYUKzTNvOBcT-IssWrbhSP2FRGhZ8H8rMW_cgoyLczF5XLSgA3_ErEvJAM3gr3x484Awdg"

        var payload = [String: Any]()
        payload["to"] = "/topics/\(topic)"
        payload["notification"] = ["title": title, "body": body]

        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            listener(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize payload"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("key=\(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = payloadData

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse else {
                listener(nil, error)
                return
            }

            if response.statusCode == 200 {
                let responseBody = String(data: data, encoding: .utf8)
                listener(responseBody, nil)
            } else {
                listener(nil, NSError(domain: "", code: response.statusCode, userInfo: nil))
            }
        }
        task.resume()
    }

}
 
