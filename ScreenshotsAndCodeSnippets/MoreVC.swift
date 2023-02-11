 
import UIKit

class MoreVC: UIViewController {

    let data = ["Speakers" , "Maps", "Sponsors" , "About"]
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.registerCells([MoreCell.self])
    }
}



extension MoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: MoreCell.self), for: indexPath) as! MoreCell
        cell.setData(data: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
        let data = self.data[indexPath.row]
        
        if(data == "Speakers") {
            
            let speakerNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpeakerNV") as! UINavigationController
            speakerNavigationController.modalPresentationStyle = .fullScreen
            present(speakerNavigationController, animated: true, completion: nil)
            
        }
        
        if(data == "Maps") {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonVC") as! CommonVC
            vc.modalPresentationStyle = .fullScreen
            vc.imageName = "sampleMap"
            vc.titleString = "Maps"
            self.present(vc, animated: true)
            
        }
        
        if(data == "Sponsors") {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SponsorsVC") as! SponsorsVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
    
        }
        
        if(data == "About") {
            
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonVC") as! CommonVC
            vc.modalPresentationStyle = .fullScreen
            vc.imageName = "sampleAbout"
            vc.titleString = "About"
            self.present(vc, animated: true)
            
        }
         
        
    }
    
}
