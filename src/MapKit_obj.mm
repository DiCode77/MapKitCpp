#include "MapKit_obj.h"
#include "MapKit.hpp"

@implementation MapKitDelegate
- (void)mapViewDidChangeVisibleRegion:(MKMapView*)mapView{
    if (self.um_func != nil){
        if (auto it = self.um_func->find(ffunc_conn::evt_height_changed); it != self.um_func->end()){
            it->second(std::make_any<const double&>(static_cast<const double&>(mapView.camera.centerCoordinateDistance)));
        }
    }
}

- (MKOverlayRenderer*) mapView:(MKMapView*)mapView rendererForOverlay: (id<MKOverlay>)overlay{
    if ([overlay isKindOfClass: [MKPolygon class]]){
        MKPolygonRenderer* renderer = [[MKPolygonRenderer alloc] initWithPolygon: (MKPolygon*)overlay];
        if (auto it = self.m_poligon->um_detector.find(reinterpret_cast<void*>(overlay)); it != self.m_poligon->um_detector.end()){
            if (auto p_it = self.m_poligon->um_borders.find(it->second); p_it != self.m_poligon->um_borders.end()){
                const Colors &color = p_it->second.prop.color_border;
                if (color != Colors()){
                    renderer.strokeColor = [NSColor colorWithCalibratedRed:color.r / 255.0
                                                                     green:color.g / 255.0
                                                                      blue:color.b / 255.0
                                                                     alpha:color.a];
                }else{
                    renderer.strokeColor = [NSColor yellowColor];
                }
                
                const Colors &fill_colore = p_it->second.prop.color_fill;
                if (fill_colore != Colors()){
                    renderer.fillColor = [NSColor colorWithCalibratedRed:fill_colore.r / 255.0
                                                                   green:fill_colore.g / 255.0
                                                                    blue:fill_colore.b / 255.0
                                                                   alpha:fill_colore.a];
                }
                else{
                    renderer.fillColor = nil;
                }
                
                const float &lwidth = p_it->second.prop.line_width;
                const float lw_def  = 1.0f;
                if (lwidth != lw_def){
                    renderer.lineWidth = lwidth;
                }else{
                    renderer.lineWidth = lw_def;
                }
            }
        }
        else if (auto it = self.m_regions->detect_reg.find(reinterpret_cast<void*>(overlay)); it != self.m_regions->detect_reg.end()){
            if (auto m_it = self.m_regions->region_off.find(it->second); m_it != self.m_regions->region_off.end()){
                for (std::vector<GeoInfo>::iterator geo = m_it->second.begin(); geo != m_it->second.end(); geo++){
                    auto find_it = std::ranges::find_if(geo->ritems.begin(), geo->ritems.end(), [&overlay](const void *data){
                        return data == reinterpret_cast<void*>(overlay);
                    });
                    
                    if (find_it != geo->ritems.end()){
                        const Colors &color = geo->prop.color_border;
                        if (color != Colors()){
                            renderer.strokeColor = [NSColor colorWithCalibratedRed:color.r / 255.0
                                                                             green:color.g / 255.0
                                                                              blue:color.b / 255.0
                                                                             alpha:color.a];
                        }else{
                            renderer.strokeColor = [NSColor yellowColor];
                        }
                        
                        const Colors &fill_color = geo->prop.color_fill;
                        if (fill_color != Colors()){
                            renderer.fillColor = [NSColor colorWithCalibratedRed:fill_color.r / 255.0
                                                                           green:fill_color.g / 255.0
                                                                            blue:fill_color.b / 255.0
                                                                           alpha:fill_color.a];
                        }else{
                            renderer.fillColor = nil;
                        }
                        
                        const float &width = geo->prop.line_width;
                        const float lw_def  = 1.0f;
                        if (width != lw_def){
                            renderer.lineWidth = width;
                        }else{
                            renderer.lineWidth = lw_def;
                        }
                    }
                }
            }
        }else{
        }
        return renderer;
    }
    return nil;
}

typedef void (^CoordinateCallback)(double, double);
- (void)findCity:(NSString*)city completion:(CoordinateCallback)completion{
    MKLocalSearchRequest  *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = city;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (error || response.mapItems.count == 0){
            completion(0.f, 0.f);
        }else{
            MKMapItem *item = response.mapItems.firstObject;
            completion(item.location.coordinate.latitude, item.location.coordinate.longitude);
        }
    }];
}

- (void)completerDidUpdateResults:(MKLocalSearchCompleter*)completer{
    if (auto it = self.um_func->find(ffunc_conn::evt_update_completer); it != self.um_func->end()){
        std::vector<std::pair<std::string, std::string>> vec(static_cast<size_t>(completer.results.count));
        for (size_t i = 0; i < vec.size(); i++){
            vec[i] = std::make_pair([completer.results[i].title UTF8String], [completer.results[i].subtitle UTF8String]);
        }
        it->second(std::make_any<std::vector<std::pair<std::string, std::string>>>(std::move(vec)));
    }
}

- (void)completer:(MKLocalSearchCompleter*)completer didFailWithError:(NSError*)error{
    if (auto it = self.um_func->find(ffunc_conn::evt_update_completer); it != self.um_func->end()){
        it->second(std::make_any<std::vector<std::pair<std::string, std::string>>>());
    }
}

- (void)dealloc{
    if (self.completer != nil){
        self.completer.delegate = nil;
        [self.completer release];
        self.completer = nil;
    }
    [super dealloc];
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
    this->ConnectToDelegateMethods();
    this->m_render.connect(reinterpret_cast<void*>(this->map_view));
    [this->ns_view addSubview:this->map_view];
}

MapKitBridge::~MapKitBridge(){
    if (this->mk_delegate != nil){
        this->map_view.delegate = nil;
        [this->mk_delegate release];
        this->mk_delegate = nil;
    }
    
    if (this->map_view != nil){
        [this->map_view removeFromSuperview];
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
        case ffunc_conn::evt_height_changed:
            if (!this->um_func.count(ffunc_conn::evt_height_changed)){
                this->um_func.insert(std::make_pair(ffunc_conn::evt_height_changed, func));
            }
            break;
        case ffunc_conn::evt_geocode_location:
            if (!this->um_func.count(ffunc_conn::evt_geocode_location)){
                this->um_func.insert(std::make_pair(ffunc_conn::evt_geocode_location, func));
            }
            break;
        case ffunc_conn::evt_update_completer:
            if (!this->um_func.count(ffunc_conn::evt_update_completer)){
                this->um_func.insert(std::make_pair(ffunc_conn::evt_update_completer, func));
                this->InitCompliterTitles();
            }
            break;
    }
}

Visualize &MapKitBridge::render(){
    return this->m_render;
}

// This is an asynchronous method; the response will be received after a period of time.
void MapKitBridge::setGeocodeLocation(const std::string &t_name){
    if (auto it = this->um_func.find(ffunc_conn::evt_geocode_location); it != this->um_func.end()){
        [this->mk_delegate findCity:[NSString stringWithUTF8String:t_name.c_str()] completion:^(double lat, double lon){
            it->second(std::make_any<Geodata>(Geodata(lat, lon)));
        }];
    }
}

void MapKitBridge::setUpdateCompleter(const std::string &name){
    if (auto it = this->um_func.find(ffunc_conn::evt_update_completer); it != this->um_func.end()){
        if (this->mk_delegate.completer != nil){
            this->mk_delegate.completer.queryFragment = [NSString stringWithUTF8String:name.c_str()];
        }
    }
}

void MapKitBridge::setCenterCoordinate(const Geodata &data, const bool status){
    CLLocationCoordinate2D coord;
    coord.latitude  = data.x;
    coord.longitude = data.y;
    
    [this->map_view setCenterCoordinate:coord animated:YES];
}

void MapKitBridge::setCenterCoordinateAndZoom(const Geodata &data, const Geodata &zoom, const bool status){
    CLLocationCoordinate2D coord;
    coord.latitude  = data.x;
    coord.longitude = data.y;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, zoom.x, zoom.y);
    [this->map_view setRegion:region animated:status];
}

float MapKitBridge::getHeadingCamera(){
    if (this->map_view != nullptr)
        return static_cast<float>(this->map_view.camera.heading);
    return 0.f;
}

void MapKitBridge::setHeadingCamera(const float &m_camera, const bool status){
    if (this->map_view != nullptr){
        if (status){
            MKMapCamera *camera = [this->map_view.camera copy];
            camera.heading = m_camera;
            [this->map_view setCamera:camera animated:YES];
            [camera release];
        }else{
            [this->map_view.camera setHeading:m_camera];
        }
    }
}

void MapKitBridge::setPitchCamera(const float &m_camera, const bool status){
    if (this->map_view != nullptr){
        if (status){
            MKMapCamera *camera = [this->map_view.camera copy];
            camera.pitch = m_camera;
            [this->map_view setCamera:camera animated:YES];
            [camera release];
        }else{
            [this->map_view.camera setHeading:m_camera];
        }
    }
}

void MapKitBridge::setAltitudeCamera(const float &m_camera, const bool status){
    if (this->map_view != nullptr){
        if (status){
            MKMapCamera *camera = [this->map_view.camera copy];
            camera.altitude = m_camera;
            [this->map_view setCamera:camera animated:YES];
            [camera release];
        }else{
            [this->map_view.camera setAltitude:m_camera];
        }
    }
}

void MapKitBridge::CreatedDelegatedMapKitBridge(){
    if (this->mk_delegate == nil){
        this->mk_delegate = [[MapKitDelegate alloc] init];
        this->map_view.delegate = this->mk_delegate;
    }
}

void MapKitBridge::ConnectToDelegateMethods(){
    if (this->mk_delegate != nil){
        this->mk_delegate.um_func = &this->um_func;
        this->mk_delegate.m_poligon = &this->render().country().get_st_poligon();
        this->mk_delegate.m_regions = &this->render().region().get_st_region();
    }
}

void MapKitBridge::InitCompliterTitles(){
    if (this->mk_delegate.completer == nil){
        this->mk_delegate.completer = [[MKLocalSearchCompleter alloc] init]; // Memory allocation is managed by the delegate's destructor.
        this->mk_delegate.completer.delegate = this->mk_delegate;
    }
}
