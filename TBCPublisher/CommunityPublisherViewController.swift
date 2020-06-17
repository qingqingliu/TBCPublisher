//
//  FullviewExampleViewController.swift
//  Example
//
//  Created by Qingqing Liu on 4/23/20.
//  Copyright © 2020 Nathan Tannar. All rights reserved.
//

import Foundation
import InputBarAccessoryView
import UIKit

final class CommunityPublisherViewController: CommunityPublisherBaseViewController {
    init(conversation: SampleData.Conversation) {
        super.init(conversation: conversation, inputBarStyle: false)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "TBC Community"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Full Screen", style: .plain, target: self, action: #selector(dismissKeyboard))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        view.addSubview(inputBar)
        keyboardManager.bind(inputAccessoryView: inputBar)
        
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            textView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            textView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: self.inputBar.topAnchor)
        ])
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.textView.becomeFirstResponder()
        }
    }
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}
