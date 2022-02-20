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
    var dataSettingObservable: Observable<DataSettings> { get }
    
    func fetchCurrentSondeDataList() async throws -> [SondeData]
    func updateCurrentSettings()
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
        
        let ds = DataSettings(useDataDuration: UserDefaults.standard.chartDisplayDuration,
                              selectedDate: UserDefaults.standard.selectedDate,
                              isTrueNorth: UserDefaults.standard.isTrueNorth)
        self.dataSettingBehaviorRelay = .init(value: ds)
    }
    
    func fetchCurrentSondeDataList() async throws -> [SondeData] {
        try await sondeDataModel.fetchSondeDataList(at: dataSettings.selectedDate,
                                                    duration: dataSettings.useDataDuration)
    }
    
    func updateCurrentSettings() {
        guard let selectedDate = UserDefaults.standard.selectedDate else { return }
        let isTrueNorth = UserDefaults.standard.isTrueNorth
        let useDataDuration = UserDefaults.standard.chartDisplayDuration
        let speedUnit = UserDefaults.standard.speedUnit
        let altUnit = UserDefaults.standard.altUnit
        if dataSettings.selectedDate != selectedDate
            || dataSettings.isTrueNorth != isTrueNorth
            || dataSettings.useDataDuration != useDataDuration
            || dataSettings.speedUnit != speedUnit
            || dataSettings.altUnit != altUnit {
            let newSettings = DataSettings(useDataDuration: useDataDuration,
                                           selectedDate: selectedDate,
                                           isTrueNorth: isTrueNorth,
                                           speedUnit: speedUnit,
                                           altUnit: altUnit)
            dataSettingBehaviorRelay.accept(newSettings)
        }
    }
}
