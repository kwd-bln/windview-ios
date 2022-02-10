//
//  SondeDataModel.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum SondeDataModelError: Error {
    case fetchError
}
protocol SondeDataModelInput {
    func fetchLatestSondeDataModel() async throws -> SondeData
}

final class SondeDataModel: SondeDataModelInput {
    static let fetchCount: Int = 5
    
    func fetchLatestSondeDataModel() async throws -> SondeData {
        let snapshot  = try await Firestore.firestore()
            .collection("sondeview")
            .order(by: "measured_at")
            .limit(to: Self.fetchCount)
            .getDocuments()
        
        do {
            let sondeDataList = try snapshot.documents.compactMap { try $0.data(as: SondeData.self )}
            return sondeDataList.first!
        } catch {
            throw SondeDataModelError.fetchError
        }
    }
}

final class StubSondeDataModel: SondeDataModelInput {
    func fetchLatestSondeDataModel() async throws -> SondeData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
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
        
        return sondeDataList.first!
        
    }
}
