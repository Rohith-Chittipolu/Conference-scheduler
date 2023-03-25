import UIKit


var speakerData : SpeakersModel!


class SpeakerDetailsPopupViewController: UIViewController {
    
    private let speakerImageView: UIImageView = {
           let imageView = UIImageView()
           //imageView.image = UIImage(named: "sample")
           imageView.backgroundColor = .lightGray
           imageView.layer.cornerRadius = 30
           imageView.contentMode = .scaleAspectFill
           imageView.clipsToBounds = true
           return imageView
       }()
    
    private let speakerNameLabel: UILabel = {
        let label = UILabel()
        label.text = speakerData.name
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        return label
    }()
    
    private let speakerDetailsLabel: UILabel = {
        let label = UILabel()
        label.text = speakerData.details
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.layer.cornerRadius = 25
        button.backgroundColor = .lightGray
        button.tintColor = .black
        return button
    }()
    
    @objc func dismissVC() {
           weak var weakSelf = self
           weakSelf?.dismiss(animated: true, completion: nil)
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        closeButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        let stackView = UIStackView(arrangedSubviews: [speakerImageView, speakerNameLabel, speakerDetailsLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.backgroundColor = .clear
       
        speakerImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        speakerImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        speakerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
               stackView.translatesAutoresizingMaskIntoConstraints = false
               stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
               stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
               stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
               
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -22).isActive = true
        closeButton.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
             
               
         setImage()
        }
    
    func setImage() {
        
        if(speakerData.imageUrl.count > 5) {
            
            if let imageURL = URL(string: speakerData.imageUrl){
                 
                let session = URLSession.shared
                let task = session.dataTask(with: imageURL) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.speakerImageView.image = image
                        }
                    }
                }
                task.resume()
                
           }
           
        }
    }
}
