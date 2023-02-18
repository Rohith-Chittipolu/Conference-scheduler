 
import UIKit

class SponsorsVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    let sponsorTypes = ["Diamond Sponsors", "Gold Sponsors", "Silver Sponsors"]
    
    
    let sponsorNames =    [["Name 1", "Name 2", "Name 3"],
                           ["Name 4", "Name 5", "Name 6"],
                           ["Name 7", "Name 8", "Name 9"]]
    
    let sponsorDetails = [["Details 1", "Details 2", "Details 3"],
                           ["Details 4", "Details 5", "Details 6"],
                           ["Details 7", "Details 8", "Details 9"]]
     
    override func viewDidLoad() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.registerCells([SponsorCell.self])
            
        tableView.backgroundView = nil
    }
    

}


extension SponsorsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return sponsorTypes.count
       }
       
       func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           return sponsorTypes[section]
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return sponsorNames[section].count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "SponsorCell", for: indexPath) as! SponsorCell
           cell.sponsorName?.text = sponsorNames[indexPath.section][indexPath.row]
           cell.sponsorDetails?.text = sponsorDetails[indexPath.section][indexPath.row]
           return cell
       }
    
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            guard let header = view as? UITableViewHeaderFooterView else { return }
            header.backgroundView?.backgroundColor = AppColors.primary
            header.textLabel?.font = UIFont.systemFont(ofSize: 18)
        }
    
}
