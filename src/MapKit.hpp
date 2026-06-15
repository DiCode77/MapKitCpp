//
//  MapKit.hpp
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef MapKit_hpp
#define MapKit_hpp

#include <functional>
#include <any>
#include "Parameters.hpp"
#include "Visualize.hpp"

class MapKitBridge;
class MapKit{
    MapKitBridge *map_bridge;
public:
    MapKit();
    MapKit(void*, const fpoint& = fPointDefault, const fsize& = fSizeDefault, const fscale& = fscale::fauto, const fmap_type& = fmap_type::standard);
    ~MapKit();
    
    void show();   // Show map.
    void hide();   // Hide map
    bool is_show();
    
    void setSize(const fsize&);
    void setSize_fix_point(const fsize&);
    void setPoint(const fpoint&);
    void set_auto_size();
    void set_auto_size_fix_point();
    
    fsize  getSize();
    fpoint getPoint();
    
    void setMapType(const fmap_type&);             // Select the map type.
 
    void enable_buildings(const bool&);            // Shows houses.
    void enable_traffic(const bool&);              // Shows traffic conditions.
    void enable_scale(const bool&);                // Shows the map scale.
    void enable_compass(const bool&);              // The compass shows.
    void enable_pitch_control(const bool&);        // Displays the map tilt button.
    void enable_user_location(const bool&);        // Shows the user's location.
    void enable_zoom_controls(const bool&);        // Displays the standard macOS zoom buttons.
    void enable_points_of_interest(const bool&);   // Displays POIs (Points of Interest). Displays airplanes, stores, and more.
    void enable_user_tracking_button(const bool&); // Shows the finished Apple geolocation button:
    
    double getCenterCordinateDistance();           // Returns the map scale in meters.
    
    void connect(const ffunc_conn&, std::function<void(const std::any&)>); // To implement delegating methods.
    
    Visualize &render();
    
    void setGeocodeLocation(const std::string&);
    void setUpdateCompleter(const std::string&);
    void setCenterCoordinate(const Geodata&, const bool = true); // move the map's focus to the desired coordinates.
    void setCenterCoordinateAndZoom(const Geodata&, const Geodata&, const bool = true);
    
    float getHeadingCamera(); // Determine the angle of rotation.
    void  setHeadingCamera(const float&, const bool = true); // Set the rotation angle to a minimum of 0 degrees and a maximum of 360 degrees.
    void  setPitchCamera(const float&, const bool = true);   // Set the camera's angle relative to the object.
    void  setAltitudeCamera(const float&, const bool = true); // To set the height of the chamber.
};

#endif /* MapKit_hpp */
