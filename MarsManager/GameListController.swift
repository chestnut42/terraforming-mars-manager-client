//
//  GameListControllerTableViewController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 19/08/2024.
//

import UIKit
import os

enum GameListData {
    case Message(String)
    case List([Game])
}

protocol GameViewCellDelegate: AnyObject {
    func playButtonPressed(on cell: GameViewCell)
}

class GameViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var awaitsInputImage: UIImageView!
    
    var game: Game?
    weak var delegate: GameViewCellDelegate?
    
    @IBAction func playButtonPressed() {
        if let d = self.delegate {
            d.playButtonPressed(on: self)
        }
    }
}

class GameListController: UITableViewController, APIHolder, GameViewCellDelegate {
    var api: MarsAPIService?
    var data: GameListData = GameListData.Message("loading") {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: GameListController.self)
    )
    
    func playButtonPressed(on cell: GameViewCell) {
        if let url = cell.game?.playURL {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - View Controller cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let api = self.api else {
            return
        }
        
        self.data = GameListData.Message("loading")
        
        Task {
            do {
                let games = try await api.getGames()
                if games.games.count > 0 {
                    self.data = GameListData.List(games.games)
                } else {
                    self.data = GameListData.Message("you have no games")
                }
            } catch let error {
                logger.error("error loading: \(error.localizedDescription)")
                self.data = GameListData.Message("error: \(error.localizedDescription)")
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCellID", for: indexPath)

        if let gameCell = cell as? GameViewCell {
            gameCell.delegate = self
            
            switch self.data {
            case .Message(let msg):
                gameCell.game = nil
                gameCell.label.text = msg
                gameCell.awaitsInputImage.isHidden = true
            case .List(let games):
                let g = games[indexPath.row]
                gameCell.game = g
                gameCell.label.text = "\(g.playersCount) players"
                gameCell.awaitsInputImage.isHidden = !g.awaitsInput
            }
        }

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
