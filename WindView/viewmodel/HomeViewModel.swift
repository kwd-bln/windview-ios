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
    var isLoggedIn: Bool { get }
    
    func loadView()
    func reAppearView()
    func finishLogin()
    func logout()
    
    var zoomButtonTap: AnyObserver<Void> { get }
    var distIsFromSegment: AnyObserver<Bool> { get }
}

protocol HomeViewModelOutput {
    var sondeDataList: Driver<[SondeData]> { get }
    var displayDataSettings: Driver<DisplayDataSetting> { get }
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
    var isLoggedIn: Bool {
        model.isLoggedIn
    }
    
    func finishLogin() {
        model.updateCurrentSondeDataList()
    }
    
    func logout() {
        model.logout()
    }
    
    // MARK: outputs
    
    var sondeDataList: Driver<[SondeData]>
    var isDistFrom: Driver<Bool>
    
    var chartSize: Driver<ChartSize>
    
    let model: HomeModelInput
    
    init(model: HomeModelInput = HomeModel()) {
        self.model = model
        
        self.sondeDataList = self.model.currentSondeDataListObservable.asDriver(onErrorJustReturn: [])
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
    }
    
    func loadView() {
        // 必要なさそうなのでとりあえずコメントアウト
//        updateSondeDataList()
    }
    
    private func updateSondeDataList() {
        model.updateCurrentSondeDataList()
    }
    
    func reAppearView() {
        model.updateCurrentSettings()
    }
    
    var displayDataSettings: Driver<DisplayDataSetting> {
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
