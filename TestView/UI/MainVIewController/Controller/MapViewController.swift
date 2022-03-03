//
//  MapViewController.swift
//  TestView
//
//  Created by Kai on 2022/2/18.
//

import UIKit
import GoogleMaps
import Alamofire

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    lazy var address: String = ""

    private let fullScreenSize = UIScreen.main.bounds
    private lazy var apiService: ApiService = ApiService()
    private var mapView: GMSMapView = GMSMapView()
    
    private var location: Location = Location(lat: 0, lng: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mapView)
        
//        getCoordinateData2()
        getCoordinateData {
            self.setupMapView()
            self.setupGMSMarker()
            self.setupDelegate()
        }
        
        print("setup delegate Done")
    }
    
    private func getCoordinateData2() {
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&key=\(AppDelegate.googleApiKey)"
        
        print("url is : \(url)")
        
        Alamofire.request(url).responseJSON { response in
            
            if let data = response.data {
                
                let decoder = JSONDecoder()
                if let googleMapGeocodingData = try? decoder.decode(GoogleMapGeocodingData.self, from: data) {
                    
                    if let location = googleMapGeocodingData.results.first?.geometry.location {
                        
                        self.location = location
                    }
                    
                    print("getCoordinate in MapVC done")
                }
                
            } else {
                print("error: \(response.error)")
            }
        }
    }
    
    private func getCoordinateData( completion: @escaping ( () -> () ) ) {
        
        apiService.address = self.address
        apiService.getCoordinateFromApi { [weak self] (googleMapGeocodingData) in
            
            if let location = googleMapGeocodingData.results.first?.geometry.location {
                
                self?.location = location
                completion()
            }
        }
        
        print("finished getCoordinateData()")
    }
    
    private func setupMapView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: location.lat, longitude: location.lng, zoom: 25.0)
        
        mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height), camera: camera)
        
        
        print("lat: \(location.lat) & lng: \(location.lng)")
    }
    
    private func setupGMSMarker() {
        
        //如果座標皆為0則跳出
        let marker: GMSMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng))
        
        marker.map = mapView
        marker.title = "小高拉麵" //TODO
    }
    
    private func setupDelegate() {
        mapView.delegate = self
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("information of marker is tapped")
    }
    
    
    //在想要繼續做街景還是搜尋地址定位
}