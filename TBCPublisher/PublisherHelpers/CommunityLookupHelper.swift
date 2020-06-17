//
//  CommunityLookupHelper.swift
//  TBCPublisher
//
//  Created by Qingqing Liu on 6/17/20.
//  Copyright © 2020 Qingqing Liu. All rights reserved.
//

import Foundation
import InputBarAccessoryView

struct CommunityUserLookupHelper {
    var getUsers : () -> [AutocompleteCompletion] = autoCompleteOnUser
}

private func autoCompleteOnUser() -> [AutocompleteCompletion] {
    let conversation = SampleData.shared.getConversations(count: 1)[0]
    return conversation.users
    .filter { $0.name != SampleData.shared.currentUser.name }
    .map { user in
        AutocompleteCompletion(text: user.name,
                               context: ["id": user.id])
    }
}
