//
//  MapKit.h
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef MapKit_obj_h
#define MapKit_obj_h

#include <Cocoa/cocoa.h>
#include <MapKit/MapKit.h>

class MapKitBridge{
    NSView    *ns_view;
    MKMapView *map_view;
public:
    MapKitBridge() : ns_view(nil), map_view(nil){}
    MapKitBridge(void *ns_vw) : MapKitBridge(){
        this->ns_view  = (__bridge NSView*)ns_vw;
        this->map_view = [[MKMapView alloc] initWithFrame:[this->ns_view bounds]];
        
        [this->map_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [this->ns_view addSubview:this->map_view];
    }
    
    ~MapKitBridge(){
        [map_view release];
    }
};

#endif /* MapKit_obj_h */
