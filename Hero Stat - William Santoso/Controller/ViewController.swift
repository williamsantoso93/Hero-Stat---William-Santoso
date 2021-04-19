//
//  ViewController.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 18/04/21.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var roleCollectionView: UICollectionView!
    @IBOutlet weak var heroCollectionView: UICollectionView!
    
    //MARK: - variabel
    var heroes: [Hero]?
    var filteredHeroes: [Hero]?
    var similarHeroes: [Hero]?
    var selectedHero:Hero?
    let roleList = Role.list
    var heroesString = ""
    
    //MARK: - Realm Variable
    let realm: Realm = try! Realm()
    var realmHero: Results<HeroData>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //register collection view cell
        roleCollectionView.register(UINib.init(nibName: "RoleCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RoleCardCollectionViewCell")
        heroCollectionView.register(UINib.init(nibName: "HeroCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HeroCardCollectionViewCell")
        
        load()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailHero" {
            let controller = segue.destination as! HeroDetailViewController
            controller.hero = selectedHero
            controller.similarHeroes = similarHeroes
        }
    }
    
    func showAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - load data
    func load() {
        loadDataRealm()
        
        if filteredHeroes ==  nil || filteredHeroes?.count == 0 {
            Networking.shared.getData(from: "https://api.opendota.com/api/herostats") { (result: Result<[Hero],NetworkError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data) :
                        self.heroes = data
                        
                        if !(self.heroes?.isEmpty ?? true) {
                            for i in 0 ..< (self.heroes?.count ?? 0) {
                                let imageURL = "https://api.opendota.com\(self.heroes?[i].img ?? "")"
                                self.getImageData(urlString: imageURL) { (data) in
                                    self.heroes?[i].imageData = data
                                    self.heroes?[i].isImageLoaded = true
                                    
                                    self.filteredHeroes = self.heroes
                                    
                                    DispatchQueue.main.async {
                                        if let hero = self.heroes?[i] {
                                            self.saveToRealm(hero)
                                        }
                                    
                                        self.heroCollectionView.reloadData()
                                    }
                                }
                            }
                        }
                        
                    case .failure(let error) :
                        switch error {
                        case .badUrl:
                            break
                        case .decodingError:
                            self.showAlert(title: "Error", message: "cannot fetch data.")
                        case .noData:
                            self.showAlert(title: "Error", message: "Cannot fetch data. Please check your network connection.")
                        }
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getImageData(urlString: String, completion: @escaping (Data) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
//                DispatchQueue.main.async {
                    completion(data)
//                }
            }.resume()
        }
    }
    
    //MARK: - Realm
    func loadDataRealm() {
        heroes?.removeAll()
        filteredHeroes?.removeAll()
        
        let heroesData = realm.objects(HeroData.self)
        
        var tempHeroes = [Hero]()
        
        for heroData in heroesData {
            var hero = Hero()
            
            hero.id = heroData.id
            hero.localizedName = heroData.localizedName
            hero.primaryAttr = heroData.primaryAttr
            hero.img = heroData.img
            for role in heroData.roles {
                hero.roles.append(role)
            }
            hero.baseHealth = heroData.baseHealth
            hero.baseMana = heroData.baseMana
            hero.baseAttackMin = heroData.baseAttackMin
            hero.baseAttackMax = heroData.baseAttackMax
            hero.moveSpeed = heroData.moveSpeed
            hero.moveSpeed = heroData.moveSpeed
            hero.imageData = heroData.imageData
            hero.isImageLoaded = heroData.isImageLoaded
            
            tempHeroes.append(hero)
        }
        
        heroes = tempHeroes
        filteredHeroes = tempHeroes
        heroCollectionView.reloadData()
    }
    
    func saveToRealm(_ hero: Hero) {
        let heroData = HeroData()
        heroData.id = hero.id
        heroData.localizedName = hero.localizedName
        heroData.primaryAttr = hero.primaryAttr
        heroData.img = hero.img
        for role in hero.roles {
            heroData.roles.append(role)
        }
        heroData.baseHealth = hero.baseHealth
        heroData.baseMana = hero.baseMana
        heroData.baseAttackMin = hero.baseAttackMin
        heroData.baseAttackMax = hero.baseAttackMax
        heroData.moveSpeed = hero.moveSpeed
        heroData.moveSpeed = hero.moveSpeed
        heroData.imageData = hero.imageData ?? Data()
        heroData.isImageLoaded = hero.isImageLoaded
        
        do {
            try realm.write {
                realm.add(heroData)
            }
        } catch {
            print("error save context : \(error)")
        }
    }
    
    //MARK: - filter hero by role
    func getfilterHeroes(by role: String) -> [Hero]? {
        var tempHeroes = [Hero]()
        if let heroes = heroes {
            for hero in heroes {
                if isMatchRole(hero, with: role) {
                    tempHeroes.append(hero)
                }
            }
        }
        if !tempHeroes.isEmpty {
            return tempHeroes
        }
        return nil
    }
    
    func isMatchRole(_ hero: Hero, with role: String) -> Bool {
        for heroRole in hero.roles {
            if heroRole == role {
                return true
            }
        }
        
        return false
    }
    
    //MARK: - similar hero by attribute
    func getfilterHeroes(attr: String) -> [Hero]? {
        var tempHeroes = [Hero]()
        if let heroes = heroes {
            for hero in heroes {
                if hero.primaryAttr == attr {
                    tempHeroes.append(hero)
                }
            }
        }
        
        if !tempHeroes.isEmpty {
            return tempHeroes
        }
        return nil
    }
    
    func getThreeHighestHeroes(from hero: Hero) -> [Hero]? {
        if var filteredHeroesByAttr = getfilterHeroes(attr: hero.primaryAttr) {
            switch hero.primaryAttr {
            case "agi":
                filteredHeroesByAttr.sort{$0.moveSpeed > $1.moveSpeed}
            case "int":
                filteredHeroesByAttr.sort(by: {$0.baseMana > $1.baseMana})
            case "str":
                filteredHeroesByAttr.sort(by: {$0.baseAttackMax > $1.baseAttackMax})
            default:
                break
            }
            var tempHero = [Hero]()
            
            if filteredHeroesByAttr.count >= 3 {
                var index = 0
                while tempHero.count < 3 {
                    if filteredHeroesByAttr[index].id != hero.id {
                        tempHero.append(filteredHeroesByAttr[index])
                    }
                    index += 1
                }
                
                if tempHero.count >= 3 {
                    return tempHero
                }
            }
        }
        
        return nil
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case roleCollectionView:
            return roleList.count
        case heroCollectionView:
            return filteredHeroes?.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tempCell = UICollectionViewCell()
        
        switch collectionView {
        case roleCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoleCardCollectionViewCell", for: indexPath) as! RoleCardCollectionViewCell
            cell.titleLabel.text = roleList[indexPath.row]
            
            return cell
        case heroCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroCardCollectionViewCell", for: indexPath) as! HeroCardCollectionViewCell
            if let hero = filteredHeroes?[indexPath.row] {
                cell.nameLabel.text = hero.localizedName
                if let imageData = hero.imageData {
                    cell.imageView.image = UIImage(data: imageData)
                }
                
                if hero.isImageLoaded {
                    cell.indicatorView.stopAnimating()
                }
            }
            
            return cell
        default:
            return tempCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !(filteredHeroes?.isEmpty ?? true) {
            guard let hero = filteredHeroes?[indexPath.row] else { return }
            switch collectionView {
            case roleCollectionView:
                self.title = roleList[indexPath.row]
                filteredHeroes?.removeAll()
                if roleList[indexPath.row] == "All" {
                    filteredHeroes = heroes
                } else {
                    let selectedRole = roleList[indexPath.row]
                    filteredHeroes = getfilterHeroes(by: selectedRole)
                }
                self.heroCollectionView.reloadData()
            case heroCollectionView:
                selectedHero = hero
                similarHeroes = getThreeHighestHeroes(from: hero)
                if selectedHero?.imageData != nil {
                    performSegue(withIdentifier: "detailHero", sender: self)
                }
            default:
                break
            }
        }
    }
}
