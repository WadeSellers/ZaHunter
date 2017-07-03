//
//  LocationDetailsViewController.swift
//  ZaHunter
//
//  Created by Wade Sellers on 5/3/17.
//  Copyright © 2017 MobileMakersEDU. All rights reserved.
//

import UIKit
// We import MapKit so we can use MKMapItems on this ViewController
import MapKit
// We import the SafariServices library/framework so we can create a SafariViewController
import SafariServices

class LocationDetailsViewController: UIViewController {

    @IBOutlet weak var pizzaShopNameLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var zipCodeLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!

    // We set this variable to public so the 1st ViewController has access to it and can pass us the MKMapItem we want to use here.
    public var mapItemPassed: MKMapItem?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // We use viewWillAppear to make sure all the UI Elements have been created so we have access to them for sure!
    override func viewWillAppear(_ animated: Bool) {
        setPizzaShopLabels()

        // If we have a website address for the mapItem, set the buttons label to the address
        if let mapItemURL = mapItemPassed?.url {
            websiteButton.setTitle(mapItemURL.absoluteString, for: .normal)
        } else {
            // If there is no website, hide the button so it can't be tapped
            websiteButton.isHidden = true
        }
    }

    func setPizzaShopLabels() {
        // If we have a mapItem, let's take info from it and set some labels up
        guard let pizzaShop = mapItemPassed else {
            return
        }
        // We get access to the mapItem info through the placemark object inside it
        let placemark = pizzaShop.placemark
        // The placemark object has a dictionary holding the pieces of information we want to get access to
        if let addressDictionary = placemark.addressDictionary {
            // ***Be careful here!  Those dictionary key strings are CASE-SENSITIVE***
            pizzaShopNameLabel.text = addressDictionary["Name"] as? String
            streetAddressLabel.text = addressDictionary["Street"] as? String
            cityLabel.text = addressDictionary["City"] as? String
            stateLabel.text = addressDictionary["State"] as? String
            zipCodeLabel.text = addressDictionary["ZIP"] as? String
        }

        // The phone number is kept in the mapItem itself but it is optional so we need to check to make sure we have 1
        guard let mapItemPassed = mapItemPassed else { return }
        
        if mapItemPassed.phoneNumber != nil {
            // If we have a phone number, we'll set it here
            phoneNumberLabel.text = mapItemPassed.phoneNumber
        } else {
            // if no phone number, we let the user know here.
            phoneNumberLabel.text = "No Ph. # Available"
        }

    }

    // When the user taps on the Get Directions, we will tell the phone to open Apple Maps and show driving directions to the pizza shop
    @IBAction func onGetDirectionsButtonTapped(_ sender: UIButton) {
        // Launching options are used to tell Apple Maps we want driving directions to display 1st
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

        // We tell the phone to open Apple Maps and give it the mapItem we want to display along with the driving directions launch options from above.
        MKMapItem.openMaps(with: [mapItemPassed!], launchOptions: launchOptions)
    }

    // If the mapItem has a website, let's open a Safari window with the website
    @IBAction func onWebsiteButtonTapped(_ sender: UIButton) {
        // Create a SafariViewController and give it the website URL of the mapItem
        let safariViewController = SFSafariViewController(url: (mapItemPassed?.url)!)

        // Now we show the SafariViewController. We automatically get a "done" button to dismiss it so we don't have to worry about anything else.
        self.present(safariViewController, animated: true, completion: nil)
    }
}
