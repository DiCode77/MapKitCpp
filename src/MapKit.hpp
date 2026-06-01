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
    MapKit(void*);
    MapKit(void*, const fpoint& = fPointDefault, const fsize& = fSizeDefault, const fscale & = fscale::fauto);
    ~MapKit();
    
    void show();
    void hide();
    void setSize(const fsize&);
    void setSize_fix_point(const fsize&);
    void setPoint(const fpoint&);
    void set_auto_size();
    void set_auto_size_fix_point();
};

#endif /* MapKit_hpp */
