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
#include "Parameters.hpp"

class MapKitBridge{
    NSView    *ns_view;
    MKMapView *map_view;
    NSRect     rect_map;
public:
    MapKitBridge() : ns_view(nil), map_view(nil), rect_map(NSMakeRect(-1, -1, -1, -1)){}
    MapKitBridge(void *ns_vw) : MapKitBridge(){
        this->ns_view  = (__bridge NSView*)ns_vw;
        this->rect_map = [this->ns_view bounds];
        this->map_view = [[MKMapView alloc] initWithFrame:this->rect_map];
        
        [this->map_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [this->ns_view addSubview:this->map_view];
    }
    
    MapKitBridge(void *ns_vw, const fpoint &point, const fsize &size) : MapKitBridge(){
        this->ns_view  = (__bridge NSView*)ns_vw;
        this->rect_map = [this->ns_view bounds];
        
        if (point != fPointDefault){
            this->rect_map.origin.x = point.x;
            this->rect_map.origin.y = point.y;
        }
        
        if (size != fSizeDefault){
            this->rect_map.size.width  = size.x;
            this->rect_map.size.height = size.y;
        }
        
        this->map_view = [[MKMapView alloc] initWithFrame:this->rect_map];
        
        [this->map_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [this->ns_view addSubview:this->map_view];
    }
    
    ~MapKitBridge(){
        [map_view release];
    }
};

#endif /* MapKit_obj_h */
