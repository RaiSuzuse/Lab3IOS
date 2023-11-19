//
//  ViewController.swift
//  lab3
//
//  Created by Suzuse Rai on 11/18/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchBar: UITextField!
    
    var celsiusValue = ""
    var fahrenheitValue = ""
    var longitude = ""
    var latitutde = ""
    var manager = CLLocationManager()
    
    let weatherImages: [Condition] = [
        Condition(text: "sun.max.fill", code: 1000),
        Condition(text: "cloud", code: 1003),
        Condition(text: "cloud.fog", code: 1006),
        Condition(text: "cloud.snow", code: 1219),
        Condition(text: "cloud.heavyrain", code: 1195)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getWeatherData(search: "Lahore")
        
        switchButton.isOn = true
        searchBar.delegate = self
        
        manager.delegate = self
                manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                manager.requestAlwaysAuthorization()
                manager.requestWhenInUseAuthorization()
                manager.startUpdatingLocation()

    }
    
    func getWeatherCode(code: Int) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .systemBlue, .systemGreen])
            self.imageView.preferredSymbolConfiguration = config
            var imageName = "sun.max.fill"
            
        for i in 0...weatherImages.count - 1 {
            if weatherImages[i].code == code {
                imageName = weatherImages[i].text 
                    break
                }
            }
            
            self.imageView.image = UIImage(systemName: imageName)
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        getWeatherData(search: searchBar.text ?? "")
        
        
        return true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         let location :CLLocation = locations[0] as CLLocation
         
         latitutde = "\(location.coordinate.latitude)"
         longitude = "\(location.coordinate.longitude)"
  
     }
    
      func getWeatherData(search: String?) {
        guard let search = search else  {
            return
        }
        
        guard let url = apiUrl(query: search) else {
            print("Cannot find URL")
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("Network call complete")
            
            guard error == nil else {
                print("Recieved error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let response = self.parseJson(data: data) {
                
                DispatchQueue.main.async {
                    self.celsiusValue = "\(response.current.temp_c)"
                    self.fahrenheitValue = "\(response.current.temp_f)"
                    
                    self.cityNameLabel.text = response.location.name
                    
                    self.getWeatherCode(code: response.current.condition.code)
                    self.switchAction(self.switchButton)
                    
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func parseJson(data: Data) -> WeatherData? {
        let decoder = JSONDecoder()
        var weather: WeatherData?
        do {
            weather = try decoder.decode(WeatherData.self , from: data)
        } catch {
            print("Error decoding")
        }
        
        return weather
    }
    
    func apiUrl(query: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "5c498fd75b24459e99031322231911"
        guard let url = "\(baseURL)\(currentEndPoint)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: url)
    }
    
    @IBAction func locationButton(_ sender: Any) {
        let coordinates = latitutde + "," + longitude
        getWeatherData(search: coordinates)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        self.view.endEditing(true)
        getWeatherData(search: searchBar.text ?? "")
    }
    
    
    @IBAction func switchAction(_ sender: UISwitch) {
        if !sender.isOn{
            temperatureLabel.text = "\(celsiusValue)°C"
        }
        else{
        temperatureLabel.text = "\(fahrenheitValue)°F"
        }
    }
    
}


struct WeatherData: Decodable {
    let location: Location
    let current: Current
}

struct Location: Decodable {
    let name: String
}

struct Current: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: Condition
}

struct Condition: Decodable {
    let text: String
    let code: Int
}

