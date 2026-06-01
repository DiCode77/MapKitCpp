//
//  MapKit.hpp
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef MapKit_hpp
#define MapKit_hpp

#include "Parameters.hpp"

class MapKitBridge;
class MapKit{
    MapKitBridge *map_bridge;
public:
    MapKit();
    MapKit(void*, const fpoint& = fPointDefault, const fsize& = fSizeDefault, const fscale& = fscale::fauto, const fmap_type& = fmap_type::standard);
    ~MapKit();
    
    void show();
    void hide();
    bool is_show();
    
    void setSize(const fsize&);
    void setSize_fix_point(const fsize&);
    void setPoint(const fpoint&);
    void set_auto_size();
    void set_auto_size_fix_point();
    
    fsize  getSize();
    fpoint getPoint();
    
    void setMapType(const fmap_type&);
};

#endif /* MapKit_hpp */
