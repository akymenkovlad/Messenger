//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Valados on 18.11.2021.
//

import Foundation

enum ProfileViewModelType{
    case info, logout
}

struct ProfileViewModel{
    let viewModelType: ProfileViewModelType
    var title: String
    let handler: (() -> Void)?
}
