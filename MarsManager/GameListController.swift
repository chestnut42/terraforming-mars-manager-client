//
//  GameListControllerTableViewController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 19/08/2024.
//

import UIKit

struct Game {
    let playUrl: URL
    let playersCount: Int
    let awaitsInput: Bool
}

enum GameListData {
    case Message(String)
    case List([Game])
}

protocol GameViewCellDelegate: AnyObject {
    func playButtonPressed(onCell: GameViewCell)
}

class GameViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var awaitsInputImage: UIImageView!
    
    var data: GameListData?
    weak var delegate: GameViewCellDelegate?
    
    @IBAction func playButtonPressed() {
        if let d = self.delegate {
            d.playButtonPressed(onCell: self)
        }
    }
}

class GameListController: UITableViewController, APIHolder {
    var api: MarsAPIService?
    var data: GameListData = GameListData.Message("loading") {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.data {
        case .Message(_):
            return 1
        case .List(let games):
            return games.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
