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

struct Settled{
    std::vector<void*> country;
    bool visible = true;
};

using um_map_poli = std::unordered_map<fcountries, Settled>;

class CountryBorder{
    um_map_poli    um_borders;
    void           *mk_map;
public:
    CountryBorder() : mk_map(nullptr){}
    CountryBorder(void *map): mk_map(map){}
    CountryBorder(const CountryBorder&) = delete;
    CountryBorder(CountryBorder&&) = delete;
    
    void connect_map(void*);
    void disconnect_map();
    
    std::string loadFile(const std::string&);
    void setCountryBorder(const fcountries&, const std::string&);
    
    um_map_poli &getMapBorders();
    
    void show_boundary(const fcountries&);
    void hide_boundary(const fcountries&);
    
    
private:
    bool GetMKPolygon(std::vector<std::vector<Geodata>>&, const std::string&);
};

#endif
