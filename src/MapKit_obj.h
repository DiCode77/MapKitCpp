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
#include <CoreLocation/CoreLocation.h>
#include <unordered_map>
#include <functional>
#include <any>
#include "Parameters.hpp"
#include "Visualize.hpp"
#include "AirOoject.h"

using um_map_func = std::unordered_map<ffunc_conn, std::function<void(const std::any&)>>;

@interface MapKitDelegate : NSObject <MKMapViewDelegate, MKLocalSearchCompleterDelegate>
@property(nonatomic, assign) MKLocalSearchCompleter *completer;
@property(nonatomic, assign) um_map_func *um_func;
@property(nonatomic, assign) StPoligon   *m_poligon;
@property(nonatomic, assign) StRegionOf  *m_regions;
@end

class MapKitBridge{
    NSView         *ns_view;
    MKMapView      *map_view;
    NSRect         rect_map;
    MapKitDelegate *mk_delegate;
    Visualize      m_render;
public:
    um_map_func um_func;
public:
    MapKitBridge();
    MapKitBridge(void*, const fpoint&, const fsize&, const fscale&, const fmap_type&);
    ~MapKitBridge();
    
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
    
    double getCenterCordinateDistance();
    
    void connect(const ffunc_conn &isId, std::function<void(const std::any&)>);
    
    Visualize &render();
    
    void setGeocodeLocation(const std::string&);
    void setUpdateCompleter(const std::string&);
    void setCenterCoordinate(const Geodata&, const bool);
    void setCenterCoordinateAndZoom(const Geodata&, const Geodata&, const bool);
    
    float getHeadingCamera();
    void  setHeadingCamera(const float&, const bool);
    void  setPitchCamera(const float&, const bool);
    void  setAltitudeCamera(const float&, const bool);
    
private:
    void CreatedDelegatedMapKitBridge();
    void ConnectToDelegateMethods();
    void InitCompliterTitles();
};

#endif /* MapKit_obj_h */
