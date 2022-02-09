//
//  SondeData.swift
//  WindView
//
//  Created by 河田慎平 on 2022/02/09.
//

import Foundation
import FirebaseFirestore

struct SondeData: Codable {
    let lat: Double
    let lng: Double
    let magDeclination: Double
    
    let measuredAt: Timestamp
    let updatedAt: Timestamp
    
    let location: Location?
    let values: [SondeDataItem]
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lng
        case magDeclination = "mag_dec"
        case measuredAt = "measured_at"
        case updatedAt = "updated_at"
        case location
        case values
    }
}

struct Location: Codable {
    let addressComponents: [AddressComponents]
    let formattedAddress: String
    let geometry: Geometry
    let placeId: String
    let plusCode: [String:String]
    let types: [String]
    
    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case geometry
        case placeId = "place_id"
        case plusCode = "plus_code"
        case types
    }
    
    struct AddressComponents: Codable {
        let longName: String
        let shortName: String
        let types: [String]
        
        enum CodingKeys: String, CodingKey {
            case longName = "long_name"
            case shortName = "short_name"
            case types
        }
    }
    
    struct Geometry: Codable {
        let bounds: [String: [String: Double]]
        let location: [String: Double]
        let locationType: String
        let viewport: [String: [String: Double]]
        
        enum CodingKeys: String, CodingKey {
            case bounds
            case location
            case locationType = "location_type"
            case viewport
        }
    }
}

struct SondeDataItem: Codable {
    let altitude: Double
    let height: Double
    let temperature: Double?
    let windheading: Double
    let windspeed: Double
}
