#include "Visualize.hpp"
#include "MapKit_obj.h"

// ************ Utilities class ************* //

std::string Utilities::loadFile(const std::string &dir){
    std::ifstream file(dir);
    std::string   text;
    
    if (file.is_open()){
        text.assign(std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>());
    }
    
    return text;
}

std::string Utilities::GetSelectEntries(const fetries &entry, const GeoInfo &info) const{
    switch (entry) {
        case fetries::name:  return info.entries.sh_name;
        case fetries::iso:   return info.entries.sh_iso;
        case fetries::id:    return info.entries.sh_id;
        case fetries::group: return info.entries.sh_group;
        case fetries::type:  return info.entries.sh_type;
    }
    return {};
}

// ************ CountryBorder class ************* //

CountryBorder::~CountryBorder(){
    this->Destroy();
    this->m_map = nullptr;
}

void CountryBorder::clear_entire_map(){
    this->Destroy();
}

void CountryBorder::set_country_border(const fcountries &city, const std::string &d_json, const Colors &colors){
    if (!this->st_poligon.um_borders.count(city)){
        JsonPoligonData st_poligon;
        bool mkp = this->GetTheCountryProfile(st_poligon, d_json);
        
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

StPoligon &CountryBorder::get_st_poligon(){
    return this->st_poligon;
}

void CountryBorder::show(const fcountries &cnt){
    if (auto it = this->st_poligon.um_borders.find(cnt); it != this->st_poligon.um_borders.end()){
        if (it->second.prop.visible == false){
            it->second.prop.visible = true;
            
            MKMapView *map    = reinterpret_cast<MKMapView*>(*this->m_map);
            const auto &c_vec = it->second.ritems;
            
            std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
            });
        }
        
    }
}

void CountryBorder::hide(const fcountries &cnt){
    if (auto it = this->st_poligon.um_borders.find(cnt); it != this->st_poligon.um_borders.end()){
        if (it->second.prop.visible == true){
            it->second.prop.visible = false;
            
            MKMapView *map    = reinterpret_cast<MKMapView*>(*this->m_map);
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

void CountryBorder::set_color(const fcountries &coy, const Colors &color){
    if (auto it = this->st_poligon.um_borders.find(coy); it != this->st_poligon.um_borders.end()){
        if (Colors &m_color = it->second.prop.color_border; m_color != color){
            m_color = color;
            
            if (it->second.prop.visible){
                MKMapView *map    = reinterpret_cast<MKMapView*>(*this->m_map);
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
                MKMapView *map    = reinterpret_cast<MKMapView*>(*this->m_map);
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
                MKMapView *map    = reinterpret_cast<MKMapView*>(*this->m_map);
                const auto &c_vec = it->second.ritems;
                
                std::ranges::for_each(c_vec.begin(), c_vec.end(), [&](void *data){
                    [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
                    [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
                });
            }
        }
    }
}

Colors CountryBorder::get_color(const fcountries &coy) const{
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

std::vector<fcountries> CountryBorder::get_all_keys() const{
    return this->st_poligon.um_borders | std::views::keys | std::ranges::to<std::vector<fcountries>>();
}

std::vector<std::string> CountryBorder::get_all_select_entries(const fetries &entry) const{
    return this->st_poligon.um_borders | std::views::values | std::views::transform([&](const GeoInfo &values){
        return this->GetSelectEntries(entry, values);
    }) | std::ranges::to<std::vector<std::string>>();
    return {};
}

std::vector<std::reference_wrapper<const EntriesStr>> CountryBorder::get_all_entries() const{
    return this->st_poligon.um_borders | std::views::values | std::views::transform([](const GeoInfo &values) -> const EntriesStr&{
        return values.entries;
    }) | std::ranges::to<std::vector<std::reference_wrapper<const EntriesStr>>>();
}

std::vector<std::reference_wrapper<const Properties>> CountryBorder::get_all_properti() const{
    return this->st_poligon.um_borders | std::views::values | std::views::transform([](const GeoInfo &values) -> const Properties&{
        return values.prop;
    }) | std::ranges::to<std::vector<std::reference_wrapper<const Properties>>>();
}

void CountryBorder::Destroy(){
    if (!this->st_poligon.um_detector.empty()){
        auto &u_map = this->st_poligon.um_detector;
        
        std::ranges::for_each(u_map.begin(), u_map.end(), [&](const std::pair<void*, fcountries> &map){
            this->hide(map.second);
            [reinterpret_cast<MKPolygon*>(map.first) release];
        });
        
        this->st_poligon.um_borders.clear();
        this->st_poligon.um_detector.clear();
    }
}

bool CountryBorder::GetTheCountryProfile(JsonPoligonData &st_poligon, const std::string &d_json){
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

// ************ RegionBorder class ************* //

RegionBorder::~RegionBorder(){
    this->Destroy();
    this->m_map = nullptr;
}
void RegionBorder::clear_entire_map(){
    this->Destroy();
}

void RegionBorder::set_region_offices(const fcountries &coy, const std::string &d_json, const Colors &color){
    if (!this->st_region.region_off.count(coy)){
        std::vector<JsonRegionData> vec;
        
        bool mkp = this->GetTheRegionalProfile(vec, d_json);
        if (mkp){
            std::vector<GeoInfo> reg_vec;
            std::ranges::for_each(vec.begin(), vec.end(), [&reg_vec, &color](JsonRegionData &st_data){
                GeoInfo m_region{
                    .entries = {
                        .sh_name  = std::move(st_data.entries.sh_name),
                        .sh_iso   = std::move(st_data.entries.sh_iso),
                        .sh_id    = std::move(st_data.entries.sh_id),
                        .sh_group = std::move(st_data.entries.sh_group),
                        .sh_type  = std::move(st_data.entries.sh_type)
                    },
                    .prop = {
                        .color_border = color,
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

StRegionOf &RegionBorder::get_st_region(){
    return this->st_region;
}

void RegionBorder::show(const fcountries &coy, const std::string &sh_id){
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        auto it_find = std::ranges::find_if(it->second.begin(), it->second.end(), [&sh_id](GeoInfo &geo){
            return geo.entries.sh_id == sh_id;
        });
        
        if (it_find != it->second.end()){
            if (!it_find->prop.visible){
                it_find->prop.visible = true;
                
                MKMapView *map = reinterpret_cast<MKMapView*>(*this->m_map);
                std::ranges::for_each(it_find->ritems.begin(), it_find->ritems.end(), [&map](void *data){
                    [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
                });
            }
        }
    }
}

void RegionBorder::hide(const fcountries &coy, const std::string &sh_id){
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        auto it_find = std::ranges::find_if(it->second.begin(), it->second.end(), [&sh_id](GeoInfo &geo){
            return geo.entries.sh_id == sh_id;
        });
        
        if (it_find != it->second.end()){
            if (it_find->prop.visible){
                it_find->prop.visible = false;
                
                MKMapView *map = reinterpret_cast<MKMapView*>(*this->m_map);
                std::ranges::for_each(it_find->ritems.begin(), it_find->ritems.end(), [&map](void *data){
                    [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
                });
            }
        }
    }
}

bool RegionBorder::is_show(const fcountries &coy, const std::string &sh_id){
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        auto it_find = std::ranges::find_if(it->second.begin(), it->second.end(), [&sh_id](GeoInfo &geo){
            return geo.entries.sh_id == sh_id;
        });
        
        if (it_find != it->second.end()){
            return it_find->prop.visible;
        }
    }
    return false;
}

void RegionBorder::set_color(const fcountries &coy, const std::string &sh_id, const Colors &m_color){
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        auto find = std::ranges::find_if(it->second.begin(), it->second.end(), [&sh_id](GeoInfo &info){
            return info.entries.sh_id == sh_id;
        });
        
        if (find != it->second.end()){
            if (Colors &color = find->prop.color_border; color != m_color){
                color = m_color;
                
                if (find->prop.visible){
                    this->RefreshVisualization(find->ritems);
                }
            }
        }
    }
}

void RegionBorder::set_color_fill(const fcountries &coy, const std::string &sh_id, const Colors &m_color){
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        auto find = std::ranges::find_if(it->second.begin(), it->second.end(), [&sh_id](GeoInfo &info){
            return info.entries.sh_id == sh_id;
        });
        
        if (find != it->second.end()){
            if (Colors &color = find->prop.color_fill; color != m_color){
                color = m_color;
                
                if (find->prop.visible){
                    this->RefreshVisualization(find->ritems);
                }
            }
        }
    }
}

void RegionBorder::set_line_width(const fcountries &coy, const std::string &sh_id, const float &m_width){
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        auto find = std::ranges::find_if(it->second.begin(), it->second.end(), [&sh_id](GeoInfo &info){
            return info.entries.sh_id == sh_id;
        });
        
        if (find != it->second.end()){
            if (float &width = find->prop.line_width; width != m_width){
                width = m_width;
                
                if (find->prop.visible){
                    this->RefreshVisualization(find->ritems);
                }
            }
        }
    }
}

std::vector<fcountries> RegionBorder::get_all_keys() const{
    return this->st_region.region_off | std::views::keys | std::ranges::to<std::vector<fcountries>>();
}

std::vector<std::string> RegionBorder::get_all_select_entries(const fcountries &coy, const fetries &entry) const{
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        return it->second | std::views::transform([&](const GeoInfo &info){
            return this->GetSelectEntries(entry, info);
        }) | std::ranges::to<std::vector<std::string>>();
    }
    return {};
}

std::vector<std::pair<std::string, std::string>> RegionBorder::get_all_pair_select_entries(const fcountries &coy, const fetries &first, const fetries &second) const{
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        return it->second | std::views::transform([&](const GeoInfo &info){
            return std::make_pair(this->GetSelectEntries(first, info), this->GetSelectEntries(second, info));
        }) | std::ranges::to<std::vector<std::pair<std::string, std::string>>>();
    }
    return {};
}

std::unordered_map<std::string, std::string> RegionBorder::get_all_map_select_entries(const fcountries &coy, const fetries &first, const fetries &second) const{
    return this->get_all_pair_select_entries(coy, first, second) | std::views::transform([](std::pair<std::string, std::string> &pair){
        return std::make_pair(std::move(pair.first), std::move(pair.second));
    }) | std::ranges::to<std::unordered_map<std::string, std::string>>();
}

std::vector<std::reference_wrapper<const EntriesStr>> RegionBorder::get_all_entries(const fcountries &coy) const{
    if (auto it = this->st_region.region_off.find(coy); it != this->st_region.region_off.end()){
        return it->second | std::views::transform([](const GeoInfo &info) -> const EntriesStr&{
            return info.entries;
        }) | std::ranges::to<std::vector<std::reference_wrapper<const EntriesStr>>>();
    }
    return {};
}

void RegionBorder::Destroy(){
    if (!this->st_region.detect_reg.empty()){
        auto &u_map = this->st_region.detect_reg;
        std::ranges::for_each(u_map.begin(), u_map.end(), [&](const std::pair<void*, fcountries> &map){
            [reinterpret_cast<MKMapView*>(*this->m_map) removeOverlay:reinterpret_cast<MKPolygon*>(map.first)]; // This is a test method for hiding all active overlays.
            [reinterpret_cast<MKPolygon*>(map.first) release];
        });
        
        this->st_region.region_off.clear();
        this->st_region.detect_reg.clear();
    }
}

bool RegionBorder::GetTheRegionalProfile(std::vector<JsonRegionData> &vec_loc, const std::string &d_json){
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

void RegionBorder::RefreshVisualization(const std::vector<void*> &vec){
    if (!vec.empty()){
        MKMapView  *map = reinterpret_cast<MKMapView*>(*this->m_map);
        std::ranges::for_each(vec.begin(), vec.end(), [&map](void *data){
            [map removeOverlay:reinterpret_cast<MKPolygon*>(data)];
            [map addOverlay:reinterpret_cast<MKPolygon*>(data)];
        });
    }
}

// ************ Visualize class ************* //

Visualize::Visualize() : m_country(new CountryBorder(&this->m_map)), m_region(new RegionBorder(&this->m_map)), m_air_obj(new AirObject(&this->m_map)), m_map(nullptr){}

Visualize::Visualize(void *map) : Visualize::Visualize(){
    this->m_map = map;
}

Visualize::~Visualize(){
    delete this->m_country;
    delete this->m_region;
    delete this->m_air_obj;
    this->m_map = nullptr;
}

void Visualize::connect(void *map){
    this->m_map = map;
}

CountryBorder &Visualize::country(){
    return *this->m_country;
}

RegionBorder &Visualize::region(){
    return *this->m_region;
}

AirObject &Visualize::air_object(){
    return *this->m_air_obj;
}
