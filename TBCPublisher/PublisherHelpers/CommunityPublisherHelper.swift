//
//  CommunityPublisherHelper.swift
//  TBCPublisher
//
//  Created by Qingqing Liu on 6/17/20.
//  Copyright © 2020 Qingqing Liu. All rights reserved.
//

import InputBarAccessoryView
import UIKit

/// Main helper class for community publisher
class CommunityPublisherHelper: NSObject {
    // MARK: - Properties
    let inputBar: CommunityInputBar
    let textView: UITextView?
    let userLookup: CommunityUserLookupHelper
    
    weak var parentController: UIViewController? {
        didSet {
            inputBar.parentController = self.parentController
        }
    }
    
    /// The object that manages attachments
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    /// The object that manages autocomplete
    lazy var autocompleteManager: CommunityAutoCompletionManager = { [unowned self] in
        let manager = CommunityAutoCompletionManager(for: self.textViewForAutoCompletion())
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
    var hastagAutocompletes: [AutocompleteCompletion] = {
        var array: [AutocompleteCompletion] = []
        for _ in 1...100 {
            array.append(AutocompleteCompletion(text: Lorem.word(), context: nil))
        }
        return array
    }()
    
    // Completions loaded async that get appeneded to local cached completions
    var asyncCompletions: [AutocompleteCompletion] = []
    
    init(inputBarStyle: Bool, inputTextView: UITextView?, userLookup: CommunityUserLookupHelper = CommunityUserLookupHelper()) {
        self.textView = inputTextView
        self.inputBar = CommunityInputBar(inputBarStyle: inputBarStyle)
        self.userLookup = userLookup
        super.init()
        inputBar.attachmentInputDelegate = self
    }
    
    func configureInputBar() {
        // Configure AutocompleteManager
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body),.foregroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1),.backgroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.1)])
        autocompleteManager.register(prefix: "#")
        autocompleteManager.maxSpaceCountDuringCompletion = 1 // Allow for autocompletes with a space
        
        // Set plugins
        inputBar.inputPlugins = [autocompleteManager, attachmentManager]
    }
    
    open func textViewForAutoCompletion() -> UITextView {
        return self.textView ?? inputBar.inputTextView
    }
}

extension CommunityPublisherHelper: AttachmentManagerDelegate {
    // MARK: - AttachmentManagerDelegate
    
    public func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    public func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        inputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    public func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        inputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    public func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        inputBar.sendButton.isEnabled = manager.attachments.count > 0
    }
    
    public func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        let canShow = canAddAttachmentToInputBar(inputBar: inputBar)
        if canShow {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            parentController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    
    public func setAttachmentManager(active: Bool) {
        let topStackView = inputBar.topStackView
        if active, !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active, topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
        inputBar.invalidateIntrinsicContentSize()
    }
}

extension CommunityPublisherHelper: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    // MARK: - AutocompleteManagerDataSource
    
    public func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        if prefix == "@" {
            return userLookup.getUsers()
        } else if prefix == "#" {
            return hastagAutocompletes + asyncCompletions
        }
        return []
    }
    
    public func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        let users = SampleData.shared.users
        let name = session.completion?.text ?? ""
        let user = users.filter { $0.name == name }.first
        cell.imageView?.image = user?.image
        cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15)
        return cell
    }
    
    // MARK: - AutocompleteManagerDelegate
    
    public func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    // Optional
    public func autocompleteManager(_ manager: AutocompleteManager, shouldRegister prefix: String, at range: NSRange) -> Bool {
        return true
    }
    
    // Optional
    public func autocompleteManager(_ manager: AutocompleteManager, shouldUnregister prefix: String) -> Bool {
        return true
    }
    
    // Optional
    public func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        return true
    }
    
    // MARK: - AutocompleteManagerDelegate Helper
    
    public func setAutocompleteManager(active: Bool) {
        let topStackView = inputBar.topStackView
        if active, !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: 0)
            topStackView.layoutIfNeeded()
        } else if !active, topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        inputBar.invalidateIntrinsicContentSize()
    }
}

extension CommunityPublisherHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let info = Dictionary(uniqueKeysWithValues: info.map { key, value in (key.rawValue, value) })
        
        parentController?.dismiss(animated: true, completion: {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
                let handled = self.attachmentManager.handleInput(of: pickedImage)
                if !handled {
                    // throw error
                }
            }
        })
    }
}

extension CommunityPublisherHelper: CommunityInputBarDelegate {
    func canAddAttachmentToInputBar(inputBar: CommunityInputBar) -> Bool {
        // support up to 3 attachment
        attachmentManager.attachments.count < 3
    }
}
