#include "MapKit_obj.h"
#include "MapKit.hpp"

void MapKitBridge::show(){
    [this->map_view setHidden:NO];
}

void MapKitBridge::hide(){
    [this->map_view setHidden:YES];
}

bool MapKitBridge::is_show(){
    return !static_cast<bool>(this->map_view.hidden);
}

void MapKitBridge::setSize(const fsize &size){
    this->rect_map.size = CGSize(size.x, size.y);
    [this->map_view setFrame:this->rect_map];
}

void MapKitBridge::setSize_fix_point(const fsize &size){
    this->setSize(fsize(size.x - this->rect_map.origin.x, size.y - this->rect_map.origin.y));
}

void MapKitBridge::setPoint(const fpoint &point){
    this->rect_map.origin = CGPoint(point.x, point.y);
    [this->map_view setFrame:this->rect_map];
}

void MapKitBridge::set_auto_size(){
    this->rect_map.size = [this->ns_view bounds].size;
    [this->map_view setFrame:this->rect_map];
}

void MapKitBridge::set_auto_size_fix_point(){
    this->rect_map.size = [this->ns_view bounds].size;
    
    this->rect_map.size.width -= this->rect_map.origin.x;
    this->rect_map.size.height -= this->rect_map.origin.y;
    
    [this->map_view setFrame:this->rect_map];
}

fsize MapKitBridge::getSize(){
    return fsize(this->rect_map.size.width, this->rect_map.size.height);
}

fpoint MapKitBridge::getPoint(){
    return fpoint(this->rect_map.origin.x, this->rect_map.origin.y);
}

void MapKitBridge::setMapType(const fmap_type &type){
    switch (type){
        case fmap_type::standard:
            [this->map_view setMapType:MKMapTypeStandard];
            break;
        case fmap_type::sate_llite:
            [this->map_view setMapType:MKMapTypeSatellite];
            break;
        case fmap_type::hybrid:
            [this->map_view setMapType:MKMapTypeHybrid];
            break;
        case fmap_type::sate_llite_flyover:
            [this->map_view setMapType:MKMapTypeSatelliteFlyover];
            break;
        case fmap_type::hybrid_flyover:
            [this->map_view setMapType:MKMapTypeHybridFlyover];
            break;
        case fmap_type::muted_standard:
            [this->map_view setMapType:MKMapTypeMutedStandard];
            break;
    }
}

void MapKitBridge::enable_buildings(const bool &bl){
    [this->map_view setShowsBuildings:bl];
}

void MapKitBridge::enable_traffic(const bool &bl){
    [this->map_view setShowsTraffic:bl];
}

void MapKitBridge::enable_scale(const bool &bl){
    [this->map_view setShowsScale:bl];
}

void MapKitBridge::enable_compass(const bool &bl){
    [this->map_view setShowsCompass:bl];
}

void MapKitBridge::enable_pitch_control(const bool &bl){
    [this->map_view setShowsPitchControl:bl];
}

void MapKitBridge::enable_user_location(const bool &bl){
    [this->map_view setShowsUserLocation:bl];
}

void MapKitBridge::enable_zoom_controls(const bool &bl){
    [this->map_view setShowsZoomControls:bl];
}

void MapKitBridge::enable_points_of_interest(const bool &bl){
    if (bl){
        this->map_view.pointOfInterestFilter = nil;
    }else{
        this->map_view.pointOfInterestFilter = [MKPointOfInterestFilter filterExcludingAllCategories];
    }
}

void MapKitBridge::enable_user_tracking_button(const bool &bl){
    [this->map_view setShowsUserTrackingButton:bl];
}
