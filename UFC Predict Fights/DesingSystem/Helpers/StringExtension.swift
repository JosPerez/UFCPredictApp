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
    
    var shortName: String {
        let parts = self.split(separator: " ")
        guard parts.count > 1 else { return self }
        // "Islam Makhachev" → "I. Makhachev" if too long, else full name
        let full = self
        if full.count <= 20 { return full }
        return "\(parts.first!.prefix(1)). \(parts.last!)"
    }
    var lastName: String {
        let parts = self.split(separator: " ")
        if parts.count > 2 { return String(parts[1]) }
        return parts.count > 1 ? String(parts.last ?? "") : self
    }
}
