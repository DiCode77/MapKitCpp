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
    bool   visible = false;
    Colors color;
    Colors fill_color;
    float  line_width = 1.0;
};

using um_map_poli = std::unordered_map<fcountries, Settled>;
using um_map_sett = std::unordered_map<void*, fcountries>;

class CountryBorder{
    um_map_poli    um_borders;
    um_map_sett    um_detector;
    void           *mk_map;
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
    
    um_map_poli &getMapBorders();
    um_map_sett &getMapDetector();
    
    void show_boundary(const fcountries&);
    void hide_boundary(const fcountries&);
    
    void set_color_boundery(const fcountries&, const Colors&);
    void set_fill_color(const fcountries&, const Colors&);
    
private:
    void Destroy();
    bool GetMKPolygon(std::vector<std::vector<Geodata>>&, const std::string&);
};

#endif
