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
    func updateSondeDataList(_ values: [SondeData])
}

protocol SpeedViewModelOutput {
    var sondeDataList: Driver<[SondeData]> { get }
    var selectedIndex: Driver<Int> { get }
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
    
    // MARK: outputs
    
    private let _sondeDataList: BehaviorRelay<[SondeData]> = .init(value: [])
    var sondeDataList: Driver<[SondeData]>
    
    private let _selectedIndex: BehaviorRelay<Int>
    let selectedIndex: Driver<Int>
    
    init() {
        // outputs
        self.sondeDataList = _sondeDataList.asDriver(onErrorJustReturn: [])
        
        let _selectedIndex = BehaviorRelay<Int>.init(value: 0)
        self.selectedIndex = _selectedIndex.asDriver(onErrorJustReturn: 0)
        
        // inputs
        self.timeButtonTap = AnyObserver<Int>() { event in
            _selectedIndex.accept(event.element ?? 0)
        }
        self._selectedIndex = _selectedIndex
    }
    
    func updateSondeDataList(_ values: [SondeData]) {
        _sondeDataList.accept(values)
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
