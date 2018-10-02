//
//  ViewController.swift
//  SwiftJsondataCollectionView
//
//  Created by apple on 01/03/18.
//  Copyright © 2018 apple. All rights reserved.
// https://api.opendota.com/api/heroStats

import UIKit

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

struct hero: Decodable {
    
    let localized_name: String
    let img: String
}
class ViewController: UIViewController , UICollectionViewDataSource,UICollectionViewDelegate{
    
    

    var heros = [hero]()
    
    @IBOutlet var collectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://api.opendota.com/api/heroStats")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error == nil {
                
                do{
                    self.heros = try JSONDecoder().decode([hero].self, from: data!)
                }
                catch
                {
                    print(" parse error")
                }
                
                DispatchQueue.main.async {
                    print(self.heros.count)
                    
                    self.collectionview.delegate = self
                    self.collectionview.dataSource = self
                    self.collectionview.reloadData()
                }
            }
        }.resume()

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heros.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionCell", for: indexPath) as! CustomCollectionCell
        cell.lblName.text = heros[indexPath.row].localized_name.capitalized
        
        
        let defaultlink = "https://api.opendota.com"
        let completelink = defaultlink + heros[indexPath.row].img
        
        cell.imgVCell.downloadedFrom(link: completelink)
        cell.imgVCell.clipsToBounds = true
        cell.imgVCell.layer.cornerRadius = cell.imgVCell.frame.height/2
        
        cell.imgVCell.contentMode = .scaleAspectFill
        return cell
    }


}

