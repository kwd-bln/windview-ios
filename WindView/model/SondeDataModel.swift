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
    /// 指定した日時から遡って`duration`だけデータを取得する
    func fetchSondeDataList(at date: Date?, duration: Int) async throws -> [SondeData]
    /// 全てのsondeDataを取得する
    func fetchSAllSondeDataList() async throws -> [SondeData]
}

final class SondeDataModel: SondeDataModelInput {
    static let fetchCount: Int = 10
    
    func fetchLatestSondeDataModel() async throws -> SondeData {
        let sondeDataList = try await fetchLatestSondeDataList()
        return sondeDataList.first!
    }
    
    private func fetchLatestSondeDataList() async throws -> [SondeData] {
        let sondeDataList = try await Firestore.fetchSondeDateList(limitCount: Self.fetchCount)
        return sondeDataList
    }
    
    func fetchSondeDataList(at date: Date?, duration: Int) async throws -> [SondeData] {
        if let date = date {
            let fromDate = Date(timeInterval: -TimeInterval(hour: duration), since: date)
            return try await Firestore.fetchSondeDateList(from: fromDate, to: date, limitCount: Self.fetchCount)
        } else {
            let latestSondeDataList = try await fetchLatestSondeDataList()
            if let first = latestSondeDataList.first {
                let toDate = first.measuredAt.dateValue()
                let fromDate = Date(timeInterval: -TimeInterval(hour: duration), since: toDate)
                return latestSondeDataList.filter { sondeData in
                    let measuredAt = sondeData.measuredAt.dateValue()
                    return fromDate < measuredAt && measuredAt <= toDate
                }
            } else {
                return []
            }
        }
    }
    
    func fetchSAllSondeDataList() async throws -> [SondeData] {
        try await Firestore.fetchSondeDateList(from: nil, to: nil, limitCount: 50)
    }
}

final class StubSondeDataModel: SondeDataModelInput {
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
    
    func fetchSAllSondeDataList() async throws -> [SondeData] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return getDataList()
    }
    
    private func getDataList() -> [SondeData] {
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
        
        return sondeDataList
    }
}


extension TimeInterval {
    init(hour: Int) {
        // 60秒 * 60分 * hour時間
        self.init(60 * 60 * hour)
    }
}

// MARK: - モックデータの作成のためのextension

extension SondeDataModel {
    func save(dataList: [SondeData]) {
        guard let json =  try? JSONEncoder().encode(dataList) else { return }
        
        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("wind.json") else { return }

        do {
            try json.write(to: url)
        } catch let error {
            print(error)
        }
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    }
}

