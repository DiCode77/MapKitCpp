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
    
    MapKitBridge(void *ns_vw, const fpoint &point, const fsize &size, const fscale &scale) : MapKitBridge(){
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
        
        switch (scale) {
            case fscale::fnone:
                [this->map_view setAutoresizingMask:NSViewNotSizable];
                break;
            case fscale::fnone_fix_point:
                this->rect_map.size.width  -= this->rect_map.origin.x;
                this->rect_map.size.height -= this->rect_map.origin.y;
                
                [this->map_view setFrame:this->rect_map];
                [this->map_view setAutoresizingMask:NSViewNotSizable];
                break;
            case fscale::fauto:
                [this->map_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                break;
            case fscale::fauto_fix_point:
                this->rect_map.size.width  -= this->rect_map.origin.x;
                this->rect_map.size.height -= this->rect_map.origin.y;
                
                [this->map_view setFrame:this->rect_map];
                [this->map_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                break;
            case fscale::fwidth:
                [this->map_view setAutoresizingMask:NSViewWidthSizable];
                break;
            case fscale::fwidth_fix_point:
                this->rect_map.size.width  -= this->rect_map.origin.x;
                
                [this->map_view setFrame:this->rect_map];
                [this->map_view setAutoresizingMask:NSViewWidthSizable];
                break;
            case fscale::fheight:
                [this->map_view setAutoresizingMask:NSViewHeightSizable];
                break;
            case fscale::fheight_fix_point:
                this->rect_map.size.height -= this->rect_map.origin.y;
                
                [this->map_view setFrame:this->rect_map];
                [this->map_view setAutoresizingMask:NSViewHeightSizable];
                break;
        }

        [this->ns_view addSubview:this->map_view];
    }
    
    ~MapKitBridge(){
        [map_view release];
    }
    
    void show(){
        [this->map_view setHidden:NO];
    }
    
    void hide(){
        [this->map_view setHidden:YES];
    }
    
    void setSize(const fsize &size){
        this->rect_map.size = CGSize(size.x, size.y);
        [this->map_view setFrame:this->rect_map];
    }
    
    void setSize_fix_point(const fsize &size){
        this->setSize(fsize(size.x - this->rect_map.origin.x, size.y - this->rect_map.origin.y));
    }
    
    void setPoint(const fpoint &point){
        this->rect_map.origin = CGPoint(point.x, point.y);
        [this->map_view setFrame:this->rect_map];
    }
    
    void set_auto_size(){
        this->rect_map.size = [this->ns_view bounds].size;
        [this->map_view setFrame:this->rect_map];
    }
    
    void set_auto_size_fix_point(){
        this->rect_map.size = [this->ns_view bounds].size;
        
        this->rect_map.size.width -= this->rect_map.origin.x;
        this->rect_map.size.height -= this->rect_map.origin.y;
        
        [this->map_view setFrame:this->rect_map];
    }
};

#endif /* MapKit_obj_h */
