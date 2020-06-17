//
//  CommunityFeedsViewController.swift
//  TBCPublisher
//
//  Created by Qingqing Liu on 6/17/20.
//  Copyright © 2020 Qingqing Liu. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class CommunityFeedsViewController: UIViewController, UITableViewDataSource {
    let publisherHelper: CommunityPublisherHelper
    let cellIdentifier = "Convo"
    let conversation: SampleData.Conversation
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return tableView
    }()


    init(conversation: SampleData.Conversation) {
        self.conversation = conversation
        self.publisherHelper = CommunityPublisherHelper(inputBarStyle: true, inputTextView: nil)
        super.init(nibName: nil, bundle: nil)
        self.publisherHelper.parentController = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        publisherHelper.configureInputBar()
        publisherHelper.inputBar.delegate = self
        view.backgroundColor = .white
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    override var inputAccessoryView: UIView? {
        return publisherHelper.inputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversation.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let message = conversation.messages[indexPath.row]
        cell.textLabel?.text = message.text
        return cell
    }
}


extension CommunityFeedsViewController: InputBarAccessoryViewDelegate {
    
    // MARK: - InputBarAccessoryViewDelegate
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (attributes, range, stop) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        inputBar.inputTextView.text = String()
        
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.invalidatePlugins()
                inputBar.invalidateIntrinsicContentSize()
                
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                
                self?.conversation.messages.append(SampleData.Message(user: SampleData.shared.currentUser, text: text))
                let indexPath = IndexPath(row: (self?.conversation.messages.count ?? 1) - 1, section: 0)
                self?.tableView.insertRows(at: [indexPath], with: .automatic)
                self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // Adjust content insets
        tableView.contentInset.bottom = size.height + 300 // keyboard size estimate
    }
    
}
