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

void MapKit::enable_buildings(const bool &bl){
    this->map_bridge->enable_buildings(bl);
}

void MapKit::enable_traffic(const bool &bl){
    this->map_bridge->enable_traffic(bl);
}

void MapKit::enable_scale(const bool &bl){
    this->map_bridge->enable_scale(bl);
}

void MapKit::enable_compass(const bool &bl){
    this->map_bridge->enable_compass(bl);
}

void MapKit::enable_pitch_control(const bool &bl){
    this->map_bridge->enable_pitch_control(bl);
}

void MapKit::enable_user_location(const bool &bl){
    this->map_bridge->enable_user_location(bl);
}

void MapKit::enable_zoom_controls(const bool &bl){
    this->map_bridge->enable_zoom_controls(bl);
}

void MapKit::enable_points_of_interest(const bool &bl){
    this->map_bridge->enable_points_of_interest(bl);
}

void MapKit::enable_user_tracking_button(const bool &bl){
    this->map_bridge->enable_user_tracking_button(bl);
}

double MapKit::getCenterCordinateDistance(){
    return this->map_bridge->getCenterCordinateDistance();
}

void MapKit::connect(const ffunc_conn &id, std::function<void(const std::any&)> func){
    this->map_bridge->connect(id, func);
}

Visualize &MapKit::render(){
    return this->map_bridge->render();
}

void MapKit::setGeocodeLocation(const std::string &name){
    this->map_bridge->setGeocodeLocation(name);
}

void MapKit::setUpdateCompleter(const std::string &name){
    this->map_bridge->setUpdateCompleter(name);
}

void MapKit::setCenterCoordinate(const Geodata &data, const bool status){
    this->map_bridge->setCenterCoordinate(data, status);
}

void MapKit::setCenterCoordinateAndZoom(const Geodata &data, const Geodata &zoom, const bool status){
    this->map_bridge->setCenterCoordinateAndZoom(data, zoom, status);
}

float MapKit::getHeadingCamera(){
    return this->map_bridge->getHeadingCamera();
}

void MapKit::setHeadingCamera(const float &ht, const bool status){
    this->map_bridge->setHeadingCamera(ht, status);
}

void MapKit::setPitchCamera(const float &ht, const bool status){
    this->map_bridge->setPitchCamera(ht, status);
}

void MapKit::setAltitudeCamera(const float &ht, const bool status){
    this->map_bridge->setAltitudeCamera(ht, status);
}
