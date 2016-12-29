//
//  PersonDetailTableViewController.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/29/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Sweeft

class PersonDetailTableViewController: UITableViewController {
    
    var movies = [Movie]()
    var person: Person? {
        didSet {
            title = person?.name
            person >>> **self.tableView.reloadData
            person?.getMovies().onSuccess { movies in
                self.movies = movies
                movies >>> **self.tableView.reloadData
            }
        }
    }
    
    func identifier(for section: Int) -> String {
        switch section {
        case 0:
            return "person"
        default:
            return "movie"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return movies.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Stars in"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier(for: indexPath.section), for: indexPath)
        switch indexPath.section {
        case 0:
            (cell as? PersonTableViewCell)?.person = person
        case 1:
            (cell as? MovieTableViewCell)?.movie = movies | indexPath.row
        default:
            break
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? DetailMovieTableViewController {
            mvc.movie = movies | (tableView.indexPathForSelectedRow?.row).?
        }
    }
    
}
