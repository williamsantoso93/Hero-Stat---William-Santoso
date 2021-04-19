//
//  DetailHeroViewController.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 18/04/21.
//

import UIKit

class DetailHeroViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let hero = hero else { return }
        
        self.title = hero.localizedName
        
//        let urlImage = URL(string: "https://api.opendota.com\(hero.img)")!
//        heroImageView.load(url: urlImage)
        if let imageData = hero.imageData {
            heroImageView.image = UIImage(data: imageData)
            
            similarHero1ImageView.image = UIImage(data: imageData)
            similarHero2ImageView.image = UIImage(data: imageData)
            similarHero3ImageView.image = UIImage(data: imageData)
        }
        nameLabel.text = hero.localizedName
        minMaxAttackLabel.text = "\(hero.baseAttackMin) - \(hero.baseAttackMax)"
        armorLabel.text = "\(hero.baseArmor)"
        speedLabel.text = "\(hero.moveSpeed)"
        manaLabel.text = "\(hero.baseMana)"
        typeLabel.text = "\(hero.attackType.rawValue)"
        
        var tempRole = ""
        for role in hero.roles {
            tempRole += "\(role.rawValue), "
        }
        roleLabel.text = String(tempRole.dropLast(2))
        
        typeImageView.image = UIImage(named: "type-\(hero.primaryAttr.rawValue)")
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
