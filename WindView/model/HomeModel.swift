//
//  HomeModel.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import RxSwift
import RxCocoa

protocol HomeModelInput {
    func fetchCurrentSondeDataList() async throws -> [SondeData]
    var dataSettingObservable: Observable<DataSettings> { get }
}

final class HomeModel: HomeModelInput {
    let sondeDataModel: SondeDataModelInput

    // MARK: data settings
    private let dataSettingBehaviorRelay: BehaviorRelay<DataSettings>
    var dataSettingObservable: Observable<DataSettings> {
        dataSettingBehaviorRelay.asObservable()
    }
    private var dataSettings: DataSettings {
        dataSettingBehaviorRelay.value
    }
    
    init(sondeDataModel: SondeDataModelInput = StubSondeDataModel()) {
        self.sondeDataModel = sondeDataModel
        
        let ds = DataSettings(useDataDuration: 6, selectedDate: Date(timeIntervalSince1970: 1640992367))
        self.dataSettingBehaviorRelay = .init(value: ds)
    }
    
    func fetchCurrentSondeDataList() async throws -> [SondeData] {
        try await sondeDataModel.fetchSondeDataList(at: dataSettings.selectedDate,
                                                    duration: dataSettings.useDataDuration)
    }
}
