//
//  CommunityInputBar.swift
//  Example
//
//  Created by Qingqing Liu on 4/24/20.
//  Copyright © 2020 Nathan Tannar. All rights reserved.
//

import Foundation

import InputBarAccessoryView
import UIKit

protocol CommunityInputBarDelegate: AnyObject {
    func canAddAttachmentToInputBar(inputBar: CommunityInputBar) -> Bool
}

class CommunityInputBar: InputBarAccessoryView {
    weak var attachmentInputDelegate: CommunityInputBarDelegate?
    weak var parentController: UIViewController?
    let inputBarStyle: Bool
    
    init(inputBarStyle: Bool) {
        self.inputBarStyle = inputBarStyle
        super.init(frame: .zero)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        var items = [
            makeButton(named: "ic_at").onSelected {
                self.inputPlugins.forEach { _ = $0.handleInput(of: "@" as AnyObject) }
                $0.tintColor = UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
            },
            makeButton(named: "ic_hashtag").onSelected {
                self.inputPlugins.forEach { _ = $0.handleInput(of: "#" as AnyObject) }
                $0.tintColor = UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
            },
            .flexibleSpace,
            makeButton(named: "ic_library")
                .onSelected {
                    $0.tintColor = UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
                    let canShow = self.attachmentInputDelegate?.canAddAttachmentToInputBar(inputBar: self) ?? true
                    if canShow {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = .photoLibrary
                        self.parentController?.present(imagePicker, animated: true, completion: nil)
                    }
                }
        ]
        if self.inputBarStyle {
            items.append(
                sendButton
                    .configure {
                        $0.layer.cornerRadius = 8
                        $0.layer.borderWidth = 1.5
                        $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                        $0.setTitleColor(.white, for: .normal)
                        $0.setTitleColor(.white, for: .highlighted)
                        $0.setSize(CGSize(width: 52, height: 30), animated: false)
                    }.onDisabled {
                        $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                        $0.backgroundColor = .white
                    }.onEnabled {
                        $0.backgroundColor = UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
                        $0.layer.borderColor = UIColor.clear.cgColor
                    }.onSelected {
                        // We use a transform becuase changing the size would cause the other views to relayout
                        $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    }.onDeselected {
                        $0.transform = CGAffineTransform.identity
                    }
            )
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            items.insert(self.makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
            }.onSelected {
                $0.tintColor = UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
                let canShow = self.attachmentInputDelegate?.canAddAttachmentToInputBar(inputBar: self) ?? true
                if canShow {
                    let imagePicker = UIImagePickerController()
                    
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    self.parentController?.present(imagePicker, animated: true, completion: nil)
                }
            }, at: 0)
        }
        items.forEach { $0.tintColor = .lightGray }
        
        // We can change the container insets if we want
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        rightStackView.alignment = .top
        
        if self.inputBarStyle {
            let maxSizeItem = InputBarButtonItem()
                .configure {
                    $0.image = UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate)
                    $0.tintColor = .darkGray
                    $0.setSize(CGSize(width: 20, height: 20), animated: false)
                }.onSelected {
                    let oldValue = $0.inputBarAccessoryView?.shouldForceTextViewMaxHeight ?? false
                    $0.image = oldValue ? UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "icons8-collapse")?.withRenderingMode(.alwaysTemplate)
                    self.setShouldForceMaxTextViewHeight(to: !oldValue, animated: true)
                }
            setStackViewItems([maxSizeItem], forStack: .right, animated: false)
        } else {
            setStackViewItems([], forStack: .right, animated: false)
        }
        setRightStackViewWidthConstant(to: 20, animated: false)
        if !self.inputBarStyle {
            setMiddleContentView(nil, animated: false)
        }
        
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
                $0.tintColor = UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
    }
}

extension CommunityInputBar: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let info = Dictionary(uniqueKeysWithValues: info.map { key, value in (key.rawValue, value) })
        picker.dismiss(animated: true, completion: {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
                self.inputPlugins.forEach { _ = $0.handleInput(of: pickedImage) }
            }
        })
    }
}
