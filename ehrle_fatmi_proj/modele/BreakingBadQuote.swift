import Foundation
//
//  BreakingBadQuote.swift
//  ehrle_fatmi_proj
//
//  Created by Valentin Ehrle on 29/05/2026.
//



struct BreakingBadQuote: Codable {
    let quote: String
    let author: String
}

struct BreakingBadResponse: Codable {
    let data: [BreakingBadQuote]
}
