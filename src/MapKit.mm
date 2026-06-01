#include "MapKit.hpp"
#include "MapKit_obj.h"

MapKit::MapKit() : map_bridge(nullptr){};
MapKit::MapKit(void *ns_vw) : MapKit(){
    this->map_bridge = new MapKitBridge(ns_vw);
}

MapKit::MapKit(void *ns_vw, const fpoint &point, const fsize &size){
    this->map_bridge = new MapKitBridge(ns_vw, point, size);
}

MapKit::~MapKit(){
    if (this->map_bridge != nullptr){
        delete this->map_bridge;
    }
}

void MapKit::init(void *ns_vw){}
