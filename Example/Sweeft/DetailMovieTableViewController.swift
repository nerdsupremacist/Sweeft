//
//  DetailMovieController.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/29/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Sweeft

class DetailMovieTableViewController: UITableViewController {
    
    var similar = [Movie]()
    var roles = [Role]()
    var movie: Movie? {
        didSet {
            title = movie?.title
            movie >>> **self.tableView.reloadData
            movie?.getSimilar().onSuccess { movies in
                self.similar = movies
                self.similar >>> **self.tableView.reloadData
            }
            movie?.getRoles().onSuccess { roles in
                self.roles = roles
                self.roles >>> **self.tableView.reloadData
            }
        }
    }
    
    func identifier(for section: Int) -> String {
        switch section {
        case 1:
            return "description"
        case 3:
            return "role"
        default:
            return "movie"
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 1
    }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Description"
        case 2:
            return "Similar Movies"
        case 3:
            return "Starring"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        case 2:
            return similar.count
        case 3:
            return roles.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(for: indexPath.section), for: indexPath)
        switch indexPath.section {
        case 0:
            (cell as? MovieTableViewCell)?.movie = movie
        case 1:
            cell.textLabel?.text = movie?.overview
        case 2:
            (cell as? MovieTableViewCell)?.movie = similar | indexPath.row
        case 3:
            (cell as? RoleTableViewCell)?.role = roles | indexPath.row
        default:
            break
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? DetailMovieTableViewController {
            mvc.movie = similar | (tableView.indexPathForSelectedRow?.row).?
        }
        if let mvc = segue.destination as? PersonDetailTableViewController {
            let role = roles | (tableView.indexPathForSelectedRow?.row).?
            mvc.person = role?.actor
        }
    }
    
}
