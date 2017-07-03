//
//  ViewController.swift
//  ZaHunter
//
//  Created by Wade Sellers on 4/24/17.
//  Copyright © 2017 MobileMakersEDU. All rights reserved.
//

// Links I used when creating this app...
// https://www.youtube.com/watch?v=UyiuX8jULF4


import UIKit
// We use the CoreLocation library/framework to get the users location
import CoreLocation
// We use the MapKit library/framework to create maps
import MapKit

// We will use CoreLocation and MapKit delegate methods below so we declare them in the class declaration here.
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    let manager = CLLocationManager()
    var mapItemsFound = [MKMapItem]()
    var selectedMapItem = MKMapItem()

    // this variable is for our local request later
    var ourRegion = MKCoordinateRegion()

    override func viewDidLoad() {
        super.viewDidLoad()

        // We want to use CLLocationManager delegate functions in this ViewController so we set this ViewController as its delegate
        manager.delegate = self

        // We set mapViewDelegate to self so we can access the annotations when tapped
        mapView.delegate = self
        // How hard do you want the GPS to work? We set it so that we get the most accurate position of the phone
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // We ask the user to give us permission to get their location when the app is in use (current app on screen)
        manager.requestWhenInUseAuthorization()
        // Start gaining GPS position information for the phone
        manager.startUpdatingLocation()

    }

    // Use CoreLocation delegate funcs here.

    // Let's do something everytime our phone's location updates...
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We grab the 1st location in the locations array we get from the function itself.
        let location = locations[0]

        // We create this CLLocationCoordinate with the locations latitude/longitude. DON'T REVERSE THEM!
        let myLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)

        // The span sets how much we will zoom the map to our location. You can play with these numbers and see what happens when you run.
        // The larger the number, the more ZOOMED OUT the map will be.
        let span = MKCoordinateSpanMake(0.75, 0.075)

        // Next, we use those constants to create a region. Yes, I realize it seems like the above was unnecessary but it keeps the code very clean and I will show you that below.
        let region = MKCoordinateRegionMake(myLocationCoordinate, span)

        //This line comes in handy later on
        ourRegion = region

        // Now let's update our map to the region we setup. *You won't see a blue dot on the map because we have to do 1 more thing...*
        mapView.setRegion(region, animated: true)

        // Set showsUserLocation to true to see our blue dot on the map.
        self.mapView.showsUserLocation = true
    }

    // To find all the pizza shops nearby, let's search for it by creating a search function

    func findNearbyPizzaShops() {
        // We use this to request info
        let request = MKLocalSearchRequest()

        // Let's add a term to search for into the request
        request.naturalLanguageQuery = "pizza"

        // We need to give it a region to search in. Let's make the 1 above accessible to this function too...
        request.region = ourRegion

        // Now we can actually make the search happen
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            // *call function in viewDidLoad and look at console to see pizza shops coming in.
            //------------------ BREAK ------------

            // Okay we have the items, let's get them on the map now.

            // first let stop if we didn't receive a response
            guard let response = response else {
                return
            }

            // loop through all the mapItems...
            for item in response.mapItems {
                dump(item)
                self.mapItemsFound.append(item)

                // Create the pin (annotation) here...
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name

                // this allows the screen to update WHENEVER the location info comes in
                DispatchQueue.main.async {
                    // This adds the pin (annotation) to the map
                    self.mapView.addAnnotation(annotation)
                }
            }
        }

    }

    // We use this MPMapViewDelegate functions here

    // viewForAnnotation is how we setup the map's red pins (annotations)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't set a pic for the user's location. We will have a blue circle instead.
        if annotation is MKUserLocation {
            return nil
        }

        // We create each annotation "pin" here
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")

        // Like tableviews, these pins are reusable (see the line above, it says "Reusable" right in it)
        // If the pin isn't already setup, we set it up right here
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            // If the annotation is already setup, we just set it to this particular annotation and it's good to go.
            pinView?.annotation = annotation
        }
        // After we have the annotation "pin" all setup, we return it.
        return pinView

    }

    // Here we are waiting until the map loads and knows we are in the world before we go looking for pizza shops
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        // this is our helper function we created for finding pizza shops
        findNearbyPizzaShops()
    }

    // The user selected a pin... let's find the mapItem that pin cooresponds to so we can pass to the next ViewController later.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // We run through all the pizza shop mapItem's we have and look for the 1 that has the same coordinates as the pin the user tapped.
        for item in mapItemsFound {
            if item.placemark.coordinate.latitude == view.annotation?.coordinate.latitude && item.placemark.coordinate.longitude == view.annotation?.coordinate.longitude {
                // We've found the right mapItem so we set it to a global variable so we can use it in another function later.
                selectedMapItem = item
            }
        }

    }

    // The user taps on the "additional info" button in the annotation. Let's send them to the LocationDetailsViewController now
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "showLocationDetailsSegue", sender: nil)
    }

    // The segue is about to happen, let's pass that mapItem they want to see all the information on so we can use its information in LocationDetailsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LocationDetailsViewController {
            // We set a MKMapItem variable in LocationDetailsViewController so we can pass the mapItem we want it to use. This is just like WORDPLAY app.
            destination.mapItemPassed = selectedMapItem
        }
    }

}

