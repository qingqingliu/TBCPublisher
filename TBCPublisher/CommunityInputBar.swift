//
//  CommunityInputBar.swift
//  Example
//
//  Created by Qingqing Liu on 4/24/20.
//  Copyright © 2020 Nathan Tannar. All rights reserved.
//

import Foundation


import UIKit
import InputBarAccessoryView

protocol CommunityInputBarDelegate: AnyObject {
    func canAddAttachmentToInputBar(inputBar: CommunityInputBar) -> Bool
}

class CommunityInputBar: InputBarAccessoryView {
    weak var attachmentInputDelegate: CommunityInputBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func configure() {
        var items = [
            makeButton(named: "ic_at").onSelected {
                self.inputPlugins.forEach { _ = $0.handleInput(of: "@" as AnyObject) }
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
            },
            makeButton(named: "ic_hashtag").onSelected {
                self.inputPlugins.forEach { _ = $0.handleInput(of: "#" as AnyObject) }
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
            },
            .flexibleSpace,
            makeButton(named: "ic_library")
                .onSelected {
                    $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                    let canShow = self.attachmentInputDelegate?.canAddAttachmentToInputBar(inputBar: self) ?? true
                    if (canShow) {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = .photoLibrary
                        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
                    }
            }
        ]
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            items.insert(makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
                }.onSelected {
                    $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
                    let canShow = self.attachmentInputDelegate?.canAddAttachmentToInputBar(inputBar: self) ?? true
                    if (canShow) {
                        let imagePicker = UIImagePickerController()
                        
                        imagePicker.delegate = self
                        imagePicker.sourceType = .camera
                        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
                    }
            }, at: 0)
        }
        items.forEach { $0.tintColor = .lightGray }
        
        // We can change the container insets if we want
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        rightStackView.alignment = .top
        setStackViewItems([], forStack: .right, animated: false)
        setRightStackViewWidthConstant(to: 20, animated: false)
        setMiddleContentView(nil, animated: false)
        
        // Finally set the items
        setStackViewItems(items, forStack: .bottom, animated: false)
    }
    

    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
    }
    
}

extension CommunityInputBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info =  Dictionary(uniqueKeysWithValues: info.map { key, value in (key.rawValue, value) })
        picker.dismiss(animated: true, completion: {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
                self.inputPlugins.forEach { _ = $0.handleInput(of: pickedImage) }
            }
        })
    }
}
