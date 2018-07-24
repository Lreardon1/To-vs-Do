//
//  Storyboard+Utility.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/24/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    enum TVDType: String {
        case main
        case login
        
        var filename: String{
            return rawValue.capitalized
        }
    }
    
    convenience init(type: TVDType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }

    static func initialViewController(for type: TVDType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate initial view controller for \(type.filename) storyboard.")
        }

        return initialViewController
    }
}
