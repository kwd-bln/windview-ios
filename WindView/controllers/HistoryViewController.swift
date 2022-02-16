//
//  HistoryViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import UIKit
import RxSwift

final class HistoryViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sondeDataList: [SondeData] = [] {
        didSet {
            updateSondeDataListWithDate()
            tableView.reloadData()
        }
    }
    
    private var sondeDataListWithDate: [(date: String, dataList: [SondeData])] = []
    
    private let model = StubSondeDataModel()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .Palette.main
        
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "\(HistoryCell.self)")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        fetchLatestSondeDataList()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(36)
        }
    }
}


private extension HistoryViewController {
    func fetchLatestSondeDataList() {
        Task {
            sondeDataList = try await model.fetchSAllSondeDataList()
        }
    }
    
    func updateSondeDataListWithDate() {
        var currentDataList: [SondeData] = []
        
        var previousDate = DateUtil.dateText(from: Date())
        sondeDataList.forEach { sondeData in
            let dateText = DateUtil.dateText(from: sondeData.measuredAt.dateValue())
            if dateText != previousDate, currentDataList.count > 0 {
                sondeDataListWithDate.append((previousDate, currentDataList))
                currentDataList = []
            }
            currentDataList.append(sondeData)
            previousDate = dateText
        }
        
        if currentDataList.count > 0 {
            sondeDataListWithDate.append((previousDate, currentDataList))
        }
    }
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(HistoryCell.self)", for: indexPath)
        
        guard let historyCell = cell as? HistoryCell else { return cell }
        
        let sondeData = sondeDataListWithDate[indexPath.section].dataList[indexPath.row]
        let date = sondeData.measuredAt.dateValue()
        let time = DateUtil.timeText(from: date)
        let place = sondeData.locationText
        
        historyCell.set(time: time, place: place)
        return historyCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sondeDataListWithDate[section].date
    }
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sondeDataListWithDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sondeDataListWithDate[section].dataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
}
