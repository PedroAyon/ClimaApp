//
//  WeatherManager.swift
//  Clima
//
//  Created by Pedro Ayón on 08/08/21.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weahterManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=6b576592f9eae50651026b20d5d58f57&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(_ lat: Double, _ lon: Double) {
        let urlString = "\(baseURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(cityName: String) {
        let urlString = "\(baseURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        delegate?.didUpdateWeather(weahterManager: self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let cityName = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: cityName, temperature: temp)
            
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

