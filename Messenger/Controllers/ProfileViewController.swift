//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Valados on 06.11.2021.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage


final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var data = [ProfileViewModel]()
    private var profileObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        startListeningForProfileData()
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        tableView.tableHeaderView = createTableHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(UserDefaults.standard.value(forKey: "name") as! String)
        profileObserver = NotificationCenter.default.addObserver(forName: .profileUpdateNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self]_ in
            guard let strongSelf = self else{
                return
            }
            strongSelf.tableView.tableHeaderView = strongSelf.createTableHeader()
            strongSelf.data.removeAll()
            strongSelf.startListeningForProfileData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(data)
    }
    
    private func startListeningForProfileData(){
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? "No email"
        let name = UserDefaults.standard.value(forKey: "name") as? String ?? "No name"
        print(name)
        if let observer = profileObserver{
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting profile fetch...")
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(name)",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .info, title: "Email: \(email)", handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout,title: "Log Out",handler: {[weak self] in
            
            guard let strongSelf = self else {
                return
                
            }
            let actionSheet = UIAlertController(title: "",
                                                message: "",
                                                preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out",
                                                style: .destructive,
                                                handler: {_ in
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                // Log Out facebook
                FBSDKLoginKit.LoginManager().logOut()
                
                // Google Log out
                GIDSignIn.sharedInstance()?.signOut()
                
                do {
                    try Firebase.Auth.auth().signOut()
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: true)
                    DispatchQueue.main.async {
                        strongSelf.tabBarController?.selectedIndex = 0
                    }
                } catch {
                    print("Failed to log out")
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            strongSelf.present(actionSheet, animated: true)
        }))
        tableView.reloadData()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture_png"
        
        let path = "images/"+filename
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: view.width,
                                              height: 160))
        headerView.backgroundColor = .systemBackground
        let imageView = UIImageView(frame: CGRect(x: (view.width-150)/2,
                                                  y: 5,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.link.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                imageView.sd_setImage(with: nil, placeholderImage: UIImage(systemName: "person"))
                print("failed to get download url: \(error)")
            }
        })
        
        return headerView
    }
}
//MARK: UITableViewDelegate, UITableViewDataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for:indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}
class ProfileTableViewCell: UITableViewCell{
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel){
        textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            textLabel?.textColor = .label
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }
}
