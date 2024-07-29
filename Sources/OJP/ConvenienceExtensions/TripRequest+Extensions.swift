//
//  TripRequest+Extensions.swift
//
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import Foundation

public extension OJPv2.PlaceRefChoice {
    var title: String {
        switch self {
        case let .geoPosition(ref):
            ref.name.text
        case let .stopPointRef(ref):
            ref.name.text
        case let .stopPlaceRef(ref):
            ref.name.text
        }
    }
}

extension OJPv2.PlaceRefChoice: Hashable {
    public static func == (lhs: OJPv2.PlaceRefChoice, rhs: OJPv2.PlaceRefChoice) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .stopPlaceRef(let stopPlaceRef):
            hasher.combine(stopPlaceRef.stopPlaceRef)
        case .geoPosition(let geoPositionRef):
            hasher.combine(geoPositionRef.geoPosition.latitude)
            hasher.combine(geoPositionRef.geoPosition.longitude)
        case .stopPointRef(let stopPointRef):
            hasher.combine(stopPointRef.stopPointRef)
        }
    }
}

public extension OJPv2.PlaceResult {
    var title: String {
        switch place.place {
        case let .stopPlace(stopPlace):
            stopPlace.stopPlaceName.text
        case let .address(address):
            address.name.text
        }
    }

    var placeRef: OJPv2.PlaceRefChoice {
        switch place.place {
        case let .stopPlace(stopPlace):
            .stopPlaceRef(
                .init(
                    stopPlaceRef: stopPlace.stopPlaceRef,
                    name: stopPlace.stopPlaceName
                )
            )
        case let .address(address):
            .geoPosition(
                .init(
                    geoPosition: place.geoPosition,
                    name: address.name
                )
            )
        }
    }
}

public extension OJPv2.Trip {
    var originName: String {
        switch legs.first?.legType {
        case let .continous(continousLeg):
            continousLeg.legStart.title
        case let .timed(timedLeg):
            timedLeg.legBoard.stopPointName.text
        case let .transfer(transferLeg):
            transferLeg.legStart.title
        case nil:
            ""
        }
    }

    var destinationName: String {
        switch legs.last?.legType {
        case let .continous(continousLeg):
            continousLeg.legEnd.title
        case let .timed(timedLeg):
            timedLeg.legAlight.stopPointName.text
        case let .transfer(transferLeg):
            transferLeg.legEnd.title
        case nil:
            ""
        }
    }

    var legCount: Int {
        legs.count
    }
}
