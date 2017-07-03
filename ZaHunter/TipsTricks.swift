//
//  TipsTricks.swift
//  ZaHunter
//
//  Created by Wade Sellers on 4/26/17.
//  Copyright © 2017 MobileMakersEDU. All rights reserved.
//

/*
 Things I thought of when creating this app for you.
 
 Remember... 
    *CoreLocation is used to get phone's location in the world.
    *MapKit is used to show stuff on map like user location, business, directions, etc.

 
 How do you get the phone's location so you can show it on the map???   
    You use CoreLocation. Add it as a linked library "target -> Build Phases -> Linked Binary Libraries"
 Also, add a line in PList...
    Exactly like this (case sensitive!)... "Privacy - Location When In Use Usage Description" and then a message you want the user to see.
 Then... we use CLLocationManager in the ViewController to get access to the location of the device
 
 
 */
