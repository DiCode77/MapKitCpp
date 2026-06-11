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

void CountryBorder::clear_entire_map(){
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
        JsonPoligonData st_poligon;
        bool mkp = this->GetMKPolygon(st_poligon, d_json);
        
        if (mkp){
            GeoInfo sld;
            um_map_poli &m_pol = this->st_poligon.um_borders;
            um_map_dete &m_det = this->st_poligon.um_detector;
            auto &vec = st_poligon.country;
            auto &ent = st_poligon.entries;
            
            std::ranges::for_each(vec.begin(), vec.end(), [&sld, &m_det, &city](const std::vector<Geodata> &m_vec){
                void *poligon = reinterpret_cast<void*>([[MKPolygon polygonWithCoordinates:(CLLocationCoordinate2D*)m_vec.data() count:m_vec.size()] retain]);
                sld.ritems.emplace_back(poligon);
                m_det.insert(std::make_pair(poligon, city));
            });
            
            m_pol.insert(std::make_pair(city, GeoInfo{
                .ritems  = std::move(sld.ritems),
                .entries = {
                    .sh_name  = std::move(ent.sh_name),
                    .sh_iso   = std::move(ent.sh_iso),
                    .sh_id    = std::move(ent.sh_id),
                    .sh_group = std::move(ent.sh_group),
                    .sh_type  = std::move(ent.sh_type)
                },
                .prop = {
                    .color_border = colors
                }
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
            std::vector<GeoInfo> reg_vec;
            std::ranges::for_each(vec.begin(), vec.end(), [&reg_vec](JsonRegionData &st_data){
                GeoInfo m_region{
                    .entries = {
                        .sh_name  = std::move(st_data.entries.sh_name),
                        .sh_iso   = std::move(st_data.entries.sh_iso),
                        .sh_id    = std::move(st_data.entries.sh_id),
                        .sh_group = std::move(st_data.entries.sh_group),
                        .sh_type  = std::move(st_data.entries.sh_type)
                    }
                };
                
                std::ranges::for_each(st_data.countours.begin(), st_data.countours.end(), [&m_region](const std::vector<std::vector<Geodata>> &level_1){
                    std::ranges::for_each(level_1.begin(), level_1.end(), [&m_region](const std::vector<Geodata> &level_2){
                        m_region.ritems.emplace_back(reinterpret_cast<void*>([[MKPolygon polygonWithCoordinates:
                                                                               (CLLocationCoordinate2D*)level_2.data()count:level_2.size()] retain]));
                    });
                });
                reg_vec.emplace_back(m_region);
            });
            
            if (!reg_vec.empty()){
                std::ranges::for_each(reg_vec.begin(), reg_vec.end(), [&](GeoInfo &reg_data){
                    std::ranges::for_each(reg_data.ritems.begin(), reg_data.ritems.end(), [&](void *data){
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

StPoligon &CountryBorder::getStPoligon(){
    return this->st_poligon;
}

StRegionOf &CountryBorder::getStRegionOf(){
    return this->st_region;
}

void CountryBorder::show_boundary(const fcountries &cnt){
    if (auto it = this->st_poligon.um_borders.find(cnt); it != this->st_poligon.um_borders.end()){
        if (it->second.prop.visible == false){
            it->second.prop.visible = true;
            
            MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
            const auto &c_vec = it->second.ritems;
            
            std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
            });
        }
        
    }
}

void CountryBorder::hide_boundary(const fcountries &cnt){
    if (auto it = this->st_poligon.um_borders.find(cnt); it != this->st_poligon.um_borders.end()){
        if (it->second.prop.visible == true){
            it->second.prop.visible = false;
            
            MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
            const auto &c_vec = it->second.ritems;
            
            std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
            });
        }
        
    }
}

bool CountryBorder::is_show(const fcountries &coy){
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.prop.visible;
    }
    return false;
}

void CountryBorder::set_color_boundery(const fcountries &coy, const Colors &color){
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        if (Colors &m_color = it->second.prop.color_border; m_color != color){
            m_color = color;
            
            if (it->second.prop.visible){
                MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
                const auto &c_vec = it->second.ritems;
                
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
        if (Colors &m_fcolor = it->second.prop.color_fill; m_fcolor != fcolor){
            m_fcolor = fcolor;
            
            if (it->second.prop.visible){
                MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
                const auto &c_vec = it->second.ritems;
                
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
        if (float &m_lwidth = it->second.prop.line_width; m_lwidth != lwidth){
            m_lwidth = lwidth;
            
            if (it->second.prop.visible){
                MKMapView *map    = reinterpret_cast<MKMapView*>(this->mk_map);
                const auto &c_vec = it->second.ritems;
                
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
        return it->second.prop.color_border;
    }
    return Colors();
}

Colors CountryBorder::get_fill_color(const fcountries &coy) const{
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.prop.color_fill;
    }
    return Colors();
}

float CountryBorder::get_line_width(const fcountries &coy) const{
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.prop.line_width;
    }
    return 0.f;
}

std::string CountryBorder::get_country_name(const fcountries &coy) const{
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        return it->second.entries.sh_name;
    }
    return std::string();
}

std::vector<fcountries> CountryBorder::get_all_keys_boundary() const{
    return this->st_poligon.um_borders | std::views::keys | std::ranges::to<std::vector<fcountries>>();
}

void CountryBorder::Destroy(){
    if (!this->st_poligon.um_detector.empty()){
        auto u_map = this->st_poligon.um_detector;
        
        std::ranges::for_each(u_map.begin(), u_map.end(), [&](const std::pair<void*, fcountries> &map){
            this->hide_boundary(map.second);
            [reinterpret_cast<MKPolygon*>(map.first) release];
        });
        
        this->st_poligon.um_borders.clear();
        this->st_poligon.um_detector.clear();
    }
    
    if (!this->st_region.detect_reg.empty()){
        auto u_map = this->st_region.detect_reg;
        
        std::ranges::for_each(u_map.begin(), u_map.end(), [&](const std::pair<void*, fcountries> &map){
            // ....
            [reinterpret_cast<MKPolygon*>(map.first) release];
        });
        
        this->st_region.region_off.clear();
        this->st_region.detect_reg.clear();
    }
}

bool CountryBorder::GetMKPolygon(JsonPoligonData &st_poligon, const std::string &d_json){
    if (!d_json.empty()){
        nlohmann::json j_root;
        try {
            j_root = nlohmann::json::parse(d_json);
        } catch (const nlohmann::json::parse_error &error){
            printf("Parse json error: %s\n", error.what());
            return false;
        }
        
        if (!j_root.empty() && 1){
            if (!j_root.count("features"))
                return false;
            
            auto &feature = j_root["features"][0];
            if (feature.count("properties") && feature.count("geometry")){
                auto &prop = feature["properties"];
                auto &geom = feature["geometry"];
                auto &entr = st_poligon.entries;
                auto &vect = st_poligon.country;
                
                entr = {
                    .sh_name  = prop["shapeName"].get<std::string>(),
                    .sh_iso   = prop["shapeISO"].get<std::string>(),
                    .sh_id    = prop["shapeID"].get<std::string>(),
                    .sh_group = prop["shapeGroup"].get<std::string>(),
                    .sh_type  = prop["shapeType"].get<std::string>()
                };

                std::string type = geom["type"].get<std::string>();
                if (type == "Polygon"){
                    auto &location = geom["coordinates"];
                    vect.resize(location.size());
                    
                    std::ranges::for_each(location.begin(), location.end(), [i = 0, &vect](const nlohmann::json &arr) mutable{
                        std::ranges::for_each(arr.begin(), arr.end(), [&i, &vect](const nlohmann::json &geo){
                            vect[i].emplace_back(geo[1], geo[0]);
                        });
                        i++;
                    });
                    
                }else if (type == "MultiPolygon"){
                    auto &location = geom["coordinates"];
                    vect.resize(location.size());
                    
                    std::ranges::for_each(location.begin(), location.end(), [i = 0, &vect](const nlohmann::json &arr) mutable{
                        std::ranges::for_each(arr[0].begin(), arr[0].end(), [&i, &vect](const nlohmann::json &geo){
                            vect[i].emplace_back(geo[1], geo[0]);
                        });
                        i++;
                    });
                }else{
                }
                return !vect.empty();
            }
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
            return false;
        }
        
        if (!j_root.empty()){
            if (!j_root.count("features"))
                return false;
            
            auto &feature = j_root["features"];
            vec_loc.resize(feature.size());
            
            size_t vec_pos = 0;
            std::ranges::for_each(feature.begin(), feature.end(), [&vec_loc, &vec_pos](const nlohmann::json &level_1){
                if (level_1.count("properties") && level_1.count("geometry")){
                    auto &prop = level_1["properties"];
                    auto &geom = level_1["geometry"];
                    auto &regn = vec_loc[vec_pos];
                    
                    regn.entries = {
                        .sh_name  = prop["shapeName"].get<std::string>(),
                        .sh_iso   = prop["shapeISO"].get<std::string>(),
                        .sh_id    = prop["shapeID"].get<std::string>(),
                        .sh_group = prop["shapeGroup"].get<std::string>(),
                        .sh_type  = prop["shapeType"].get<std::string>()
                    };
                    
                    std::string type = geom["type"].get<std::string>();
                    
                    if (type == "Polygon"){
                        if (geom.count("coordinates")){
                            auto &coord = geom["coordinates"];
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
                            auto &coord = geom["coordinates"];
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
