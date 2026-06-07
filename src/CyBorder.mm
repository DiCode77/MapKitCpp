#include "CyBorder.hpp"
#include "MapKit_obj.h"

CountryBorder::~CountryBorder(){
    this->Destroy();
}

void CountryBorder::connect_map(void *map){
    if (this->mk_map == nullptr){
        this->mk_map = map;
    }
}

void CountryBorder::disconnect_map(){
    this->Destroy();
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
        std::vector<std::vector<Geodata>> vec;
        bool mkp = this->GetMKPolygon(vec, d_json);
        
        if (mkp){
            Settled sld;
            
            for (auto it = vec.begin(); it != vec.end(); it++){
                sld.country.emplace_back(reinterpret_cast<void*>([[MKPolygon polygonWithCoordinates:(CLLocationCoordinate2D*)it->data() count:it->size()] retain]));
            }
            this->um_borders.insert(std::make_pair(city, Settled{ .country = std::move(sld.country) }));
        }else{
            printf("%s\n", "Error created country border, method 'setCountryBorder(..., ...)'");
        }
    }
}

um_map_poli &CountryBorder::getMapBorders(){
    return this->um_borders;
}

void CountryBorder::show_boundary(const fcountries &cnt){
    if (auto it = this->um_borders.find(cnt); it != this->um_borders.end()){
        if (it->second.visible == false){
            it->second.visible = true;
            MKMapView *map = reinterpret_cast<MKMapView*>(this->mk_map);
            
            for (auto p_it = it->second.country.begin(); p_it != it->second.country.end(); p_it++){
                MKPolygon *pl = reinterpret_cast<MKPolygon*>(*p_it);
                [map addOverlay:pl];
            }
        }
        
    }
}

void CountryBorder::hide_boundary(const fcountries &cnt){
    if (auto it = this->um_borders.find(cnt); it != this->um_borders.end()){
        if (it->second.visible == true){
            it->second.visible = false;
            MKMapView *map = reinterpret_cast<MKMapView*>(this->mk_map);
            
            for (auto p_it = it->second.country.begin(); p_it != it->second.country.end(); p_it++){
                MKPolygon *pl = reinterpret_cast<MKPolygon*>(*p_it);
                [map removeOverlay:pl];
            }
        }
        
    }
}

void CountryBorder::set_color_boundery(const Colors &color){}

void CountryBorder::Destroy(){
    if (!this->um_borders.empty()){
        for (auto &[kay, val] : this->um_borders){
            for (auto it = val.country.begin(); it != val.country.end(); it++){
                [reinterpret_cast<MKPolygon*>(*it) release];
            }
        }
        this->um_borders.clear();
    }
}

bool CountryBorder::GetMKPolygon(std::vector<std::vector<Geodata>> &vec_loc, const std::string &d_json){
    if (!d_json.empty()){
        nlohmann::json j_root;
        try {
            j_root = nlohmann::json::parse(d_json);
        } catch (const nlohmann::json::parse_error &error){
            printf("Parse json error: %s\n", error.what());
        }
        
        if (!j_root.empty()){
            if (!j_root.count("features"))
                return false;
            
            auto &feature = j_root["features"][0];
            
            if (!feature.count("geometry"))
                return false;
            
            auto &geometry = feature["geometry"];
            
            if (!geometry.count("coordinates"))
                return false;
            
            std::string type = geometry["type"];
            if (type == "Polygon"){
                auto &location = geometry["coordinates"][0];
                vec_loc.resize(1);
                
                for (auto it = location.begin(); it != location.end(); it++){
                    vec_loc[0].emplace_back((*it)[1], (*it)[0]);
                }
            }else if (type == "MultiPolygon"){
                auto &location = geometry["coordinates"];
        
                for (auto it = location.begin(); it != location.end(); it++){
                    vec_loc.resize(vec_loc.size() +1);
                    
                    for (auto s_it = (*it)[0].begin(); s_it != (*it)[0].end(); s_it++){
                        vec_loc[vec_loc.size() -1].emplace_back((*s_it)[1], (*s_it)[0]);
                    }
                }
            }else{
            }
            
            return !vec_loc.empty();
        }
    }
    return false;
}
