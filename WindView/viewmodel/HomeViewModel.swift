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
    func reAppearView()
    
    var zoomButtonTap: AnyObserver<Void> { get }
    var distIsFromSegment: AnyObserver<Bool> { get }
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
    let disposeBag = DisposeBag()
    
    // MARK: inputs
    
    var zoomButtonTap: AnyObserver<Void>
    var distIsFromSegment: AnyObserver<Bool>
    
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
        self.distIsFromSegment = AnyObserver<Bool>() { event in
            _isDistFrom.accept(event.element ?? false)
        }
        
        model.dataSettingObservable
            .subscribe(onNext: { [weak self] _ in
                self?.updateSondeDataList()
            })
            .disposed(by: disposeBag)
    }
    
    func loadView() {
        updateSondeDataList()
    }
    
    private func updateSondeDataList() {
        Task {
            let currentDataList = try await model.fetchCurrentSondeDataList()
            self._sondeDataList.accept(currentDataList)
        }
    }
    
    func reAppearView() {
        model.updateCurrentDate()
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
