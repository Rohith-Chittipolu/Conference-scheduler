import Foundation
import FirebaseFirestoreSwift

struct ConferencesModel: Codable {
    
    var name, key, imageUrl: String
    
}

 
struct SpeakersModel: Codable {
    
    var name, key,details,imageUrl: String
    
}

struct SponsorModel: Codable {
    
    var name,type, key,details,imageUrl: String
    
}



 
struct EventModel: Codable {
    
    var surveyLink,type,eventName,aboutSpeaker, date,eventDescription,imageUrl,location , speaker, speakerkey ,conferenceId, time,key:String
    
    var mySubscribeDocumentID: String?
}

 
