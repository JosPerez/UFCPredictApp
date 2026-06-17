//
//  dateFormatters.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import Foundation

extension String {
    func formatEventDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: self) else { return self }
        let output = DateFormatter()
        output.dateFormat = "MMMM d, yyyy"
        return output.string(from: date)
    }
}
