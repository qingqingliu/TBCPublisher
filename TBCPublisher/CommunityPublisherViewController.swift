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

final class CommunityPublisherViewController: UIViewController {
    let publisherHelper: CommunityPublisherHelper
    let conversation: SampleData.Conversation
    lazy var keyboardManager = KeyboardManager()
    let textView: UITextView
    
    init(conversation: SampleData.Conversation) {
        self.textView = UITextView()
        self.textView.textContainer.lineFragmentPadding = 4.0
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        self.conversation = conversation
        self.publisherHelper = CommunityPublisherHelper(inputBarStyle: false, inputTextView: self.textView)
        super.init(nibName: nil, bundle: nil)
        self.publisherHelper.parentController = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.publisherHelper.configureInputBar()
        
        view.backgroundColor = .white
        title = "TBC Community"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        view.addSubview(publisherHelper.inputBar)
        keyboardManager.bind(inputAccessoryView: publisherHelper.inputBar)
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            textView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            textView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: self.publisherHelper.inputBar.topAnchor)
        ])
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.textView.becomeFirstResponder()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}
