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

void CountryBorder::clear(){
    this->Destroy();
}

std::string CountryBorder::loadFile(const std::string &dir){
    std::ifstream file(dir);
    std::string   text;
    
    if (file.is_open()){
        text.assign(std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>());
    }
    
    return text;
}

void CountryBorder::setCountryBorder(const fcountries &city, const std::string &d_json, const Colors &colors){
    if (!this->st_poligon.um_borders.count(city)){
        std::vector<std::vector<Geodata>> vec;
        bool mkp = this->GetMKPolygon(vec, d_json);
        
        if (mkp){
            Settled sld;
            um_map_poli &m_pol = this->st_poligon.um_borders;
            um_map_dete &m_det = this->st_poligon.um_detector;
            
            std::ranges::for_each(vec.begin(), vec.end(), [&sld, &m_det, &city](const std::vector<Geodata> &m_vec){
                void *poligon = reinterpret_cast<void*>([[MKPolygon polygonWithCoordinates:(CLLocationCoordinate2D*)m_vec.data() count:m_vec.size()] retain]);
                sld.country.emplace_back(poligon);
                m_det.insert(std::make_pair(poligon, city));
            });
            
            m_pol.insert(std::make_pair(city, Settled{
                .country = std::move(sld.country),
                .name    = this->GetCountryName(d_json),
                .color   = colors
            }));
        }else{
            printf("%s\n", "Error created country border, method 'setCountryBorder(..., ...)'");
        }
    }
}

void CountryBorder::setRegionOffices(const fcountries &coy, const std::string &d_json, const Colors &color){
    if (!this->st_region.region_off.count(coy)){
        std::vector<JsonRegionData> vec;
        
        bool mkp = this->GetMkRegionOf(vec, d_json);
        if (mkp){
            std::vector<RegionOf> reg_vec;
            std::ranges::for_each(vec.begin(), vec.end(), [&reg_vec](JsonRegionData &st_data){
                RegionOf m_region{
                    .sh_name  = std::move(st_data.sh_name),
                    .sh_iso   = std::move(st_data.sh_iso),
                    .sh_id    = std::move(st_data.sh_id),
                    .sh_group = std::move(st_data.sh_group),
                    .sh_type  = std::move(st_data.sh_type)
                };
                
                std::ranges::for_each(st_data.countours.begin(), st_data.countours.end(), [&m_region](const std::vector<std::vector<Geodata>> &level_1){
                    std::ranges::for_each(level_1.begin(), level_1.end(), [&m_region](const std::vector<Geodata> &level_2){
                        m_region.region.emplace_back(reinterpret_cast<void*>([[MKPolygon polygonWithCoordinates:
                                                                               (CLLocationCoordinate2D*)level_2.data()count:level_2.size()] retain]));
                    });
                });
                reg_vec.emplace_back(m_region);
            });
            
            if (!reg_vec.empty()){
                std::ranges::for_each(reg_vec.begin(), reg_vec.end(), [&](RegionOf &reg_data){
                    std::ranges::for_each(reg_data.region.begin(), reg_data.region.end(), [&](void *data){
                        this->st_region.detect_reg.insert(std::make_pair(data, coy));
                    });
                });
                
                this->st_region.region_off.insert(std::make_pair(coy, std::move(reg_vec)));
            }else{
                printf("%s\n", "Unable to retrieve the information, mthod: 'setRegionOffices(..., ..., ...)'");
            }
        }
        else{
            printf("%s\n", "Error created country border, method 'setRegionOffices(..., ..., ...)'");
        }
    }
}

um_map_poli &CountryBorder::getMapBorders(){
    return this->st_poligon.um_borders;
}

um_map_dete &CountryBorder::getMapDetector(){
    return this->st_poligon.um_detector;
}

StPoligon &CountryBorder::getStPoligon(){
    return this->st_poligon;
}

StRegionOf &CountryBorder::getStRegionOf(){
    return this->st_region;
}

void CountryBorder::show_boundary(const fcountries &cnt){
    if (auto it = this->st_poligon.um_borders.find(cnt); it != this->st_poligon.um_borders.end()){
        if (it->second.visible == false){
            it->second.visible = true;
            
            MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
            const auto &c_vec = it->second.country;
            
            std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
            });
        }
        
    }
}

void CountryBorder::hide_boundary(const fcountries &cnt){
    if (auto it = this->st_poligon.um_borders.find(cnt); it != this->st_poligon.um_borders.end()){
        if (it->second.visible == true){
            it->second.visible = false;
            
            MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
            const auto &c_vec = it->second.country;
            
            std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
            });
        }
        
    }
}

bool CountryBorder::is_show(const fcountries &coy){
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.visible;
    }
    return false;
}

void CountryBorder::set_color_boundery(const fcountries &coy, const Colors &color){
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        if (Colors &m_color = it->second.color; m_color != color){
            m_color = color;
            
            if (it->second.visible){
                MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
                const auto &c_vec = it->second.country;
                
                std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                    [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
                    [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
                });
            }
        }
    }
}

void CountryBorder::set_fill_color(const fcountries &coy, const Colors &fcolor){
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        if (Colors &m_fcolor = it->second.fill_color; m_fcolor != fcolor){
            m_fcolor = fcolor;
            
            if (it->second.visible){
                MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
                const auto &c_vec = it->second.country;
                
                std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                    [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
                    [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
                });
            }
        }
    }
}

void CountryBorder::set_line_width(const fcountries &coy, const float &lwidth){
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        if (float &m_lwidth = it->second.line_width; m_lwidth != lwidth){
            m_lwidth = lwidth;
            
            if (it->second.visible){
                MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
                const auto &c_vec = it->second.country;
                
                std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                    [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
                    [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
                });
            }
        }
    }
}

Colors CountryBorder::get_color_boundery(const fcountries &coy) const{
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.color;
    }
    return Colors();
}

Colors CountryBorder::get_fill_color(const fcountries &coy) const{
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.fill_color;
    }
    return Colors();
}

float CountryBorder::get_line_width(const fcountries &coy) const{
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.line_width;
    }
    return 0.f;
}

std::string CountryBorder::get_country_name(const fcountries &coy) const{
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.name;
    }
    return std::string();
}

void CountryBorder::Destroy(){
    if (!this->st_poligon.um_detector.empty()){
        auto m_keys = this->st_poligon.um_detector | std::views::keys;
        std::ranges::for_each(m_keys.begin(), m_keys.end(), [](void *k_data){
            [reinterpret_cast<MKPolygon*>(k_data) release];
        });
        
        this->st_poligon.um_borders.clear();
        this->st_poligon.um_detector.clear();
    }
    
    if (!this->st_region.detect_reg.empty()){
        auto m_keys = this->st_region.detect_reg | std::views::keys;
        std::ranges::for_each(m_keys.begin(), m_keys.end(), [](void *k_data){
            [reinterpret_cast<MKPolygon*>(k_data) release];
        });
        
        this->st_region.region_off.clear();
        this->st_region.detect_reg.clear();
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

bool CountryBorder::GetMkRegionOf(std::vector<JsonRegionData> &vec_loc, const std::string &d_json){
    if (!d_json.empty()){
        nlohmann::json j_root;
        try {
            j_root = nlohmann::json::parse(d_json);
        } catch (const nlohmann::json::parse_error &error) {
            printf("Error parsing JSON data while retrieving the country name: %s\n", error.what());
        }
        
        if (!j_root.empty()){
            if (!j_root.count("features"))
                return false;
            
            auto feature = j_root["features"];
            vec_loc.resize(feature.size());
            
            size_t vec_pos = 0;
            std::ranges::for_each(feature.begin(), feature.end(), [&vec_loc, &vec_pos](const nlohmann::json &level_1){
                if (level_1.count("properties") && level_1.count("geometry")){
                    auto prop = level_1["properties"];
                    auto geom = level_1["geometry"];
                    auto &regn = vec_loc[vec_pos];
                    
                    regn.sh_name.assign(prop["shapeName"].get<std::string>());
                    regn.sh_iso.assign(prop["shapeISO"].get<std::string>());
                    regn.sh_id.assign(prop["shapeID"].get<std::string>());
                    regn.sh_group.assign(prop["shapeGroup"].get<std::string>());
                    regn.sh_type.assign(prop["shapeType"].get<std::string>());
                    
                    std::string type = geom["type"].get<std::string>();
                    
                    if (type == "Polygon"){
                        if (geom.count("coordinates")){
                            auto coord = geom["coordinates"];
                            regn.countours.resize(coord.size());
                            
                            for (size_t i = 0; i < coord.size(); i++){
                                regn.countours.at(i).resize(1);
                            }
                            
                            size_t pos_a = 0;
                            std::ranges::for_each(coord.begin(), coord.end(), [&regn, &pos_a](const nlohmann::json &arr_in){
                                std::ranges::for_each(arr_in.begin(), arr_in.end(), [&regn, &pos_a](const nlohmann::json &arr_c){
                                    regn.countours.at(pos_a).at(0).emplace_back(static_cast<double>(arr_c[1]), static_cast<double>(arr_c[0]));
                                });
                                pos_a++;
                            });
                        }
                    }else if (type == "MultiPolygon"){
                        if (geom.count("coordinates")){
                            auto coord = geom["coordinates"];
                            regn.countours.resize(coord.size());
                            
                            size_t pos_a = 0;
                            std::ranges::for_each(coord.begin(), coord.end(), [&regn, &pos_a](const nlohmann::json &arr_in_arr){
                                regn.countours.at(pos_a).resize(arr_in_arr.size());
                                
                                size_t pos_b = 0;
                                std::ranges::for_each(arr_in_arr.begin(), arr_in_arr.end(), [&regn, &pos_a, &pos_b](const nlohmann::json &arr_c){
                                    std::ranges::for_each(arr_c.begin(), arr_c.end(), [&regn, &pos_a, &pos_b](const nlohmann::json &data){
                                        regn.countours.at(pos_a).at(pos_b).emplace_back(static_cast<double>(data[1]), static_cast<double>(data[0]));
                                    });
                                    pos_b++;
                                });
                                pos_a++;
                            });
                        }
                    }else{
                    }
                    vec_pos++;
                }
            });
        }
        return !vec_loc.empty();
    }
    return false;
}

std::string CountryBorder::GetCountryName(const std::string &json){
    if (!json.empty()){
        nlohmann::json j_root;
        try {
            j_root = nlohmann::json::parse(json);
        } catch (const nlohmann::json::parse_error &error){
            printf("Error parsing JSON data while retrieving the country name: %s\n", error.what());
        }
        
        if (!j_root.empty()){
            if (!j_root.count("features"))
                return std::string();
            
            auto &feature = j_root["features"][0];
            
            if (!feature.count("properties"))
                return std::string();
            
            auto &properties = feature["properties"];
            
            if (!properties.count("shapeName"))
                return std::string();
            
            return properties["shapeName"].get<std::string>();
        }
    }
    return std::string();
}
