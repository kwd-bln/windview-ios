//
//  SpeedChartViewModel.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/14.
//

import Foundation
import RxSwift
import RxCocoa

protocol SpeedViewModelInput {
    var timeButtonTap: AnyObserver<Int> { get }
    var isFromSegmentControlChanged: AnyObserver<Bool> { get }
    var selectedHieightIndexValueChanged: AnyObserver<Int?> { get }
    func updateSondeDataList(_ values: [SondeData])
    func updateUseTrueNorth(_ bool: Bool)
    func updateSpeedUnit(_ unit: SpeedUnit)
}

protocol SpeedViewModelOutput {
    var sondeDataList: Driver<[SondeData]> { get }
    var selectedIndex: Driver<Int> { get }
    var selectedHeightIndex: Driver<Int?> { get }
    var isFrom: Driver<Bool> { get }
    var useTN: Driver<Bool> { get }
    var speedUnit: Driver<SpeedUnit> { get }
}

protocol SpeedViewModelPresenterOutput {
    var selectedIndexValue: Int { get }
    var numOfSondeData: Int { get }
    func sondeData(at index: Int) -> SondeData
}

protocol SpeedViewModelType {
    var inputs: SpeedViewModelInput { get }
    var outputs: SpeedViewModelOutput { get }
    var presenter: SpeedViewModelPresenterOutput { get }
}

final class SpeedChartViewModel: SpeedViewModelInput, SpeedViewModelOutput {
    // MARK: inputs
    
    var timeButtonTap: AnyObserver<Int>
    var isFromSegmentControlChanged: AnyObserver<Bool>
    var selectedHieightIndexValueChanged: AnyObserver<Int?>
    
    // MARK: outputs
    
    private let _sondeDataList: BehaviorRelay<[SondeData]> = .init(value: [])
    var sondeDataList: Driver<[SondeData]>
    
    private let _selectedIndex: BehaviorRelay<Int>
    let selectedIndex: Driver<Int>
    
    private let _isFrom: BehaviorRelay<Bool>
    let isFrom: Driver<Bool>
    
    private let _useTN: BehaviorRelay<Bool>
    let useTN: Driver<Bool>
    
    private let _selectedHeightIndex: BehaviorRelay<Int?>
    let selectedHeightIndex: Driver<Int?>
    
    private let _speedUnit: BehaviorRelay<SpeedUnit>
    let speedUnit: Driver<SpeedUnit>
    
    init() {
        // outputs
        self.sondeDataList = _sondeDataList.asDriver(onErrorJustReturn: [])
        
        let _selectedIndex = BehaviorRelay<Int>.init(value: 0)
        self.selectedIndex = _selectedIndex.asDriver(onErrorJustReturn: 0)
        
        let _isFrom = BehaviorRelay<Bool>.init(value: false)
        self.isFrom = _isFrom.asDriver(onErrorJustReturn: false)
        
        let _useTN = BehaviorRelay<Bool>.init(value: true)
        self.useTN = _useTN.asDriver(onErrorJustReturn: true)
        
        let _selectedHeightIndex = BehaviorRelay<Int?>.init(value: nil)
        self.selectedHeightIndex = _selectedHeightIndex.asDriver(onErrorJustReturn: nil)
        
        let _speedUnit = BehaviorRelay<SpeedUnit>.init(value: .mps)
        self.speedUnit = _speedUnit.asDriver(onErrorJustReturn: .mps)
        
        // inputs
        self.timeButtonTap = AnyObserver<Int>() { event in
            _selectedIndex.accept(event.element ?? 0)
        }
        
        self.isFromSegmentControlChanged = AnyObserver<Bool> { event in
            _isFrom.accept(event.element ?? false)
        }
        
        self.selectedHieightIndexValueChanged = AnyObserver<Int?> { event in
            _selectedHeightIndex.accept(event.element ?? nil)
        }
        
        self._selectedIndex = _selectedIndex
        self._isFrom = _isFrom
        self._useTN = _useTN
        self._selectedHeightIndex = _selectedHeightIndex
        self._speedUnit = _speedUnit
    }
    
    func updateSondeDataList(_ values: [SondeData]) {
        if _selectedIndex.value >= values.count {
            _selectedIndex.accept(0)
        }
        _selectedHeightIndex.accept(nil)
        _sondeDataList.accept(values)
    }
    
    func updateUseTrueNorth(_ bool: Bool) {
        if _useTN.value != bool {
            _useTN.accept(bool)
        }
    }
    
    func updateSpeedUnit(_ unit: SpeedUnit) {
        if _speedUnit.value != unit {
            _speedUnit.accept(unit)
        }
    }
}

extension SpeedChartViewModel: SpeedViewModelPresenterOutput {
    var selectedIndexValue: Int {
        _selectedIndex.value
    }
    
    var numOfSondeData: Int {
        _sondeDataList.value.count
    }
    
    func sondeData(at index: Int) -> SondeData {
        _sondeDataList.value[index]
    }
}

extension SpeedChartViewModel: SpeedViewModelType {
    var inputs: SpeedViewModelInput {
        return self
    }
    var outputs: SpeedViewModelOutput {
        return self
    }
    var presenter: SpeedViewModelPresenterOutput {
        return self
    }
}
