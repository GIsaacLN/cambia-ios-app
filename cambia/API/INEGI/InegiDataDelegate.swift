//
//  InegiDataDelegate.swift
//
//  Created by yatziri on 26/10/24.
//

import Foundation

enum InegiDataRequestErrorType {
    case server
    case client
    case decode
}

struct InegiDataRequestErrorDetail {
    let error: Error
    let type: InegiDataRequestErrorType
}

protocol InegiDataResponseDelegate {
    func reset()
    func requestFailed(with error: Error?, type: InegiDataRequestErrorType)
}

class InegiDataDelegate: InegiDataResponseDelegate, ObservableObject {
    
    @Published var isErrorState: Bool = false
    @Published var errorDetail: InegiDataRequestErrorDetail? = nil
    
    func reset() {
        DispatchQueue.main.async {
            self.isErrorState = false
            self.errorDetail = nil
        }
    }
    
    func requestFailed(with error: Error?, type: InegiDataRequestErrorType) {
        DispatchQueue.main.async {
            self.isErrorState = true
            if let err = error {
                self.errorDetail = InegiDataRequestErrorDetail(error: err, type: type)
            }
        }
    }
}
