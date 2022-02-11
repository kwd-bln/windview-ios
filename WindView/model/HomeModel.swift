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
        self.dataSettingBehaviorRelay = .init(value: DataSettings())
    }
    
    func fetchCurrentSondeDataList() async throws -> [SondeData] {
        try await sondeDataModel.fetchSondeDataList(at: dataSettings.selectedDate,
                                                    duration: dataSettings.useDataDuration)
    }
}
