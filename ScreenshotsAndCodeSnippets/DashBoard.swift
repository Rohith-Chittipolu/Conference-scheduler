import UIKit


var dashBoard : DashBoard!

let eventTypes = ["KeyNote", "BreakOut"]

class DashBoard: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var noEventImage: UIImageView!
    @IBOutlet weak var noConferenceLabel: UILabel!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventImageView: UIImageView!
    var haveEvents = false
    var conferenceId = ""
    var eventImageUrl = ""
    
    var data = [EventModel]()
    var evets:[[EventModel]] = []
   
    
    @IBOutlet weak var eventName: UILabel!
    
    func showEvents(){
        
        if(haveEvents) {
            
            self.topTitle.isHidden = false
            self.noEventImage.isHidden = true
            noConferenceLabel.isHidden = true
            self.eventView.isHidden = false
            
        }else {
            self.topTitle.isHidden = true
            self.noEventImage.isHidden = false
            noConferenceLabel.isHidden = false
            self.eventView.isHidden = true
        }
    }
     
    
    override func viewDidLoad() {

        dashBoard = self
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        
        if let button = view.viewWithTag(20) as? UIButton {
            button.addTarget(self, action: #selector(addEventButtonClick), for: .touchUpInside)
        }
        
        self.showEvents()
        
        self.tableView.registerCells([EventCell.self])
        
        FireStoreManager.shared.getConferences { confrences in
            
            if(confrences.count == 0) {
                self.haveEvents = false
                self.showEvents()
                self.conferenceId = ""
            }else {
                self.haveEvents = true
                self.showEvents()
                self.eventName.text = confrences.first?.name ?? ""
                self.conferenceId = confrences.first?.key ?? ""
                self.eventImageUrl = confrences.first?.imageUrl ?? ""
                
                if let imageURL = URL(string: self.eventImageUrl), self.eventImageUrl.count > 5 {
                    let session = URLSession.shared
                    let task = session.dataTask(with: imageURL) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.eventImageView.image = image
                            }
                        }
                    }
                    task.resume()
                }
                
                self.getEvents()
                
            }
        }
    }
    
    
    func getEvents() {

        if(conferenceId == "") { // empty list and realaod data
            
            self.evets.removeAll()
            self.tableView.reloadData()
        }else {
            
            
            
            
            FireStoreManager.shared.getEvents(conferenceId: conferenceId) { evets in
                
                self.data = evets
                self.setData()
                self.tableView.reloadData()
            }
        }
        
       
    }
    
    func setData() {
        
        var mData:[[EventModel]] = []
        
        for _ in eventTypes {
            mData.append([])
        } // init data
        
       // mData[0] = self.data.filter{$0.type == "Diamond Sponsor"}
        
        for item in data {
            
            if(item.type.lowercased() == "keynote") {
                mData[0].append(item)
            }
            else {
                mData[1].append(item)
            }
        }
        
        self.evets = mData
    }
    
    @objc func addEventButtonClick() {
       
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "CreateEventVC") as! CreateEventVC
        vc.conferenceId = conferenceId
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
    }

    
    @IBAction func createConfrence(_ sender: Any) {
        
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "CreateConferenceVC") as! CreateConferenceVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
    }

    @IBAction func onConfrenceButton(_ sender: Any) {
        
        
        if(UserDefaultsManager.shared.getUserType() == .ADMIN) {
         let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "EditConferenceVC") as! EditConferenceVC
            vc.conferenceId = self.conferenceId
            vc.eventImageUrl = self.eventImageUrl
            vc.name = self.eventName.text!
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }
    }
}



extension DashBoard: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.evets.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return eventTypes[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = eventTypes[section]
        titleLabel.textColor = AppColors.primary // Set the desired color here
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evets[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: EventCell.self), for: indexPath) as! EventCell
        
        cell.setData(evet: evets[indexPath.section][indexPath.row])

        if(UserDefaultsManager.shared.getUserType() == .STUDENT) {
            cell.addButton.isHidden = false
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: #selector(self.addToSchedule(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
            vc.modalPresentationStyle = .popover
            vc.event = self.evets[indexPath.section][indexPath.row]
          //  vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }
        
    }
    

    
    @objc func addToSchedule(_ sender: UIButton) {
       
        
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
            
            // Get the index path of the cell that contains the button
            guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else {
                return
            }
            
            let section = indexPath.section // section of the button's cell
            let row = indexPath.row 
           
        
         FireStoreManager.shared.scheduleEvent(event: evets[section][row])
    }
    
    
}
