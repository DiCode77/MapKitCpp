//
//  CyBorder.hpp
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef CyBorder_hpp
#define CyBorder_hpp

#include <string>
#include <fstream>
#include <nlohmann/json.hpp>
#include <vector>
#include <ranges>
#include "Parameters.hpp"

struct Geodata{
    double x;
    double y;
};

struct Colors{
    float r = 0.f;
    float g = 0.f;
    float b = 0.f;
    float a = 1.0f;
    
    bool operator== (const Colors &_c) const{
        return this->r == _c.r && this->g == _c.g && this->b == _c.b && this->a == _c.a;
    }
    
    bool operator!= (const Colors &_c) const{
        return this->r != _c.r || this->g != _c.g || this->b != _c.b || this->a != _c.a;
    }
};

struct EntriesStr{
    std::string sh_name;
    std::string sh_iso;
    std::string sh_id;
    std::string sh_group;
    std::string sh_type;
};

struct JsonPoligonData{
    std::vector<std::vector<Geodata>> country;
    EntriesStr entries;
};

struct JsonRegionData{
    std::vector<std::vector<std::vector<Geodata>>> countours;
    EntriesStr entries;
};

struct Properties{
    Colors color_border;
    Colors color_fill;
    
    bool  visible = false;
    float line_width = 1.0f;
};

struct GeoInfo{
    std::vector<void*> ritems;
    EntriesStr entries;
    Properties prop, prop2;
};

using um_map_poli = std::unordered_map<fcountries, GeoInfo>;
using um_map_dete = std::unordered_map<void*, fcountries>;

using um_reg_offi = std::unordered_map<fcountries, std::vector<GeoInfo>>;
using um_det_reg  = std::unordered_map<void*, fcountries>;

struct StPoligon{
    um_map_poli    um_borders;
    um_map_dete    um_detector;
};

struct StRegionOf{
    um_reg_offi region_off;
    um_det_reg  detect_reg;
};

class CountryBorder{
    void       *mk_map;
    StPoligon  st_poligon;
    StRegionOf st_region;
public:
    CountryBorder() : mk_map(nullptr){}
    CountryBorder(void *map): mk_map(map){}
    CountryBorder(const CountryBorder&) = delete;
    CountryBorder(CountryBorder&&) = delete;
    ~CountryBorder();
    
    void connect_map(void*);
    void disconnect_map();
    void clear_entire_map(); // In addition to removing everything that has been added to the map, this method will also clear all added objects.
    
    std::string loadFile(const std::string&);
    void setCountryBorder(const fcountries&, const std::string&, const Colors& = Colors()); // Add a boundary object for a single country.
    void setRegionOffices(const fcountries&, const std::string&, const Colors& = Colors()); // Add a polygon feature for the regional settlements of the specified country.
    
    StPoligon  &getStPoligon();
    StRegionOf &getStRegionOf();
    
    void show_boundary(const fcountries&);
    void hide_boundary(const fcountries&);
    bool is_show(const fcountries&);
    
    void set_color_boundery(const fcountries&, const Colors&);
    void set_fill_color(const fcountries&, const Colors&);
    void set_line_width(const fcountries&, const float&);
    
    Colors get_color_boundery(const fcountries&) const;
    Colors get_fill_color(const fcountries&) const;
    float  get_line_width(const fcountries&) const;
    std::string get_country_name(const fcountries&) const;
    
    std::vector<fcountries> get_all_keys_boundary() const;
    
private:
    void Destroy();
    bool GetMKPolygon(JsonPoligonData&, const std::string&);
    bool GetMkRegionOf(std::vector<JsonRegionData>&, const std::string&);
};

#endif
