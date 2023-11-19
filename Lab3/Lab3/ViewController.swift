//
//  ViewController.swift
//  Lab3
//
//  Created by Ajai Jacob on 2023-11-09.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var switchLabel: UISwitch!
    
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    let locationManager = CLLocationManager()
    var celsius="Temp"
    var fahrenheit="Temp"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image=UIImage(systemName:"cloud.fill")
       searchTextField.delegate=self
//        configureLocationManager()
//            locationManager.requestLocation()
        
    }
    
    
    @IBAction func switchValues(_ sender: UISwitch) {
        if switchLabel.isOn
        {
            temperatureLabel.text=fahrenheit
        }
        else
        {
            temperatureLabel.text=celsius
        }
    }
    
    @IBAction func onTapLocation(_ sender: UIButton) {
        print("hg")
        configureLocationManager()
            locationManager.requestLocation()
        
    }
    
    @IBAction func onTapSearch(_ sender: UIButton) {
        loadWeather(search:  searchTextField.text)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let query = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            loadWeather(search: query)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not authorized")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    private func configureLocationManager() {
           locationManager.delegate = self
           locationManager.requestWhenInUseAuthorization()
           locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
       }
    func displayImage(weatherCondition: WeatherCondition)
    {
        var symbolImage:String
        
        switch weatherCondition.code {
              case 1000:
            symbolImage = "sun.max"
              case 1003,1109:
          symbolImage = "cloud.sun"
              case 1006:
            symbolImage = "cloud.fill"
              case 1030,1135,1147:
            symbolImage = "cloud.snow.circle.fill"
              case 1063,1153,1168,1171,1150,1240:
            symbolImage = "cloud.drizzle"
        case 1066,1210,1213,1216,1219:
      symbolImage = "cloud.snow"
              case 1069,1072,1114,1117,1204,1207:
        
            symbolImage = "cloud.sleet"
        case 1087:
      symbolImage = "cloud.bolt.fill"
              
              case 1180,1183,1186,1189:
            symbolImage = "cloud.rain"
        case 1192,1195,1198,1201,1243,1246,1249:
      symbolImage = "cloud.heavyrain.fill"
            

        case 1222,1225,1237:
      symbolImage = "snowflake"
              case 1258,1261,1264:
            symbolImage = "cloud.snow"
              case 1252:
            symbolImage = "cloud.sleet.fill"
              case 1273,1279,1276,1282:
            symbolImage = "cloud.bolt.rainbolt"
    
            
              default:
            symbolImage = "cloud.fill"
              }
        let config=UIImage.SymbolConfiguration(paletteColors: [.systemRed,.systemOrange])
        imageView.preferredSymbolConfiguration=config
        imageView.image=UIImage(systemName:symbolImage)
       
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text ?? "")
        loadWeather(search: textField.text )
        return true
    }
   
    private func loadWeather(search: String?)
    {
        guard let search=search else
        {
            return
        }
        guard let url=getUrl(query: search) else{
            print("Could not get url")
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url){data,response,error in

        print("Network call complete")
        
            guard error == nil else
                {
                    print("error")
                    return
                }
                    //no error
                    guard let data = data else
                    {
                        print("no data recieved")
                        return
                     }
            if let weatherResponse=self.parseJson(data:data)
             {
//                print(weatherResponse.location.name)
//                print(weatherResponse.current.temp_c )
//                
                
                DispatchQueue.main.async{
                    self.locationLabel.text=weatherResponse.location.name
                    self.conditionLabel.text=weatherResponse.current.condition.text
                    self.celsius="\(weatherResponse.current.temp_c)C"
                    self.fahrenheit="\(weatherResponse.current.temp_f)F"
                    if self.switchLabel.isOn
                    {
                        self.temperatureLabel.text=self.fahrenheit
                    }
                    else
                    {
                        self.temperatureLabel.text=self.celsius
                    }
                    self.displayImage(weatherCondition: weatherResponse.current.condition)
                }
            }
            
           
        }
        
        dataTask.resume()
        
    }
    
    
    private func getUrl(query:String)-> URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "ff18cc42343d4b3c8ec25353231811"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed ) else{
            return nil
        }
        //print(url)
        
        return URL(string:url)
    }
    func parseJson(data: Data)-> WeatherResponse?{
        let decoder=JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather=try decoder.decode(WeatherResponse.self, from: data)
        }
        catch{
            print(error)
        }
        return weather
    }
    }
struct WeatherResponse:Decodable{
    let location:Location
    let current:Weather
    
}
struct Location:Decodable{
    let name:String
}
struct Weather:Decodable{
    let temp_c:Float
    let temp_f:Float
    let condition:WeatherCondition
}
struct WeatherCondition:Decodable
{
    let text:String
    let code:Int
    
}

    
    

    
