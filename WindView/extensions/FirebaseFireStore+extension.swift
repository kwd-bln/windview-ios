//
//  FirebaseFireStore+extension.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/11.
//

import Foundation
import FirebaseFirestore

extension FirebaseFirestore.Firestore {
    static func fetchSondeDateList(from: Date? = nil, to: Date? = nil, limitCount: Int) async throws -> [SondeData] {
        let snapshot: QuerySnapshot
        
        if let from = from, let to = to {
            let fromTimestamp = Timestamp(date: from)
            let toStamp = Timestamp(date: to)
            snapshot = try await firestore()
                .collection("sondeview")
                .order(by: "measured_at", descending: true)
                .whereField("measured_at", isLessThanOrEqualTo: toStamp)
                .whereField("measured_at", isGreaterThan: fromTimestamp)
                .limit(to: limitCount)
                .getDocuments()
        } else {
            // 何も指定がない場合は最新のもの10個
            snapshot = try await firestore()
                .collection("sondeview")
                .order(by: "measured_at", descending: true)
                .limit(to: limitCount)
                .getDocuments()
        }
        
        do {
            let sondeDataList = try snapshot.documents.compactMap { try $0.data(as: SondeData.self )}
            return sondeDataList
        } catch {
            print("error:", error)
            throw SondeDataModelError.fetchError
        }
    }
}
