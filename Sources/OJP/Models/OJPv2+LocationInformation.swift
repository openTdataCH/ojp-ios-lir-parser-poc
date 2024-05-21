//
//  OJPv2+LocationInformation.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

public extension OJPv2 {
    internal struct StopEventServiceDelivery: Codable {
        let responseTimestamp: String
        let producerRef: String
        let stopEventDelivery: StopEventDelivery

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
            case stopEventDelivery = "OJPStopEventDelivery"
        }
    }

    internal struct StopEventDelivery: Codable {
        let places: [Place]
    }

    // TODO: where is that used?
    internal struct LocationInformationServiceDelivery: Codable {
        public let responseTimestamp: String
        public let producerRef: String
        public let locationInformationDelivery: LocationInformationDelivery

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case producerRef = "siri:ProducerRef"
            case locationInformationDelivery = "OJPLocationInformationDelivery"
        }
    }

    internal struct LocationInformationDelivery: Codable {
        public let responseTimestamp: String
        public let requestMessageRef: String?
        public let defaultLanguage: String?
        public let calcTime: Int?
        public let placeResults: [PlaceResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case defaultLanguage = "siri:DefaultLanguage"
            case calcTime = "CalcTime"
            case placeResults = "PlaceResult"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            responseTimestamp = try container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.responseTimestamp))
            requestMessageRef = try? container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.requestMessageRef))
            defaultLanguage = try? container.decode(String.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.defaultLanguage))
            calcTime = try? container.decode(Int.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.calcTime))
            placeResults = try container.decode([OJPv2.PlaceResult].self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.placeResults))
        }
    }

    struct PlaceResult: Codable {
        public let place: Place
        public let complete: Bool
        public let probability: Float?

        public enum CodingKeys: String, CodingKey {
            case place = "Place"
            case complete = "Complete"
            case probability = "Probability"
        }
    }

    enum PlaceTypeChoice: Codable {
        case stopPlace(OJPv2.StopPlace)
        case address(OJPv2.Address)

        enum CodingKeys: String, CodingKey {
            case stopPlace = "StopPlace"
            case address = "Address"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.stopPlace)) {
                self = try .stopPlace(
                    container.decode(
                        StopPlace.self,
                        forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.stopPlace)
                    )
                )
            } else if container.contains(StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.address)) {
                self = try .address(
                    container.decode(
                        Address.self,
                        forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.address)
                    )
                )
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    struct Place: Codable {
        public let place: PlaceTypeChoice
        public let name: Name
        public let geoPosition: GeoPosition
        public let modes: [Mode]

        public enum CodingKeys: String, CodingKey {
            case name = "Name"
            case geoPosition = "GeoPosition"
            case modes = "Mode"
        }

        public init(from decoder: any Decoder) throws {
            place = try PlaceTypeChoice(from: decoder)
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)
            name = try container.decode(Name.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.name))
            geoPosition = try container.decode(GeoPosition.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.geoPosition))
            modes = try container.decode([Mode].self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.modes))
        }
    }

    // TODO: - move this outside of LIR, it belongs also to TR
    // https://vdvde.github.io/OJP/develop/index.html#ModeStructure
    struct Mode: Codable {
        public let ptMode: PtMode

        // https://laidig.github.io/siri-20-java/doc/schemas/siri_modes-v1_1_xsd/schema-overview.html
        // siri:PtModeChoiceGroup
        // keep busSubmode, railSubmode for now
        public let busSubmode: String?
        // https://laidig.github.io/siri-20-java/doc/schemas/siri_modes-v1_1_xsd/elements/RailSubmode.html
        public let railSubmode: String?

        public let name: Name?
        public let shortName: Name?

        public enum CodingKeys: String, CodingKey {
            case ptMode = "PtMode"
            case busSubmode = "siri:BusSubmode"
            case railSubmode = "siri:RailSubmode"
            case name = "Name"
            case shortName = "ShortName"
        }

        public enum PtMode: String, Codable {
            case rail
            case bus
            case tram
            case water
            case telecabin
            case underground
            case unknown

            public init(from decoder: Decoder) throws {
                self = try PtMode(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
            }
        }
    }

    struct StopPlace: Codable {
        public let stopPlaceRef: String
        public let stopPlaceName: Name
        public let privateCodes: [PrivateCode]
        public let topographicPlaceRef: String?

        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case stopPlaceName = "StopPlaceName"
            case privateCodes = "PrivateCode"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }

    struct Address: Codable {
        public let publicCode: String
        public let topographicPlaceRef: String?
        public let topographicPlaceName: String?
        public let countryName: String?
        public let postCode: String?
        public let name: Name
        public let street: String?
        public let houseNumber: String?
        public let crossRoad: String?

        public enum CodingKeys: String, CodingKey {
            case publicCode = "PublicCode"
            case topographicPlaceName = "TopographicPlaceName"
            case topographicPlaceRef = "TopographicPlaceRef"
            case postCode = "PostCode"
            case name = "Name"
            case street = "Street"
            case houseNumber = "HouseNumber"
            case crossRoad = "CrossRoad"
            case countryName = "CountryName"
        }
    }

    // TODO: - move out from LIR, belongs also to TR
    // https://vdvde.github.io/OJP/develop/index.html#InternationalTextStructure
    struct Name: Codable {
        public let text: String

        public enum CodingKeys: String, CodingKey {
            case text = "Text"
        }
    }

    struct PrivateCode: Codable {
        public let system: String
        public let value: String

        public enum CodingKeys: String, CodingKey {
            case system = "System"
            case value = "Value"
        }
    }
    
    // TODO: - move out from LIR, belongs also to TR
    struct GeoPosition: Codable {
        public let longitude: Double
        public let latitude: Double

        public enum CodingKeys: String, CodingKey {
            case longitude = "siri:Longitude"
            case latitude = "siri:Latitude"
        }

        public init(longitude: Double, latitude: Double) {
            self.longitude = longitude
            self.latitude = latitude
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: StrippedPrefixCodingKey.self)

            longitude = try container.decode(Double.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.longitude))
            latitude = try container.decode(Double.self, forKey: StrippedPrefixCodingKey.stripPrefix(fromKey: CodingKeys.latitude))
        }
    }

    internal struct Request: Codable {
        public let serviceRequest: ServiceRequest

        public enum CodingKeys: String, CodingKey {
            case serviceRequest = "siri:ServiceRequest"
        }
    }

    internal struct ServiceRequest: Codable {
        public let requestTimestamp: Date
        public let requestorRef: String
        public let locationInformationRequest: LocationInformationRequest?
        public let tripRequest: TripRequest?

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case requestorRef = "siri:RequestorRef"
            case locationInformationRequest = "OJPLocationInformationRequest"
            case tripRequest = "OJPTripRequest"
        }
    }

    internal struct LocationInformationRequest: Codable {
        public let requestTimestamp: Date
        public let initialInput: InitialInput
        public let restrictions: PlaceParam

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case initialInput = "InitialInput"
            case restrictions = "Restrictions"
        }
    }

    internal struct InitialInput: Codable {
        public let geoRestriction: GeoRestriction?
        public let name: String?

        public enum CodingKeys: String, CodingKey {
            case geoRestriction = "GeoRestriction"
            case name = "Name"
        }
    }

    internal struct GeoRestriction: Codable {
        public let rectangle: Rectangle?

        public enum CodingKeys: String, CodingKey {
            case rectangle = "Rectangle"
        }
    }

    struct Rectangle: Codable {
        public let upperLeft: GeoPosition
        public let lowerRight: GeoPosition

        public enum CodingKeys: String, CodingKey {
            case upperLeft = "UpperLeft"
            case lowerRight = "LowerRight"
        }
    }

    struct PlaceParam: Codable {
        public init(type: [PlaceType], numberOfResults: Int = 10, includePtModes: Bool = true) {
            self.type = type
            self.numberOfResults = numberOfResults
            self.includePtModes = includePtModes
        }

        public let type: [PlaceType]
        public let numberOfResults: Int
        let includePtModes: Bool

        public enum CodingKeys: String, CodingKey {
            case type = "Type"
            case numberOfResults = "NumberOfResults"
            case includePtModes = "IncludePtModes"
        }
    }
}

extension OJPv2.PlaceTypeChoice: Identifiable {
    public var id: String {
        switch self {
        case let .stopPlace(stopPlace):
            stopPlace.stopPlaceRef
        case let .address(address):
            address.publicCode
        }
    }
}

extension OJPv2.PlaceResult: Identifiable {
    public var id: String { place.place.id }
}
