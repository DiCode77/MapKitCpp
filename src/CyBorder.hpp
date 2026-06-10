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

struct Settled{
    std::vector<void*> country;
    std::string name;
    bool   visible = false;
    Colors color;
    Colors fill_color;
    float  line_width = 1.0f;
};

struct RegionOf{
    std::vector<void*> region;
    std::string sh_name;
    std::string sh_iso;
    std::string sh_id;
    std::string sh_group;
    std::string sh_type;
    
    Colors color_reg;
    Colors color_fill;
    bool  visible = false;
    float line_width = 1.0f;
};

struct JsonRegionData{
    std::vector<std::vector<std::vector<Geodata>>> countours;
    std::string sh_name;
    std::string sh_iso;
    std::string sh_id;
    std::string sh_group;
    std::string sh_type;
};

using um_map_poli = std::unordered_map<fcountries, Settled>;
using um_map_sett = std::unordered_map<void*, fcountries>;

using um_reg_offi = std::unordered_map<fcountries, std::vector<RegionOf>>;
using um_det_reg  = std::unordered_map<void*, fcountries>;

struct StPoligon{
    um_map_poli    um_borders;
    um_map_sett    um_detector;
};

struct StRegionOf{
    um_reg_offi region_off;
    um_det_reg  detect_reg;
};

class CountryBorder{
    void           *mk_map;
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
    
    std::string loadFile(const std::string&);
    void setCountryBorder(const fcountries&, const std::string&, const Colors& = Colors());
    void setRegionOffices(const fcountries&, const std::string&, const Colors& = Colors());
    
    um_map_poli &getMapBorders();
    um_map_sett &getMapDetector();
    
    void show_boundary(const fcountries&);
    void hide_boundary(const fcountries&);
    
    void set_color_boundery(const fcountries&, const Colors&);
    void set_fill_color(const fcountries&, const Colors&);
    void set_line_width(const fcountries&, const float&);
    
    Colors get_color_boundery(const fcountries&) const;
    Colors get_fill_color(const fcountries&) const;
    float  get_line_width(const fcountries&) const;
    std::string get_country_name(const fcountries&) const;
    
private:
    void Destroy();
    bool GetMKPolygon(std::vector<std::vector<Geodata>>&, const std::string&);
    bool GetMkRegionOf(std::vector<JsonRegionData>&, const std::string&);
    std::string GetCountryName(const std::string&);
};

#endif
