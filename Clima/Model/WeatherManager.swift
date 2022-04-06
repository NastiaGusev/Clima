//
//  WeatherManager.swift
//  Clima
//
//  Created by Nastia Gusev on 31/03/2022.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManger, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManger {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=c8e17ba38f7ccd033f61c18bec8452a2&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        preformRequest(with: urlString)
    }
    
    func fetchWeather(latitude lat: CLLocationDegrees, longitude lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        print(urlString)
        preformRequest(with: urlString)
    }
    
    func preformRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeDate = data {
                    if let weather = self.parseJSON(safeDate) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            return WeatherModel(conditionId: id, cityName: name, temprature: temp)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
