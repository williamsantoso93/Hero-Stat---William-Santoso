//
//  Model.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 18/04/21.
//

import Foundation

/*
 "base_attack_min": 23,
 "base_attack_max": 25,
 
 "base_health": 200,
 
 "base_armor": -1,
 
 "base_mana": 75,
 
 "move_speed": 290,
 */
// MARK: - Hero
struct Hero: Codable {
    var id: Int
    var localizedName: String
    var primaryAttr: PrimaryAttr
    var attackType: AttackType
    var roles: [Role]
    var img, icon: String
    var baseHealth: Int
    var baseMana: Int
    var baseArmor: Double
    var baseAttackMin, baseAttackMax: Int
    var moveSpeed: Int
    var imageData: Data?

    enum CodingKeys: String, CodingKey {
        case id
        case localizedName = "localized_name"
        case primaryAttr = "primary_attr"
        case attackType = "attack_type"
        case roles, img, icon
        case baseHealth = "base_health"
        case baseMana = "base_mana"
        case baseArmor = "base_armor"
        case baseAttackMin = "base_attack_min"
        case baseAttackMax = "base_attack_max"
        case moveSpeed = "move_speed"
    }
}

enum AttackType: String, Codable {
    case melee = "Melee"
    case ranged = "Ranged"
}

enum PrimaryAttr: String, Codable {
    case agi = "agi"
    case int = "int"
    case str = "str"
}

enum Role: String, Codable, CaseIterable {
    case all = "All"
    case carry = "Carry"
    case disabler = "Disabler"
    case durable = "Durable"
    case escape = "Escape"
    case initiator = "Initiator"
    case jungler = "Jungler"
    case nuker = "Nuker"
    case pusher = "Pusher"
    case support = "Support"
    
    static var list: [String] {
      return Role.allCases.map { $0.rawValue }
    }
}

