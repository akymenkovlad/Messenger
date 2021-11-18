//
//  Extensions.swift
//  Messenger
//
//  Created by Valados on 06.11.2021.
//

import Foundation
import UIKit

extension UIView{
    
    public var width: CGFloat{
        return frame.size.width
    }
    public var height: CGFloat{
        return frame.size.height
    }
    public var top: CGFloat{
        return frame.origin.y
    }
    public var bottom: CGFloat{
        return frame.size.height + frame.origin.y
    }
    public var left: CGFloat{
        return frame.origin.x
    }
    public var rigth: CGFloat{
        return frame.size.width + frame.origin.x
    }
}
extension Notification.Name{
    ///  Notification when user logs in
    static let didLogInNotificaton = Notification.Name("didLogInNotificaton")
    static let profileUpdateNotification = Notification.Name("profileUpdateNotification")
}
