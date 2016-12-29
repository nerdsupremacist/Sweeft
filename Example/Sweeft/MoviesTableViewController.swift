//
//  MoviesTableView.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Sweeft

class MoviesTableViewController: UITableViewController {
    
    private enum Constants {
        static let cellIdentifier = "movie"
    }
    
    var movies = [Movie]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        let api = MoviesAPI.shared
        Movie.getAll(using: api, at: .nowPlaying, for: "results").onSuccess { movies in
            self.movies = movies
            movies >>> **self.tableView.reloadData
        }
        .onError { error in
            print(error)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        if let cell = cell as? MovieTableViewCell {
            cell.movie = movies | indexPath.row
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? DetailMovieTableViewController {
            mvc.movie = movies | (tableView.indexPathForSelectedRow?.row).?
        }
    }
    
}
