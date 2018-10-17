//
//  PostTableViewController.swift
//  WhyiOS
//
//  Created by Kaden Staker on 10/17/18.
//  Copyright © 2018 Kaden Staker. All rights reserved.
//

import UIKit

class PostTableViewController: UITableViewController {
    
    var fetchedPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func refresh() {
        PostController.getPosts { (posts) in
            guard let posts = posts else { return }
            self.fetchedPosts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        refresh()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentReasonAlert()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = fetchedPosts[indexPath.row]
        cell.textLabel?.text = "\(post.name) - \(post.cohort)"
        cell.detailTextLabel?.text = post.reason
        return cell
    }
}

// MARK: - Alerts
extension PostTableViewController {
    func presentReasonAlert() {
        var nameTextFieldForReason: UITextField?
        var reasonTextFieldForReason: UITextField?
        var cohortTextFieldForReason: UITextField?
        
        let reasonAlert = UIAlertController(title: "Why did you choose iOS?", message: "Enter your reason below", preferredStyle: .alert)
        
        reasonAlert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Enter your name"
            nameTextFieldForReason = nameTextField
        }
        reasonAlert.addTextField { (cohortTextField) in
            cohortTextField.placeholder = "Enter your cohort"
            cohortTextFieldForReason = cohortTextField
        }
        reasonAlert.addTextField { (reasonTextField) in
            reasonTextField.placeholder = "Enter your reason"
            reasonTextFieldForReason = reasonTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addReasonAction = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let name = nameTextFieldForReason?.text,
                let reason = reasonTextFieldForReason?.text,
                let cohort = cohortTextFieldForReason?.text
                else { return }
            PostController.postReason(name: name, cohort: cohort, reason: reason, completion: { (post) in
                if post != nil {
                    DispatchQueue.main.async {
                        self.refresh()
                    }
                } else {
                    print("Error posting reason.")
                }
            })
        }
        reasonAlert.addAction(cancelAction)
        reasonAlert.addAction(addReasonAction)
        present(reasonAlert, animated: true)
    }
}
