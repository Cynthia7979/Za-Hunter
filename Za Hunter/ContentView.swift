//
//  ContentView.swift
//  Za Hunter
//
//  Created by Xia He on 2021/7/31.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.0558,
            longitude: -87.6743),
        span: MKCoordinateSpan(
            latitudeDelta: 0.05,
            longitudeDelta: 0.05)
    )
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var places = [Place]()
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        Map(
            coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode,
            annotationItems: places
        ) { place in
            MapAnnotation(coordinate: place.annotation.coordinate) {
                Marker(mapItem: place.mapItem)
            }
        }
        .onAppear(perform: {
            performSearch(item: "Pizza")
        })
    }
    
    func performSearch(item: String) {
        print("Performing search on: \(item)")
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = item
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let response = response {
                print("Obtained search result of: \(item).")
                for mapItem in response.mapItems {
                    print("\(mapItem)")
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    places.append(Place(annotation: annotation, mapItem: mapItem))
                }
                print("Finishing search request on: \(item). Places: \(places)")
                return
            }
            print("Error: Failure fetching search results. error = \(String(describing: error))")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Place: Identifiable {
    let id = UUID()
    let annotation: MKPointAnnotation
    let mapItem: MKMapItem
}

struct Marker: View {
    var mapItem: MKMapItem
    var body: some View {
        if let url = mapItem.url {
            Link(destination: url, label: {
                Image("pizza")
            })
        } else {
            Image("pizza")
        }
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

