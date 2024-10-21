//
//  LeaderboardController.swift
//  MarsManager
//
//  Created by Andrei on 21/10/2024.
//

import UIKit


class LeaderboardUserCell: UITableViewCell {
    @IBOutlet var nickname: UILabel!
    @IBOutlet var elo: UILabel!
}

class LeaderboardController: UITableViewController, APIHolder {
    var api: MarsAPIService?
    var data: [User]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    private func reloadData() {
        self.data = [User(id: "", nickname: "loading", color: .blue, elo: 0)]
        self.processAsyc {
            guard let api = self.api else {
                throw APIError.undefined(message: "no api object is set")
            }
            
            do {
                self.data = try await api.getLeaderboard()
            } catch let error {
                self.data = [User(id: "", nickname: "error: \(error.localizedDescription)", color: .blue, elo: 0)]
                throw error
            }
        }
    }
    
    
    @objc func appDidBecomeActive(_ notification: Notification) {
        reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardUser", for: indexPath)

        if let userCell = cell as? LeaderboardUserCell {
            guard let u = self.data?[indexPath.row] else {
                return cell
            }
            
            userCell.nickname.text = u.nickname
            userCell.elo.text = "\(u.elo)"
        }

        return cell
    }

}
