//
//  HomeViewModel.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import Foundation
import RxSwift
import RxCocoa

protocol HomeViewModelInput {
}

protocol HomeViewModelOutput {
    var sondeData: Driver<SondeData?> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}

final class HomeViewModel: HomeViewModelInput, HomeViewModelOutput {
    
    var sondeData: Driver<SondeData?>
    let model: SondeDataModelInput
    
    init(model: SondeDataModelInput = StubSondeDataModel()) {
        let _sondeData = PublishRelay<SondeData?>()
        self.sondeData = _sondeData.asDriver(onErrorJustReturn: nil)
        self.model = model
        Task {
            let latestData = try await model.fetchLatestSondeDataModel()
            _sondeData.accept(latestData)
        }
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
