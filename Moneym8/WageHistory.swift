// WageHistory.swift
// Moneym8
//
// Created by chase Crummedyo on 03/02/25.
//

import SwiftUI
import SwiftData

@Model
class WageHistory: Codable {
    var id: UUID
    var hourlyWage: Double
    var startDate: Date
    var endDate: Date?  // nil means this is the current wage
    
    enum CodingKeys: String, CodingKey {
        case id
        case hourlyWage
        case startDate
        case endDate
    }
    
    init(id: UUID = UUID(), hourlyWage: Double, startDate: Date, endDate: Date? = nil) {
        self.id = id
        self.hourlyWage = hourlyWage
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // For Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID(uuidString: try container.decode(String.self, forKey: .id)) ?? UUID()
        hourlyWage = try container.decode(Double.self, forKey: .hourlyWage)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(hourlyWage, forKey: .hourlyWage)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
    }
}
