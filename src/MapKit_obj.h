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
    MapKitBridge(void *ns_vw, const fpoint &point, const fsize &size, const fscale &scale, const fmap_type &m_type) : MapKitBridge(){
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

        this->setMapType(m_type);
        [this->ns_view addSubview:this->map_view];
    }
    
    ~MapKitBridge(){
        [this->map_view release];
    }
    
    void show();
    void hide();
    bool is_show();
    
    void setSize(const fsize &size);
    void setSize_fix_point(const fsize &size);
    void setPoint(const fpoint &point);
    void set_auto_size();
    void set_auto_size_fix_point();
    
    fsize  getSize();
    fpoint getPoint();
    
    void setMapType(const fmap_type&);
    void enable_buildings(const bool&);
    void enable_traffic(const bool&);
    void enable_scale(const bool&);
    void enable_compass(const bool&);
    void enable_pitch_control(const bool&);
    void enable_user_location(const bool&);
    void enable_zoom_controls(const bool&);
    void enable_points_of_interest(const bool&);
    void enable_user_tracking_button(const bool&);
};

#endif /* MapKit_obj_h */
