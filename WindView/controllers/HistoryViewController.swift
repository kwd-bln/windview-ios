//
//  HistoryViewController.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/15.
//

import UIKit
import RxSwift

final class HistoryViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .Palette.text
        label.text = "履歴"
        return label
    }()
    
    private let closeButton: UIButton = CloseButton(frame: .zero)
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sondeDataList: [SondeData] = [] {
        didSet {
            updateSondeDataListWithDate()
            tableView.reloadData()
        }
    }
    
    private var sondeDataListWithDate: [(date: String, dataList: [SondeData])] = []
    
    private let model = UpdatingStubSondeDataModel()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .Palette.main
        
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "\(HistoryCell.self)")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(didPushCloseButton), for: .touchUpInside)
        
        fetchLatestSondeDataList()
        
        view.addSubview(tableView)
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        titleLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(44)
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else { return }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}


private extension HistoryViewController {
    @objc func didPushCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchLatestSondeDataList() {
        Task {
            sondeDataList = try await model.fetchAllSondeDataList()
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
        36
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sondeData = sondeDataListWithDate[indexPath.section].dataList[indexPath.row]
        model.setSelectedDate(sondeData.measuredAt.dateValue())
        dismiss(animated: true, completion: nil)
    }
}
