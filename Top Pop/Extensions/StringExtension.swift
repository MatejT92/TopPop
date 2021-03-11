//
//  StringExtension.swift
//  Top Pop
//
//  Created by Matej Terek on 11/03/2021.
//

extension String {
    //Capitalize first letter of string
    func capitalizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

