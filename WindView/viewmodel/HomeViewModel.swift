//
//  HomeViewModel.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import Foundation
import RxSwift
import RxCocoa

// MVVMの設計は https://qiita.com/REON/items/c7f3d72995170f472701 を参考にした

protocol HomeViewModelInput {
    func loadView()
    var zoomButtonTap: AnyObserver<Void> { get }
    var distFromButtonTap: AnyObserver<Void> { get }
}

protocol HomeViewModelOutput {
    var sondeDataList: Driver<[SondeData]> { get }
    var dateSettings: Driver<DataSettings> { get }
    var chartSize: Driver<ChartSize> { get }
    var isDistFrom: Driver<Bool> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}

final class HomeViewModel: HomeViewModelInput, HomeViewModelOutput {
    // MARK: inputs
    
    var zoomButtonTap: AnyObserver<Void>
    var distFromButtonTap: AnyObserver<Void>
    
    // MARK: outputs
    
    private let _sondeDataList = PublishRelay<[SondeData]>()
    var sondeDataList: Driver<[SondeData]>
    var isDistFrom: Driver<Bool>
    
//    private let _chartSize: BehaviorRelay<ChartSize> = .init(value: .m)
    var chartSize: Driver<ChartSize>
    
    let model: HomeModelInput
    
    init(model: HomeModelInput = HomeModel()) {
        self.model = model
        
        // output
        self.sondeDataList = _sondeDataList.asDriver(onErrorJustReturn: [])
        let _chartSize: BehaviorRelay<ChartSize> = .init(value: .m)
        self.chartSize = _chartSize.asDriver(onErrorJustReturn: .m)
        
        let _isDistFrom: BehaviorRelay<Bool> = .init(value: false)
        self.isDistFrom = _isDistFrom.asDriver(onErrorJustReturn: false)
        
        // input
        self.zoomButtonTap = AnyObserver<Void>() { _ in
            _chartSize.accept(_chartSize.value.next)
        }
        
        // input
        self.distFromButtonTap = AnyObserver<Void>() { _ in
            _isDistFrom.accept(!_isDistFrom.value)
        }
    }
    
    func loadView() {
        Task {
            let currentDataList = try await model.fetchCurrentSondeDataList()
            self._sondeDataList.accept(currentDataList)
        }
    }
    
    var dateSettings: Driver<DataSettings> {
        model.dataSettingObservable.asDriver(onErrorJustReturn: .init())
    }
}

extension HomeViewModel: HomeViewModelType {
    var inputs: HomeViewModelInput {
        return self
    }
    var outputs: HomeViewModelOutput {
        return self
    }
}
