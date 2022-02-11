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
}

protocol HomeViewModelOutput {
    var sondeDataList: Driver<[SondeData]> { get }
    var dateSettings: Driver<DataSettings> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}

final class HomeViewModel: HomeViewModelInput, HomeViewModelOutput {
    let _sondeDataList = PublishRelay<[SondeData]>()
    var sondeDataList: Driver<[SondeData]>
    
    let model: HomeModelInput
    
    init(model: HomeModelInput = HomeModel()) {
        self.sondeDataList = _sondeDataList.asDriver(onErrorJustReturn: [])
        self.model = model
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
