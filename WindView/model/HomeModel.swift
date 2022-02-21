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
    var currentSondeDataListObservable: Observable<[SondeData]> { get }
    
    func updateCurrentSondeDataList()
    func updateCurrentSettings()
    
    var autoUpdateData: Bool { get }
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
    
    // MARK: currentSondeDataList
    private let currentSondeDataListPublishRelay: PublishRelay<[SondeData]>
    var currentSondeDataListObservable: Observable<[SondeData]> {
        currentSondeDataListPublishRelay.asObservable()
    }
    
    private var lastFetchedDate: Date = .init()
    
    /// 選択した時刻が`lastFetchedDate`から1時間以内である場合
    var autoUpdateData: Bool {
        if let selectedDate = dataSettings.selectedDate {
            return lastFetchedDate.addingTimeInterval(-3600 * 24 * 30) < selectedDate
        } else {
            return true
        }
    }
    
    var myTimer: Timer?
    var myTask: Task<Void, Error>?
    let disposeBag = DisposeBag()
    
    init(sondeDataModel: SondeDataModelInput = StubSondeDataModel()) {
        self.sondeDataModel = sondeDataModel
        
        let ds = DataSettings(useDataDuration: UserDefaults.standard.chartDisplayDuration,
                              selectedDate: UserDefaults.standard.selectedDate,
                              isTrueNorth: UserDefaults.standard.isTrueNorth)
        self.dataSettingBehaviorRelay = .init(value: ds)
        
        self.currentSondeDataListPublishRelay = .init()
        
        dataSettingObservable.subscribe { [weak self] event in
            self?.myTimer?.invalidate()
            self?.myTask?.cancel()
            if self?.autoUpdateData == true {
                self?.myTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] _ in
                    print("== intervalFunc")
                    guard let self = self else { return }
                    self.updateCurrentSettings()
                })
            } else {
                print("== stop interval")
            }
        }.disposed(by: disposeBag)
    }
    
    func updateCurrentSondeDataList() {
        lastFetchedDate = Date()
        self.myTask = Task {
            let sondeDataList = try await sondeDataModel.fetchSondeDataList(at: dataSettings.selectedDate,
                                                                            duration: dataSettings.useDataDuration)
            
            currentSondeDataListPublishRelay.accept(sondeDataList)
        }
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
