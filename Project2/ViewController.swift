//
//  ViewController.swift
//  Project2
//
//  Created by Kristian Burnard on 2024-07-05.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    private var currentWeather: WeatherResponse?
    var weatherInfo : [citiesAdd] = []
    var weatherUnit: Bool = false
    
    private let iconCodes = [1000: "sun.max.fill", 1003: "cloud.sun.fill", 1180: "cloud.drizzle"]
    private let codesPalette = [
        1000: [UIColor.systemYellow, UIColor.systemBlue],
        1003: [UIColor.systemGray, UIColor.systemOrange],
        1180: [UIColor.systemGray, UIColor.systemCyan]
    ]

    @IBOutlet weak var weatherStatus: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var fButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadWeatherImage(palleteCode: nil)
        searchTextField.delegate = self
        locationManager.delegate = self
        renderButtonStyle(category: "C")
        
    }
    
    private func loadWeatherImage(palleteCode: Int?) {
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .light, scale: .large)
        // Palette & Icon are default values
        let palette: [UIColor] = [.systemYellow, .systemBlue]
        let icon: String = "sun.max.fill"
        // Sets weathercode to 1000 as default
        let newCode = palleteCode ?? 1000
        
        let myPalette = codesPalette[newCode] ?? palette
        let myIcon = iconCodes[newCode] ?? icon
        
        weatherImage.preferredSymbolConfiguration = config
        weatherImage.image = UIImage(systemName: myIcon)?.applyingSymbolConfiguration(.init(paletteColors: myPalette))
        weatherImage.sizeToFit()
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        weatherUnit = false
        loadWeather(search: searchTextField.text)
        
    }
    
    @IBAction func citiesTapped(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CitiesViewController") as! CitiesViewController
        vc.Cities = weatherInfo
        vc.statusUnit = weatherUnit
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onLocationTapped(_ sender: UIButton) {
        // Get the user location
        weatherUnit = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func onCelsiusTapped(_ sender: UIButton) {
        print("C tapped")
        guard let showTemp = currentWeather?.current.temp_c else {
            return
        }
        weatherUnit = false
        temperatureLabel.text = "\(showTemp)"
        renderButtonStyle(category: "C")
    }
    @IBAction func onFahrenheitTapped(_ sender: UIButton) {
        print("F tapped")
        guard let showTemp = currentWeather?.current.temp_f else {
            return
        }
        weatherUnit = true
        temperatureLabel.text = "\(showTemp)"
        renderButtonStyle(category: "F")
    }
    
    private func loadWeather(search: String?) {
        guard let search = search else {
            return
        }
        
        guard let url = getURL(query: search) else {
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("Network call completed")
            
            guard error == nil else {
                print("Received error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data) {
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                print(weatherResponse.current.temp_f)
                print("Weather Code: \(weatherResponse.current.condition.text)")

                
                DispatchQueue.main.async {
                    self.currentWeather = weatherResponse
                    //self.weatherList.append(weatherResponse)
                    self.locationLabel.text = weatherResponse.location.name
                    self.temperatureLabel.text = "\(weatherResponse.current.temp_c)"
                    self.weatherStatus.text = "\(weatherResponse.current.condition.text)"
                    self.loadWeatherImage(palleteCode: weatherResponse.current.condition.code)
                    self.weatherInfo.append(citiesAdd(title: weatherResponse.location.name, temp: weatherResponse.current.temp_c ,tempF: weatherResponse.current.temp_f))
                    self.loadWeatherImage(palleteCode: weatherResponse.current.condition.code)
                    
                    self.searchTextField.text = ""
                    self.renderButtonStyle(category: "C")
                }
            }

        }
        
        dataTask.resume()
        
    }
    
    private func renderButtonStyle(category: String) {
        cButton.layer.cornerRadius = 8
        fButton.layer.cornerRadius = 8
        
        if category == "C" {
            disableButton(button: cButton)
            enableButton(button: fButton)
        }
        else {
            disableButton(button: fButton)
            enableButton(button: cButton)
        }
    }
    
    private func disableButton(button: UIButton) {
        button.backgroundColor = UIColor(white: 0, alpha: 0.2)
        button.isEnabled = false
    }
    
    private func enableButton(button: UIButton) {
        button.backgroundColor = UIColor.link
        button.tintColor = UIColor.white
        button.isEnabled = true
    }
    
    private func getURL(query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "46eb0a5784b448c9a87221028241407"
        
        if query.isEmpty {
            print("Query is empty : \(query)")
            return nil
        }
        
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do {
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error decoding")
        }
        return weather
    }
    
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable {
    let name: String
}

struct Weather: Decodable {
    let temp_c: Double
    let temp_f: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

extension ViewController : CLLocationManagerDelegate, UITextFieldDelegate
{
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        
//        switch manager.authorizationStatus
//        {
//            
//        case .notDetermined:
//            print("Not determined")
//        case .restricted:
//            print("Restricted")
//        case .denied:
//            print("Denied")
//        case .authorizedAlways:
//            print("Authorized Always")
//            locationManager.requestAlwaysAuthorization()
//            locationManager.startUpdatingLocation()
//        case .authorizedWhenInUse:
//            print("Authorized When in use")
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.startUpdatingLocation()
//        @unknown default:
//            print("default")
//        }
//    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let loc = locations.last {
            loadWeather(search: "\(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationManager.stopUpdatingLocation()
        print("Error; \(error)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Covers the functionality when user hits return
        textField.endEditing(true)
        loadWeather(search: textField.text ?? "")
        return true
    }

    
    
}



