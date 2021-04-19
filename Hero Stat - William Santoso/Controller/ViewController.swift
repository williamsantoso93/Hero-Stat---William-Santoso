//
//  ViewController.swift
//  Hero Stat - William Santoso
//
//  Created by William Santoso on 18/04/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var roleCollectionView: UICollectionView!
    @IBOutlet weak var heroCollectionView:
        UICollectionView!
    
    //MARK: - variabel
    var heroes: [Hero]?
    var filteredHeroes: [Hero]?
    var similarHeroes: [Hero]?
    var heroImageData = [Data]()
    var filteredHeroImageData = [Data]()
    var selectedHero:Hero?
    let roleList = Role.list
    var heroesString = ""
    
    var isLoading = false
    
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
    
    @IBAction func refreshAction(_ sender: Any) {
        load()
    }
    
    func showAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveHeroes(heroes: [Hero]) {
        let jsonData = try! JSONEncoder().encode(heroes)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString)
    }
    
    //MARK: - load data
    func load() {
//        isLoading = true
        Networking.shared.getData(from: "https://api.opendota.com/api/herostats") { (result: Result<[Hero],NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data) :
                    self.heroes = data
                    self.heroImageData.removeAll()
                    
                    for i in 0 ..< (self.heroes?.count ?? 0) {
                        let imageURL = "https://api.opendota.com\(self.heroes?[i].img ?? "")"
                        self.getImageData(urlString: imageURL) { (data) in
                            self.heroes?[i].imageData = data
                            self.heroes?[i].isImageLoaded = true
                            
                            self.filteredHeroes = self.heroes
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.heroCollectionView.reloadData()
                    }
                    
//                    self.isLoading = false
//                    self.showAlert()
                case .failure(let error) :
                    switch error {
                    case .badUrl:
                        print(1)
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
    
    func getImageData(urlString: String, completion: @escaping (Data) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { // execute on main thread
                    completion(data)
                }
            }.resume()
        }
    }
    
    //MARK: - filter hero by role
    func getfilterHeroes(by role: Role) -> [Hero]? {
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
    
    func isMatchRole(_ hero: Hero, with role: Role) -> Bool {
        for heroRole in hero.roles {
            if heroRole == role {
                return true
            }
        }
        
        return false
    }
    
    //MARK: - similar hero by attribute
    func getfilterHeroes(by attr: PrimaryAttr) -> [Hero]? {
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
        if var filteredHeroesByAttr = getfilterHeroes(by: hero.primaryAttr) {
            switch hero.primaryAttr {
            case .agi:
                filteredHeroesByAttr.sort{$0.moveSpeed > $1.moveSpeed}
            case .int:
                filteredHeroesByAttr.sort(by: {$0.baseMana > $1.baseMana})
            case .str:
                filteredHeroesByAttr.sort(by: {$0.baseAttackMax > $1.baseAttackMax})
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
                    let selectedRole = Role(rawValue: roleList[indexPath.row]) ?? .carry
                    filteredHeroes = getfilterHeroes(by: selectedRole)
                }
//                DispatchQueue.main.async {
                    self.heroCollectionView.reloadData()
//                }
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
