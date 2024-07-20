





import UIKit

class CitiesViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var Cities: [WeatherResponse] = []
    var statusUnit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
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
        content.text = city.location.name
        

        if statusUnit {
            content.secondaryText = "\(city.current.temp_f)"
        }
        else {
            content.secondaryText = "\(city.current.temp_c)"
        }
        
        
        cell.contentConfiguration = content
        
        return cell
    }
}



    
    

