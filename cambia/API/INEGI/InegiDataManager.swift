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
    public var delegate: InegiDataDelegate? = nil
    static let apikey = "c637c203-fa2e-c752-ec58-0fefb7bac235"
    let url = "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/"
    
    func fetchData(indicators: [String], ciudad: String, municipio: String?, comletion: @escaping(_ inegiData: InegiData?)-> Void){
        self.delegate?.reset()
        let indicatorsString = indicators.joined(separator: ",")
        let url = URL(string: "\(self.url)\(indicatorsString)/es/\(ciudad)\(municipio ?? "")/true/BISE/2.0/\(InegiDataManager.apikey)?type=json")!
        //let url = URL(string: "\(self.url)\(indicators[0]),\(indicators[1]), \(indicators[2]),\(indicators[3])/es/\(ciudad)\(municipio ?? "")/true/BISE/2.0/\(InegiDataManager.apikey)?type=json")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let err = error {
                // TODO - handle client error
                self.handleClientError(err)
                DispatchQueue.main.async {
                    comletion(nil)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200 else {
                // TODO - handle server error
                self.handleServerError(response)
                DispatchQueue.main.async {
                    comletion(nil)
                }
                print("No data")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType.hasPrefix("application/json"), let json = data {
                let poblacion = self.decodeResponse(json: json, ciudad: ciudad, municipio: municipio ?? "")
                
                DispatchQueue.main.async {
                    comletion(poblacion)
                }
            }else{
                
                // TODO - handle decode error
            }
        }//end Task
        task.resume()
    }
    func decodeResponse(json: Data , ciudad: String, municipio: String? ) -> InegiData? {
        do {
            let decoder = JSONDecoder()
            let inegiDataResponse = try decoder.decode(InegiDataResponse.self, from: json)
            return inegiDataResponse.toInegiData(city: ciudad, municipio: municipio ?? "")
        } catch {
            self.handleDecodeError(error)
            return nil
        }
    }

    
    private func handleClientError(_ error: Error) {
        delegate?.requestFaildwith(error: error, type: .client)
    }
    
    private func handleServerError(_ respons: URLResponse?) {
        let error = NSError(domain: "API ERROR", code: 141)
        delegate?.requestFaildwith(error: error, type: .server)
    }
    
    private func handleDecodeError(_ error: Error) {
        delegate?.requestFaildwith(error: error, type: .decode)
    }
}

