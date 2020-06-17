//
//  CommunityUIHomeViewController.swift
//  TBCPublisher
//
//  Created by Qingqing Liu on 6/17/20.
//  Copyright © 2020 Qingqing Liu. All rights reserved.
//

import UIKit

class CommunityUIHomeViewController: UITableViewController {
    let cellIdentifier = "TestCell"
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier:cellIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Community UI"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = indexPath.row == 0 ? "Reply Style" : "Full Screen"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let convo = SampleData.shared.getConversations(count: 1)[0]
        if indexPath.row == 1 {
            let navController = UINavigationController(rootViewController: CommunityPublisherViewController(conversation: convo))
            present(navController, animated: true, completion: nil)
        } else {
            let vc = CommunityFeedsViewController(conversation: convo)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
