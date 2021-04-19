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
    
    var heroes: [Hero]?
    var filteredHeroes: [Hero]?
    var heroImageData = [Data]()
    var filteredHeroImageData = [Data]()
    var selectedHero:Hero?
    let roleList = Role.list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        image.load(url: URL(string: "https://api.opendota.com/apps/dota2/images/heroes/antimage_full.png?")!)
//        load(url: "https://api.opendota.com/apps/dota2/images/heroes/antimage_full.png?")
//        firstLoad()
        roleCollectionView.register(UINib.init(nibName: "RoleCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RoleCardCollectionViewCell")
        heroCollectionView.register(UINib.init(nibName: "HeroCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HeroCardCollectionViewCell")
        load()
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
    
    func load() {
        Networking.shared.getData(from: "https://api.opendota.com/api/herostats") { (result: Result<[Hero],NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data) :
                    self.heroes = data
                    self.heroImageData.removeAll()
                    
                    for i in 0 ..< (self.heroes?.count ?? 0) {
                        let imageURL = "https://api.opendota.com\(self.heroes?[i].img ?? "")"
                        self.getImageData(urlString: imageURL) { (data) in
                            DispatchQueue.main.async {
                                self.heroes?[i].imageData = data
                                
                                self.filteredHeroes = self.heroes
                                self.heroCollectionView.reloadData()
                            }
                        }
                    }
                case .failure(let error) :
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailHero" {
            let controller = segue.destination as! DetailHeroViewController
            controller.hero = selectedHero
        }
    }
}

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
//                let imageData = filteredHeroImageData[indexPath.row]
                
                cell.imageView.image = UIImage(data: hero.imageData ?? Data())
            }
            
            return cell
        default:
            return tempCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case roleCollectionView:
            print(roleList[indexPath.row])
            heroCollectionView.reloadData()
        case heroCollectionView:
            selectedHero = filteredHeroes?[indexPath.row]
            if selectedHero?.imageData != nil {
                performSegue(withIdentifier: "detailHero", sender: self)
            }
        default:
            break
        }
    }
}
