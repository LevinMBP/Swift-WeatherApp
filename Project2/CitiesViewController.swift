//
//  CitiesViewController.swift
//  Project2
//
//  Created by Juscelino de Moraes Gonçalves Junior on 2024-07-18.
//

import UIKit

class CitiesViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
     var Cities: [citiesAdd] = []
    var statusUnit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDefaultItems()
        tableView.dataSource = self
    }
    
    private func loadDefaultItems(){
        //Cities.append(citiesAdd(title: "London", temp: 23.45))
      
    }
}

extension CitiesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesCell", for: indexPath)
        let city = Cities[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = city.title
        

        if statusUnit {
            content.secondaryText = String(city.tempF)
        }
        else {
            content.secondaryText = String(city.temp)
        }
        
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    
    
}

struct citiesAdd{
    let title: String
    let temp: Double
    let tempF: Double

}



    
    

