//
//  PaginatedTripLoader.swift
//
//
//  Created by Lehnherr Reto on 01.07.2024.
//

import Foundation

public struct TripRequest {
    let from: OJPv2.PlaceRefChoice
    let to: OJPv2.PlaceRefChoice
    let via: [OJPv2.PlaceRefChoice]?
    var at: DepArrTime
    var params: OJPv2.TripParams

    public init(from: OJPv2.PlaceRefChoice, to: OJPv2.PlaceRefChoice, via: [OJPv2.PlaceRefChoice]? = nil, at: DepArrTime, params: OJPv2.TripParams) {
        self.from = from
        self.to = to
        self.via = via
        self.at = at
        self.params = params
    }
}

public actor PaginatedTripLoader {
    private(set) var minDate: Date?
    private(set) var maxDate: Date?

    private var existingTripHashes: Set<Int> = Set()
    private var request: TripRequest?
    private let ojp: OJP

    public init(ojp: OJP) {
        self.ojp = ojp
    }

    public func loadTrips(for request: TripRequest, numberOfResults: OJPv2.NumberOfResults) async throws -> OJPv2.TripDelivery {
        let params = OJPv2.TripParams(numberOfResults: numberOfResults,
                                      includeLegProjection: request.params.includeLegProjection,
                                      includeTurnDescription: request.params.includeTurnDescription,
                                      includeIntermediateStops: request.params.includeIntermediateStops,
                                      includeAllRestrictedLines: request.params.includeAllRestrictedLines,
                                      modeAndModeOfOperationFilter: request.params.modeAndModeOfOperationFilter
        )
        var tripDelivery = try await ojp.requestTrips(
            from: request.from,
            to: request.to,
            via: request.via,
            at: request.at,
            params: params
        )

        try Task.checkCancellation()
        self.request = request

        let filteredTripResults: [OJPv2.TripResult] = tripDelivery.tripResults
            .filter { $0.trip != nil } // TripSummary currently not supported
            .compactMap { tripResult in
                guard let trip = tripResult.trip else { return nil }
                let hash = trip.tripHash // de-duplicate trips based on tripHash
                guard !existingTripHashes.contains(hash) else {
                    return nil
                }
                existingTripHashes.insert(hash)

                if maxDate == nil || trip.startTime > maxDate! { maxDate = trip.startTime }
                if minDate == nil || trip.startTime < minDate! { minDate = trip.startTime }

                return tripResult
            }
        tripDelivery.tripResults = filteredTripResults
        return tripDelivery
    }

    public func loadPrevious(numberOfResults: Int) async throws -> OJPv2.TripDelivery {
        guard var request, let minDate else {
            throw OJPSDKError.notImplemented()
        }
        request.at = .departure(minDate)
        return try await loadTrips(for: request, numberOfResults: .before(numberOfResults))
    }

    public func loadNext(numberOfResults: Int) async throws -> OJPv2.TripDelivery {
        guard var request, let maxDate else {
            throw OJPSDKError.notImplemented()
        }
        request.at = .departure(maxDate)
        return try await loadTrips(for: request, numberOfResults: .after(numberOfResults))
    }

    public func reset() {
        minDate = nil
        maxDate = nil
        existingTripHashes = []
    }
}
