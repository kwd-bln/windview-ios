//
//  HistoryViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import UIKit

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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.style
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let date = sondeDataListWithDate[indexPath.section].dataList[indexPath.row].measuredAt.dateValue()
        cell.textLabel?.text = DateUtil.timeText(from: date)
        cell.accessoryType = .disclosureIndicator // > 表示
        cell.textLabel?.numberOfLines = 0 // これを設定しないと文字数が多くなった時に改行しない
        return cell
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
        24
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
}
