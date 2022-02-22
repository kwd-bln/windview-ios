//
//  UpdatingStubSondeDataModel.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/23.
//

import Foundation

/// アップデートしていくStub
final class UpdatingStubSondeDataModel: SondeDataModelInput {
    /// インスタンスが作られた時間
    static let createdAt = Date()
    
    let updateOffset: TimeInterval = .init(15)
    
    var currentJsonFileNumber: Int {
        let current = Date()
        let timeDiff = current.timeIntervalSince(Self.createdAt)
        if timeDiff < updateOffset {
            return 1
        } else if timeDiff < updateOffset * 2 {
            return 2
        } else if timeDiff < updateOffset * 3 {
            return 3
        } else {
            return 4
        }
    }
    
    func fetchLatestSondeDataModel() async throws -> SondeData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let sondeDataList = getDataList()
        return sondeDataList.first!
    }
    
    func fetchSondeDataList(at date: Date?, duration: Int) async throws -> [SondeData] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let sondeDataList = getDataList()
        let optionalTargetDate = date ?? sondeDataList.first?.measuredAt.dateValue()
        
        if let targetDate = optionalTargetDate {
            let limitDate = Date(timeInterval: -TimeInterval(hour: duration), since: targetDate)
            return sondeDataList.filter { sondeData in
                let measuredAt = sondeData.measuredAt.dateValue()
                return limitDate < measuredAt && measuredAt <= targetDate
            }
        } else {
            return []
        }
    }
    
    func fetchAllSondeDataList() async throws -> [SondeData] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return getDataList()
    }
    
    private func getDataList() -> [SondeData] {
        guard let url = Bundle.main.url(forResource: "winds-\(currentJsonFileNumber)", withExtension: "json") else {
            fatalError("ファイルが見つからない")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("ファイル読み込みエラー")
        }
        
        let decoder = JSONDecoder()
        guard let sondeDataList = try? decoder.decode([SondeData].self, from: data) else {
            fatalError("JSON読み込みエラー")
        }
        
        return sondeDataList
    }
}

