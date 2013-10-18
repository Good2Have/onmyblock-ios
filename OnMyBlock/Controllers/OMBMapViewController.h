//
//  OMBMapViewController.h
//  OnMyBlock
//
//  Created by Tommy DANGerous on 10/18/13.
//  Copyright (c) 2013 OnMyBlock. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "OMBViewController.h"

#import "OCMapView.h"

@interface OMBMapViewController : OMBViewController
<CLLocationManagerDelegate, MKMapViewDelegate>
{
  CLLocationManager *locationManager;
  OCMapView *mapView;
}

@end
