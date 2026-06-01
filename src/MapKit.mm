#include "MapKit.hpp"
#include "MapKit_obj.h"

MapKit::MapKit() : map_bridge(nullptr){};

MapKit::MapKit(void *ns_vw, const fpoint &point, const fsize &size, const fscale &scale, const fmap_type &type){
    this->map_bridge = new MapKitBridge(ns_vw, point, size, scale, type);
}

MapKit::~MapKit(){
    if (this->map_bridge != nullptr){
        delete this->map_bridge;
    }
}

void MapKit::show(){
    this->map_bridge->show();
}

void MapKit::hide(){
    this->map_bridge->hide();
}

bool MapKit::is_show(){
    return this->map_bridge->is_show();
}

void MapKit::setSize(const fsize &size){
    this->map_bridge->setSize(size);
}

void MapKit::setSize_fix_point(const fsize &size){
    this->map_bridge->setSize_fix_point(size);
}

void MapKit::setPoint(const fpoint &point){
    this->map_bridge->setPoint(point);
}

void MapKit::set_auto_size(){
    this->map_bridge->set_auto_size();
}

void MapKit::set_auto_size_fix_point(){
    this->map_bridge->set_auto_size_fix_point();
}

fsize MapKit::getSize(){
    return this->map_bridge->getSize();
}

fpoint MapKit::getPoint(){
    return this->map_bridge->getPoint();
}

void MapKit::setMapType(const fmap_type &type){
    this->map_bridge->setMapType(type);
}
