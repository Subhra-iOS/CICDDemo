//
//  ViewController.swift
//  FriendListDemo
//
//  Created by Subhra Roy on 13/12/21.
//  Comment by new collaborator

import UIKit

private let cellIdentifier = "cell_identifier"

extension UIViewController{
    func getCurrentThread(work: @escaping ()->()){
        if Thread.isMainThread{ work() }
        else{
            DispatchQueue.main.async {
                work()
            }
        }
    }
}

class ViewController: UIViewController {
    
    var viewModel: FriendsViewModel = FriendsViewModel(manager: ServiceManager(url: "https://jsonplaceholder.typicode.com/users"))
    
    var friends: [Friend] = []{
        didSet{
            self.getCurrentThread { [weak self] in
                self?.friendListTable.reloadData()
            }
        }
    }

    let friendListTable: UITableView = {
        let table : UITableView = UITableView(frame: .zero, style: UITableView.Style.plain)
        table.allowsSelection = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadList(for: 3)
    }
    
    private func loadList(for retryCount: Int = 0){
        
        viewModel.load { [weak self] result in
            switch result{
                case .success(let list): self?.friends = list
                case .failure(let error):
                    switch retryCount {
                        case let count where count == 1:
                            self?.show(error)
                        default:
                            self?.loadList(for: retryCount - 1)
                    }
            }
        }
    }
    
    private func show(_ error: ServiceError<ErrorState>) -> Void{
        var errorMessage = ""
        switch error {
            case .failure(let errorType):
                switch errorType {
                    case .invalid: errorMessage = "invalid"
                    case .nodata: errorMessage = "nodata"
                    case .unknown: errorMessage = "unknown"
                }
            case .success: break
        }
        
        let errorAlert = UIAlertController(title: "Alert", message: "\(errorMessage) error", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .destructive) { _ in
            
        }
        errorAlert.addAction(cancel)
        self.present(errorAlert, animated: true) {
            
        }
    }
    
    private func setUpTableView(){
        self.view.addSubview(self.friendListTable)
        self.friendListTable.frame = view.bounds
        self.friendListTable.dataSource = self
        self.friendListTable.delegate = self
        
        self.friendListTable.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

}


extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
        tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if self.friends.count > 0{
            let friend : Friend = self.friends[indexPath.row]
            cell.textLabel?.text = friend.name
            cell.detailTextLabel?.text = friend.email
        }
        return cell
    }
    
}

extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
