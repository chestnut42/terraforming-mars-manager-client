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
        self.delegate?.playButtonPressed(on: self)
    }
}

protocol CreateGameCellDelegate: AnyObject {
    func createButtonPressed(on cell: CreateGameCell)
}

class CreateGameCell: UITableViewCell {
    @IBOutlet var button: UIButton!
    
    weak var delegate: CreateGameCellDelegate?
    
    @IBAction func createButtonPressed() {
        self.delegate?.createButtonPressed(on: self)
    }
}

class GameListController: UITableViewController, APIHolder, GameViewCellDelegate, CreateGameCellDelegate, CreateGameControllerDelegate {
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
    
    private func getDataDetails() -> (count: Int, allowsCreate: Bool) {
        switch data {
        case .Message(_):
            return (1, false)
        case .List(let games):
            return (games.count, true)
        }
    }
    
    func playButtonPressed(on cell: GameViewCell) {
        if let url = cell.game?.playUrl {
            UIApplication.shared.open(url)
        }
    }
    
    func createButtonPressed(on cell: CreateGameCell) {
        self.performSegue(withIdentifier: "OpenCreateGame", sender: nil)
    }
    
    func gameControllerDidCreateGame(_ controller: CreateGameController) {
        self.dismiss(animated: true)
        Task {
            await reloadData()
        }
    }
    
    private func reloadData() async {
        guard let api = self.api else {
            return
        }
        
        self.data = GameListData.Message("loading")
        do {
            let games = try await api.getGames()
            self.data = GameListData.List(games.games)
        } catch let error {
            logger.error("error loading: \(error.localizedDescription)")
            self.data = GameListData.Message("error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - View Controller cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Task {
            await reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var holder = segue.destination as? APIHolder {
            holder.api = self.api
        }
        if let gameCreate = segue.destination as? CreateGameController {
            gameCreate.delegate = self
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (count, allowsCreate) = getDataDetails()
        if allowsCreate {
            return count + 1
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (count, allowsCreate) = getDataDetails()
        var cellID = "gameCellID"
        if allowsCreate && indexPath.row >= count {
            cellID = "createGame"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

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
        if let createCell = cell as? CreateGameCell {
            createCell.delegate = self
        }

        return cell
    }
}
