//
//  TripRequestResultView.swift
//  OJPSampleApp
//
//  Created by Lehnherr Reto on 27.06.2024.
//

import Duration
import OJP
import SwiftUI

enum DurationFormatter {
    static var formatter: DateComponentsFormatter {
        let f = DateComponentsFormatter()
        f.unitsStyle = .brief
        f.allowedUnits = [.day, .hour, .minute]
        return f
    }

    static func string(for duration: Duration) -> String {
        formatter.string(from: duration.dateComponents) ?? ""
    }
}

struct TripRequestResultView: View {
    @State var selectedTrip: OJPv2.Trip?

    var results: [OJPv2.TripResult] = []
    var loadPrevious: (() -> Void)?
    var loadNext: (() -> Void)?

    var body: some View {
        HStack {
            ScrollView {
                if results.count > 0 {
                    Button(action: {
                        loadPrevious?()
                    }, label: {
                        Text("Load Previous")
                    })
                }
                LazyVStack(spacing: 0) {
                    ForEach(results) { tripResult in
                        HStack {
                            if let trip = tripResult.trip {
                                if trip.tripHash == selectedTrip?.tripHash {
                                    Color.accentColor.frame(maxWidth: 2)
                                }
                                VStack(alignment: .leading) {
                                    Text(trip.originName)
                                    Text(trip.startTime.formatted())
                                }
                                Spacer()
                                HStack(spacing: 2) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .imageScale(.small)
                                        .foregroundStyle(.secondary)
                                    Text(DurationFormatter.string(for: trip.duration))
                                }
                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text(trip.destinationName)
                                    Text(trip.endTime.formatted())
                                }
                            } else { Text("No Trips found") }
                        }
                        .background(Color.white)
                        .onTapGesture {
                            selectedTrip = tripResult.trip
                        }
                        Divider()
                    }
                    .background(Color.white)
                }
                if results.count > 0 {
                    Button(action: {
                        loadNext?()
                    }, label: {
                        Text("Load Next")
                    })
                }
            }

            if let selectedTrip {
                TripDetailView(trip: selectedTrip)
                    .padding()
                    .frame(maxWidth: 400)
            }
        }
        .frame(minWidth: 300)
    }
}

#Preview {
    AsyncView(
        task: {
            await PreviewMocker.shared.loadTrips()
        },
        state: [],
        content: { t in
            TripRequestResultView(results: t)
        }
    )
}
