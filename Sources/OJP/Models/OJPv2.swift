//
//  OJPv2.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

let OJP_SDK_Version = "0.9.1"

public struct OJPv2: Codable {
    public let request: Request?
    public let response: Response?

    public enum CodingKeys: String, CodingKey {
        case request = "OJPRequest"
        case response = "OJPResponse"
    }

    public struct Response: Codable {
        public let serviceDelivery: ServiceDelivery

        public enum CodingKeys: String, CodingKey {
            case serviceDelivery = "siri:ServiceDelivery"
        }
    }

    public struct ServiceDelivery: Codable {
        public let responseTimestamp: String
        public let producerRef: String
        public let locationInformationDelivery: LocationInformationDelivery

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
            case locationInformationDelivery = "OJPLocationInformationDelivery"
        }
    }

    public struct LocationInformationDelivery: Codable {
        public let responseTimestamp: String
        public let requestMessageRef: String
        public let defaultLanguage: String
        public let calcTime: String
        public let placeResults: [PlaceResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case defaultLanguage = "siri:DefaultLanguage"
            case calcTime = "CalcTime"
            case placeResults = "PlaceResult"
        }
    }

    public struct PlaceResult: Codable {
        public let place: Place
        public let complete: Bool
        public let probability: Float

        public enum CodingKeys: String, CodingKey {
            case place = "Place"
            case complete = "Complete"
            case probability = "Probability"
        }
    }

    public struct Place: Codable {
        public let stopPlace: StopPlace
        public let name: Name
        public let geoPosition: GeoPosition

        public enum CodingKeys: String, CodingKey {
            case stopPlace = "StopPlace"
            case name = "Name"
            case geoPosition = "GeoPosition"
        }
    }

    public struct StopPlace: Codable {
        public let stopPlaceRef: String
        public let stopPlaceName: Name
        public let privateCode: PrivateCode
        public let topographicPlaceRef: String

        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case stopPlaceName = "StopPlaceName"
            case privateCode = "PrivateCode"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }

    public struct Name: Codable {
        public let text: String

        public enum CodingKeys: String, CodingKey {
            case text = "Text"
        }
    }

    public struct PrivateCode: Codable {
        public let system: String
        public let value: String

        public enum CodingKeys: String, CodingKey {
            case system = "System"
            case value = "Value"
        }
    }

    public struct GeoPosition: Codable {
        public let longitude: Double
        public let latitude: Double

        public enum CodingKeys: String, CodingKey {
            case longitude = "siri:Longitude"
            case latitude = "siri:Latitude"
        }
    }

    public struct Request: Codable {
        public let serviceRequest: ServiceRequest

        public enum CodingKeys: String, CodingKey {
            case serviceRequest = "siri:ServiceRequest"
        }
    }

    public struct ServiceRequest: Codable {
        public let requestTimestamp: String
        public let requestorRef: String
        public let locationInformationRequest: LocationInformationRequest

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case requestorRef = "siri:RequestorRef"
            case locationInformationRequest = "OJPLocationInformationRequest"
        }
    }

    public struct LocationInformationRequest: Codable {
        public let requestTimestamp: String
        public let initialInput: InitialInput
        public let restrictions: Restrictions

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case initialInput = "InitialInput"
            case restrictions = "Restrictions"
        }
    }

    public struct InitialInput: Codable {
        public let geoRestriction: GeoRestriction?

        public enum CodingKeys: String, CodingKey {
            case geoRestriction = "GeoRestriction"
        }
    }

    public struct GeoRestriction: Codable {
        public let rectangle: Rectangle?

        public enum CodingKeys: String, CodingKey {
            case rectangle = "Rectangle"
        }
    }

    public struct Rectangle: Codable {
        public let upperLeft: GeoPosition
        public let lowerRight: GeoPosition

        public enum CodingKeys: String, CodingKey {
            case upperLeft = "UpperLeft"
            case lowerRight = "LowerRight"
        }
    }

    public struct Restrictions: Codable {
        public let type: String
        public let numberOfResults: Int
        let includePtModes: Bool

        public enum CodingKeys: String, CodingKey {
            case type = "Type"
            case numberOfResults = "NumberOfResults"
            case includePtModes = "IncludePtModes"
        }
    }
}
