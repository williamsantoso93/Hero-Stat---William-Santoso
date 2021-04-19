//
//  RealmModel.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 19/04/21.
//

import Foundation
import RealmSwift

//class HeroData: Object {
//    dynamic var hero: Hero
//
//    init(hero: Hero) {
//        self.hero = hero
//    }
//}
//
//class ComicBook: Object {
//    @objc dynamic var title = ""
//    @objc dynamic var character = ""
//    @objc dynamic var issue = 0
//    var title2 = List<String>()
//}

// MARK: - HeroData
class HeroData: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var localizedName: String = ""
    @objc dynamic var primaryAttr: String = ""
    var roles = List<String>()
    @objc dynamic var img: String = ""
    @objc dynamic var baseHealth: Int = 0
    @objc dynamic var baseMana: Int = 0
    @objc dynamic var baseArmor: Double = 0
    @objc dynamic var baseAttackMin: Int = 0
    @objc dynamic var baseAttackMax: Int = 0
    @objc dynamic var moveSpeed: Int = 0
    @objc dynamic var imageData: Data = Data()
    @objc dynamic var isImageLoaded: Bool = false
}

