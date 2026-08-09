//
//  ProfileItem.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 14/01/1448 AH.
//
import UIKit

enum ProfileItem {
    case lists
    case favorites
    case watchlist
    case logout
    
    var title: String {
        switch self {
        case .lists:
            return "Lists"
        case .favorites:
            return "Favorites"
        case .watchlist:
            return "Watchlist"
        case .logout:
            return "Logout"
        }
    }
    
    var iconName: String {
        switch self {
        case .lists:
            return "list"
        case .favorites:
            return "heart"
        case .watchlist:
            return "bookmark"
        case .logout:
            return "logout"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .logout:
            return .red
        default:
            return .black
        }
    }
    
    var showsArrow: Bool {
        switch self {
        case .logout:
            return false
        default:
            return true
        }
    }
    
    var isSelectable: Bool {
        switch self {
        case .lists:
            return true
        case .favorites, .watchlist, .logout:
            return false
        }
    }
}
