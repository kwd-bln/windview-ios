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
    var dateSettingObservable: Observable<DateSettings> { get }
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
    var dateSettingObservable: Observable<DateSettings> {
        dateSettingBehaviorRelay.asObservable()
    }
    private var dateSettings: DateSettings {
        dateSettingBehaviorRelay.value
    }
    
    // MARK: currentSondeDataList
    private let currentSondeDataListPublishRelay: PublishRelay<[SondeData]>
    var currentSondeDataListObservable: Observable<[SondeData]> {
        currentSondeDataListPublishRelay.asObservable()
    }
    
    private var lastFetchedDate: Date = .init()
    
    /// 選択した時刻が`lastFetchedDate`から1時間以内である場合
    var autoUpdateData: Bool {
        if let selectedDate = dateSettings.selectedDate {
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
        
        let ds = DateSettings(useDataDuration: UserDefaults.standard.chartDisplayDuration,
                              selectedDate: UserDefaults.standard.selectedDate)
        
        let dds = DisplayDataSetting(isTrueNorth: UserDefaults.standard.isTrueNorth,
                                     speedUnit: UserDefaults.standard.speedUnit,
                                     altUnit: UserDefaults.standard.altUnit)
        self.dataSettingBehaviorRelay = .init(value: dds)
        self.dateSettingBehaviorRelay = .init(value: ds)
        
        self.currentSondeDataListPublishRelay = .init()
        
        dateSettingObservable.subscribe { [weak self] event in
            self?.myTimer?.invalidate()
            if self?.autoUpdateData == true {
                self?.forceUpdateToLatestDate()
                self?.myTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] _ in
                    print("== intervalFunc")
                    guard let self = self else { return }
                    self.forceUpdateToLatestDate()
                })
            } else {
                self?.updateCurrentSondeDataList()
                print("== stop interval")
            }
        }.disposed(by: disposeBag)
    }
    
    func updateCurrentSondeDataList() {
        lastFetchedDate = Date()
        self.myTask?.cancel()
        self.myTask = Task {
            let sondeDataList = try await sondeDataModel.fetchSondeDataList(at: dateSettings.selectedDate,
                                                                            duration: dateSettings.useDataDuration)
            
            currentSondeDataListPublishRelay.accept(sondeDataList)
        }
    }
    
    private func forceUpdateToLatestDate() {
        self.myTask?.cancel()
        self.myTask = Task {
            let sondeDataList = try await sondeDataModel.fetchSondeDataList(at: nil,
                                                                            duration: dateSettings.useDataDuration)
            
            currentSondeDataListPublishRelay.accept(sondeDataList)
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
