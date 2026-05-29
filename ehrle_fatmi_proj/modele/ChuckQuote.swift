//
//  ChuckQuote.swift
//  ehrle_fatmi_proj
//
//  Created by Valentin Ehrle on 29/05/2026.
//

class ChuckQuote:Codable {
    let id: String
    let value: String
    let iconUrl: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case value
        case iconUrl = "icon_url"
        case url
    }
}
