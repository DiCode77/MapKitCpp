#include "CyBorder.hpp"
#include "MapKit_obj.h"

void CountryBorder::connect_map(void *map){
    if (this->mk_map == nullptr){
        this->mk_map = map;
    }
}

void CountryBorder::disconnect_map(){
    this->mk_map = nullptr;
}

std::string CountryBorder::loadFile(const std::string &dir){
    std::ifstream file(dir);
    std::string   text;
    
    if (file.is_open()){
        text.assign(std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>());
    }
    
    return text;
}

void CountryBorder::setCountryBorder(const fcountries &city, const std::string &d_json){
    if (!this->um_borders.count(city)){
        void *mkp = this->GetMKPolygon(d_json);
        if (mkp != nullptr){
            this->um_borders.insert(std::make_pair(city, mkp));
            
            MKMapView *_map = reinterpret_cast<MKMapView*>(this->mk_map);
            [_map addOverlay:reinterpret_cast<MKPolygon*>(mkp)];
        }else{
            printf("%s\n", "Error created country border, method 'setCountryBorder(..., ...)'");
        }
    }
}

um_map_poli &CountryBorder::getMapBorders(){
    return this->um_borders;
}


void *CountryBorder::GetMKPolygon(const std::string &d_json){
    if (!d_json.empty()){
        nlohmann::json j_root;
        try {
            j_root = nlohmann::json::parse(d_json);
        } catch (const nlohmann::json::parse_error &error){
            printf("Parse json error: %s\n", error.what());
        }
        
        if (!j_root.empty()){
            if (!j_root.count("features"))
                return nullptr;
            
            auto &feature = j_root["features"][0];
            
            if (!feature.count("geometry"))
                return nullptr;
            
            auto &geometry = feature["geometry"];
            
            if (!geometry.count("coordinates"))
                return nullptr;
            
            auto &location = geometry["coordinates"][0];
            
            std::vector<CLLocationCoordinate2D> vec_location;
            for (auto &point : location){
                vec_location.emplace_back(point[1], point[0]);
            }
            
            return reinterpret_cast<void*>([MKPolygon polygonWithCoordinates:vec_location.data() count:vec_location.size()]);
        }
    }
    return nullptr;
}
