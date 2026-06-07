#include "MapKit_obj.h"
#include "MapKit.hpp"

@implementation MapKitDelegate
- (void)mapViewDidChangeVisibleRegion:(MKMapView*)mapView{
    if (self.um_func != nil){
        if (auto it = self.um_func->find(ffunc_conn::m_view_change_region); it != self.um_func->end()){
            it->second(std::make_any<const double&>(static_cast<const double&>(mapView.camera.centerCoordinateDistance)));
        }
    }
}

- (MKOverlayRenderer*) mapView:(MKMapView*)mapView rendererForOverlay: (id<MKOverlay>)overlay{
    if ([overlay isKindOfClass: [MKPolygon class]]){
        MKPolygonRenderer* renderer = [[MKPolygonRenderer alloc] initWithPolygon: (MKPolygon*)overlay];
        if (auto it = self.um_sett->find(reinterpret_cast<void*>(overlay)); it != self.um_sett->end()){
            if (auto p_it = self.um_poli->find(it->second); p_it != self.um_poli->end()){
                Colors &colore = p_it->second.color;
                if (p_it->second.color != Colors()){
                    const Colors &color = p_it->second.color;
                    renderer.strokeColor = [NSColor colorWithCalibratedRed:color.r / 255.0
                                                                     green:color.g / 255.0
                                                                      blue:color.b / 255.0
                                                                     alpha:color.a];
                }else{
                    renderer.strokeColor = [NSColor yellowColor];
                }
            }
        }
        return renderer;
    }
    return nil;
}

@end

MapKitBridge::MapKitBridge() : ns_view(nil), map_view(nil), rect_map(NSMakeRect(-1, -1, -1, -1)), mk_delegate(nil){}
MapKitBridge::MapKitBridge(void *ns_vw, const fpoint &point, const fsize &size, const fscale &scale, const fmap_type &m_type) : MapKitBridge(){
    this->ns_view  = (__bridge NSView*)ns_vw;
    this->rect_map = [this->ns_view bounds];  // We obtain information on size and position.
    
    if (point != fPointDefault){
        this->rect_map.origin.x = point.x;
        this->rect_map.origin.y = point.y;
    }
    
    if (size != fSizeDefault){
        this->rect_map.size.width  = size.x;
        this->rect_map.size.height = size.y;
    }
    
    // Initialize a map with your position and size parameters.
    this->map_view = [[MKMapView alloc] initWithFrame:this->rect_map];
    
    switch (scale) {
        case fscale::fnone: // This setting ignores events related to resizing the main window, both horizontally and vertically.
            [this->map_view setAutoresizingMask:NSViewNotSizable];
            break;
        case fscale::fnone_fix_point: // This is the same as in fnone, but it takes into account any offsets that may have been set manually.
            this->rect_map.size.width  -= this->rect_map.origin.x;
            this->rect_map.size.height -= this->rect_map.origin.y;
            
            [this->map_view setFrame:this->rect_map];
            [this->map_view setAutoresizingMask:NSViewNotSizable];
            break;
        case fscale::fauto: // All horizontal and vertical changes to the main window are taken into account.
            [this->map_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            break;
        case fscale::fauto_fix_point: // Same as fauto, but fpoint changes are also taken into account.
            this->rect_map.size.width  -= this->rect_map.origin.x;
            this->rect_map.size.height -= this->rect_map.origin.y;
            
            [this->map_view setFrame:this->rect_map];
            [this->map_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            break;
        case fscale::fwidth: // Allow horizontal resizing.
            [this->map_view setAutoresizingMask:NSViewWidthSizable];
            break;
        case fscale::fwidth_fix_point:
            this->rect_map.size.width  -= this->rect_map.origin.x;
            
            [this->map_view setFrame:this->rect_map];
            [this->map_view setAutoresizingMask:NSViewWidthSizable];
            break;
        case fscale::fheight: // Allow vertical resizing
            [this->map_view setAutoresizingMask:NSViewHeightSizable];
            break;
        case fscale::fheight_fix_point:
            this->rect_map.size.height -= this->rect_map.origin.y;
            
            [this->map_view setFrame:this->rect_map];
            [this->map_view setAutoresizingMask:NSViewHeightSizable];
            break;
    }

    this->setMapType(m_type); // Here we specify the map type.
    this->CreatedDelegatedMapKitBridge();
    this->m_cy_borders.connect_map(reinterpret_cast<void*>(this->map_view));
    [this->ns_view addSubview:this->map_view];
}

MapKitBridge::~MapKitBridge(){
    if (this->mk_delegate != nil){
        this->map_view.delegate = nil;
        [this->mk_delegate release];
        this->mk_delegate = nil;
    }
    
    if (this->map_view != nil){
        [this->map_view release];
        this->map_view = nil;
    }
}

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

double MapKitBridge::getCenterCordinateDistance(){
    return [this->map_view camera].centerCoordinateDistance;
}

void MapKitBridge::connect(const ffunc_conn &isId, std::function<void(const std::any&)> func){
    switch (isId) {
        case ffunc_conn::m_view_change_region:
            if (!this->um_func.count(ffunc_conn::m_view_change_region)){
                this->um_func.insert(std::make_pair(ffunc_conn::m_view_change_region, func));
            }
            break;
    }
}

CountryBorder &MapKitBridge::cy_border(){
    return this->m_cy_borders;
}

void MapKitBridge::CreatedDelegatedMapKitBridge(){
    if (this->mk_delegate == nil){
        this->mk_delegate = [[MapKitDelegate alloc] init];
        this->mk_delegate.um_func = &this->um_func;
        this->mk_delegate.um_poli = &this->cy_border().getMapBorders();
        this->mk_delegate.um_sett = &this->cy_border().getMapDetector();
        this->map_view.delegate = this->mk_delegate;
    }
}
