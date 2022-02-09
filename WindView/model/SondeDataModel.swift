//
//  SondeDataModel.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol SondeDataModelInput {
    func fetchLatestSondeDataModel()
}

final class SondeDataModel: SondeDataModelInput {
    static let fetchCount: Int = 5
    func fetchLatestSondeDataModel() {
        Firestore.firestore().collection("sondeview").order(by: "measured_at").limit(to: Self.fetchCount)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error:", error)
                }
                
                guard let snapshot = snapshot else { return }
                
                do {
                    let sondeDataList = try snapshot.documents
                        .map { try $0.data(as: SondeData.self) }
                    print("success")
                    print("sondeDataList", sondeDataList)
                    
                    let json = try JSONEncoder().encode(sondeDataList)
                    self.saveJson(json: json)
                } catch {
                    print("error", error)
                    return
                }
            }
        
    }
    
    func saveJson(json: Data) {
        guard let url = try? FileManager.default.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true)
                .appendingPathComponent("winds.json") else { return }
        
        do {
            try json.write(to: url)
            print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
        } catch let error {
            print(error)
        }

    }
}

final class StubSondeDataModel: SondeDataModelInput {
    func fetchLatestSondeDataModel() {
        guard let url = Bundle.main.url(forResource: "winds", withExtension: "json") else {
            fatalError("ファイルが見つからない")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("ファイル読み込みエラー")
        }
        
        let decoder = JSONDecoder()
        guard let sondeDataList = try? decoder.decode([SondeData].self, from: data) else {
            fatalError("JSON読み込みエラー")
        }
        
        print(sondeDataList)
        
    }
}
