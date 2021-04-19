//
//  HeroDetailViewController.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 18/04/21.
//

import UIKit

class HeroDetailViewController: UIViewController {

    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var minMaxAttackLabel: UILabel!
    @IBOutlet weak var armorLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var manaLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var similarHero1ImageView: UIImageView!
    @IBOutlet weak var similarHero2ImageView: UIImageView!
    @IBOutlet weak var similarHero3ImageView: UIImageView!
    @IBOutlet weak var typeImageView: UIImageView!
    
    
    var hero: Hero?
    var similarHeroes: [Hero]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let hero = hero else { return }
        
        self.title = hero.localizedName
        
        if let imageData = hero.imageData {
            heroImageView.image = UIImage(data: imageData)
        }
        nameLabel.text = hero.localizedName
        minMaxAttackLabel.text = "\(hero.baseAttackMin) - \(hero.baseAttackMax)"
        armorLabel.text = "\(hero.baseArmor)"
        speedLabel.text = "\(hero.moveSpeed)"
        manaLabel.text = "\(hero.baseMana)"
        typeLabel.text = "\(hero.primaryAttr)"
        
        var tempRole = ""
        for role in hero.roles {
            tempRole += "\(role), "
        }
        roleLabel.text = String(tempRole.dropLast(2))
        
        typeImageView.image = UIImage(named: "type-\(hero.primaryAttr)")
        
        if let similarHeroes = similarHeroes {
            if similarHeroes.count >= 3 {
                if let imageData = similarHeroes[0].imageData {
                    similarHero1ImageView.image = UIImage(data: imageData)
                }
                if let imageData = similarHeroes[1].imageData {
                    similarHero2ImageView.image = UIImage(data: imageData)
                }
                if let imageData = similarHeroes[2].imageData {
                    similarHero3ImageView.image = UIImage(data: imageData)
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
