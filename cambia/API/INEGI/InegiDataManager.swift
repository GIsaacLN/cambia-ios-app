//
//  InegiDataManager.swift
//  AppiPrueba1
//
//  Created by yatziri on 26/10/24.
//

import Foundation

class InegiDataManager {
    /*
    https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/1002000001,3105001001/es/070000090002/true/BISE/2.0/[Aquí va tu Token]?type=json
     */
    /*
     https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/3114006001,1002000001/es/07000009/true/BISE/2.0/[Aquí va tu Token]?type=json
    */

    // Base URL for the API
    private let baseURL = "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/"
    
    // Delegate to handle responses and errors
    public var delegate: InegiDataDelegate?
    
    // Securely store the API key
    private var apiKey: String {
        // Retrieve the API key from secure storage or configuration
        // For example, from environment variables or a secure plist
        return "c637c203-fa2e-c752-ec58-0fefb7bac235"
    }
    
    func fetchData(indicators: [String], municipio: String?, completion: @escaping (InegiData?) -> Void) {
        delegate?.reset()
        
        let indicatorsString = indicators.joined(separator: ",")
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.path += "\(indicatorsString)/es/\(municipio ?? "")/true/BISE/2.0/\(apiKey)"
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: "json")
        ]
        
        guard let url = urlComponents.url else {
            // Handle invalid URL
            delegate?.requestFailed(with: nil, type: .client)
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let err = error {
                self.handleClientError(err)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                self.handleServerError(response)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let jsonData = data {
                let inegiData = self.decodeResponse(json: jsonData, municipio: municipio ?? "")
                DispatchQueue.main.async {
                    completion(inegiData)
                }
            } else {
                self.handleDecodeError(NSError(domain: "DataError", code: 0, userInfo: nil))
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    func decodeResponse(json: Data, municipio: String) -> InegiData? {
        do {
            let decoder = JSONDecoder()
            let inegiDataResponse = try decoder.decode(InegiDataResponse.self, from: json)
            return inegiDataResponse.toInegiData(municipio: municipio)
        } catch {
            self.handleDecodeError(error)
            return nil
        }
    }
    
    private func handleClientError(_ error: Error) {
        delegate?.requestFailed(with: error, type: .client)
    }
    
    private func handleServerError(_ response: URLResponse?) {
        let error = NSError(domain: "API Error", code: 141, userInfo: nil)
        delegate?.requestFailed(with: error, type: .server)
    }
    
    private func handleDecodeError(_ error: Error) {
        delegate?.requestFailed(with: error, type: .decode)
    }
}
