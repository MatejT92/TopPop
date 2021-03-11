//
//  IntegerExtension.swift
//  Top Pop
//
//  Created by Matej Terek on 11/03/2021.
//

import UIKit

extension Int{
    //  Convert seconds to format with minutes and second
    func convertToMMSS() -> String{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]
        let formattedString = formatter.string(from: TimeInterval(self))!
        return formattedString
    }

}

