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
    MapKit(void*, const fpoint& = fPointDefault, const fsize& = fSizeDefault);
    ~MapKit();
    
    void init(void*);
};

#endif /* MapKit_hpp */
