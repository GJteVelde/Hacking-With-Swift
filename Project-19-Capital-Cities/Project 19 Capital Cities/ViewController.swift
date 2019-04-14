//
//  ViewController.swift
//  Project 19 Capital Cities
//
//  Created by Gerjan te Velde on 25/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var annotations: [Capital]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.", isFavorite: false)
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.", isFavorite: true)
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.", isFavorite: true)
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.", isFavorite: false)
        let washington = Capital(title: "Washington", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.", isFavorite: false)
        
        annotations = [london, oslo, paris, rome, washington]
        mapView.addAnnotations(annotations)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(changeMapAppearance))
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Capital"
        
        if annotation is Capital {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let calloutButton = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = calloutButton
                
                let favoriteButton = UIButton(type: .custom)
                favoriteButton.frame.size = calloutButton.frame.size
                favoriteButton.layer.cornerRadius = favoriteButton.frame.size.width / 2
                favoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
                favoriteButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.fill
                favoriteButton.contentEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -6, right: -10)
                annotationView!.leftCalloutAccessoryView = favoriteButton
            } else {
                annotationView!.annotation = annotation
            }
            
            let capital = annotation as! Capital

            let favoriteButton = annotationView?.leftCalloutAccessoryView as! UIButton
            
            if capital.isFavorite {
                annotationView?.pinTintColor = UIColor.green
                favoriteButton.setTitle("-", for: .normal)
                favoriteButton.backgroundColor = UIColor.red
                favoriteButton.tintColor = UIColor.white
            } else {
                annotationView?.pinTintColor = UIColor.red
                favoriteButton.setTitle("+", for: .normal)
                favoriteButton.backgroundColor = UIColor.green
                favoriteButton.tintColor = UIColor.white
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let capital = view.annotation as! Capital
        
        if view.rightCalloutAccessoryView == control {
            let placeName = capital.title
            let placeInfo = capital.info
            
            let alertController = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        } else {
            if let index = annotations.index(of: capital) {
                let selectedAnnotation = annotations[index]
                mapView.removeAnnotation(annotations[index])
                selectedAnnotation.isFavorite = !selectedAnnotation.isFavorite
                mapView.addAnnotation(annotations[index])
            }
        }
    }
 
    @objc func changeMapAppearance() {
        let alertController = UIAlertController(title: "Change map appearance", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { (_) in
            self.mapView.mapType = .satellite
        }))
        alertController.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { (_) in
            self.mapView.mapType = .hybrid
        }))
        alertController.addAction(UIAlertAction(title: "Standard", style: .default, handler: { (_) in
            self.mapView.mapType = .standard
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
}

