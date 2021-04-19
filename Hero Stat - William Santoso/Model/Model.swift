//
//  Model.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 18/04/21.
//

import Foundation
import RealmSwift

// MARK: - Hero
struct Hero: Codable {
    var id: Int = Int()
    var localizedName: String = String()
    var primaryAttr: String = String()
    var roles: [String] = [String]()
    var img: String = String()
    var baseHealth: Int = Int()
    var baseMana: Int = Int()
    var baseArmor: Double = Double()
    var baseAttackMin: Int = Int()
    var baseAttackMax: Int = Int()
    var moveSpeed: Int = Int()
    var imageData: Data? = Data()
    var isImageLoaded: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case localizedName = "localized_name"
        case primaryAttr = "primary_attr"
        case roles, img
        case baseHealth = "base_health"
        case baseMana = "base_mana"
        case baseArmor = "base_armor"
        case baseAttackMin = "base_attack_min"
        case baseAttackMax = "base_attack_max"
        case moveSpeed = "move_speed"
    }
}

enum Role: String, Codable, CaseIterable {
    case carry = "Carry"
    case disabler = "Disabler"
    case durable = "Durable"
    case escape = "Escape"
    case initiator = "Initiator"
    case jungler = "Jungler"
    case nuker = "Nuker"
    case pusher = "Pusher"
    case support = "Support"
    case all = "All"
    
    static var list: [String] {
      return Role.allCases.map { $0.rawValue }
    }
}

