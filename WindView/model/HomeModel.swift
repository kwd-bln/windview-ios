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
    var dataSettingObservable: Observable<DisplayDataSetting> { get }
    var currentSondeDataListObservable: Observable<[SondeData]> { get }
    
    func updateCurrentSondeDataList()
    func updateCurrentSettings()
    
    var autoUpdateData: Bool { get }
}

final class HomeModel: HomeModelInput {
    let sondeDataModel: SondeDataModelInput

    // MARK: data settings
    private let dataSettingBehaviorRelay: BehaviorRelay<DisplayDataSetting>
    var dataSettingObservable: Observable<DisplayDataSetting> {
        dataSettingBehaviorRelay.asObservable()
    }
    private var dataSettings: DisplayDataSetting {
        dataSettingBehaviorRelay.value
    }
    
    private let dateSettingBehaviorRelay: BehaviorRelay<DateSettings>
    private var dateSettings: DateSettings {
        dateSettingBehaviorRelay.value
    }
    
    // MARK: currentSondeDataList
    private let currentSondeDataListBehaviorRelay: BehaviorRelay<[SondeData]>
    var currentSondeDataListObservable: Observable<[SondeData]> {
        currentSondeDataListBehaviorRelay.asObservable()
    }
    
    private var lastFetchedDate: Date = .init()
    
    var criteriaOffset: TimeInterval {
        if Util.isDebug {
            // 2ヶ月
            return 3600 * 24 * 60
        } else {
            // 1時間
            return 3600
        }
    }
    /// 選択した時刻が`lastFetchedDate`から`criteriaOffset`時間以内である場合、
    /// もしくは選択していないけれども、最新のデータの時刻が`criteriaOffset`時間以内である場合
    var autoUpdateData: Bool {
        if let selectedDate = dateSettings.selectedDate {
            return lastFetchedDate.addingTimeInterval(-criteriaOffset) < selectedDate
        } else {
            guard let latestDate = currentSondeDataListBehaviorRelay.value.first else { return false }
            let updatedAt = latestDate.updatedAt.dateValue()
            return lastFetchedDate.addingTimeInterval(-criteriaOffset) < updatedAt
        }
    }
    
    var myTimer: Timer?
    var myTask: Task<Void, Error>?
    let disposeBag = DisposeBag()
    
    init(sondeDataModel: SondeDataModelInput = UpdatingStubSondeDataModel()) {
        self.sondeDataModel = sondeDataModel
        
        let ds = DateSettings(useDataDuration: UserDefaults.standard.chartDisplayDuration,
                              selectedDate: UserDefaults.standard.selectedDate)
        
        let dds = DisplayDataSetting(isTrueNorth: UserDefaults.standard.isTrueNorth,
                                     speedUnit: UserDefaults.standard.speedUnit,
                                     altUnit: UserDefaults.standard.altUnit)
        self.dataSettingBehaviorRelay = .init(value: dds)
        self.dateSettingBehaviorRelay = .init(value: ds)
        
        self.currentSondeDataListBehaviorRelay = .init(value: [])
        
        dateSettingBehaviorRelay.subscribe { [weak self] event in
            self?.myTimer?.invalidate()
            if self?.autoUpdateData == true {
                self?.forceUpdateToLatestDate()
                self?.myTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] _ in
                    guard let self = self else { return }
                    self.forceUpdateToLatestDate()
                })
            } else {
                self?.updateCurrentSondeDataList()
            }
        }.disposed(by: disposeBag)
    }
    
    func updateCurrentSondeDataList() {
        lastFetchedDate = Date()
        self.myTask?.cancel()
        self.myTask = Task {
            let sondeDataList = try await sondeDataModel.fetchSondeDataList(at: dateSettings.selectedDate,
                                                                            duration: dateSettings.useDataDuration)
            
            currentSondeDataListBehaviorRelay.accept(sondeDataList)
        }
    }
    
    private func forceUpdateToLatestDate() {
        lastFetchedDate = Date()
        self.myTask?.cancel()
        self.myTask = Task {
            let sondeDataList = try await sondeDataModel.fetchSondeDataList(at: nil,
                                                                            duration: dateSettings.useDataDuration)
            
            currentSondeDataListBehaviorRelay.accept(sondeDataList)
        }
    }
    
    func updateCurrentSettings() {
        updateCurrentDateSettings()
        updateCurrentDisplayDataSettings()
    }
    
    private func updateCurrentDateSettings() {
        let selectedDate = UserDefaults.standard.selectedDate
        let useDataDuration = UserDefaults.standard.chartDisplayDuration
        
        if dateSettings.selectedDate != selectedDate || dateSettings.useDataDuration != useDataDuration {
            let newSettings = DateSettings(useDataDuration: useDataDuration, selectedDate: selectedDate)
            dateSettingBehaviorRelay.accept(newSettings)
        }
    }
    
    private func updateCurrentDisplayDataSettings() {
        let isTrueNorth = UserDefaults.standard.isTrueNorth
        let speedUnit = UserDefaults.standard.speedUnit
        let altUnit = UserDefaults.standard.altUnit
        
        if dataSettings.isTrueNorth != isTrueNorth
            || dataSettings.speedUnit != speedUnit
            || dataSettings.altUnit != altUnit {
            let newSettings = DisplayDataSetting(isTrueNorth: isTrueNorth,
                                                 speedUnit: speedUnit,
                                                 altUnit: altUnit)
            dataSettingBehaviorRelay.accept(newSettings)
        }
    }
}
