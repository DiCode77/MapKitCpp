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
#include <unordered_map>
#include <functional>
#include <filesystem>
#include <mutex>
#include "Parameters.hpp"

struct Geodata{
    double x = 0.f;
    double y = 0.f;
    
    bool operator== (const Geodata &_g) const{
        return this->x == _g.x && this->y == _g.y;
    }
    
    bool operator!= (const Geodata &_g) const{
        return this->x != _g.x || this->y != _g.y;
    }
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
    Properties prop;
};

using um_map_poli = std::unordered_map<fcountries, GeoInfo>;
using um_map_dete = std::unordered_map<void*, fcountries>;

struct StPoligon{
    um_map_poli    um_borders;
    um_map_dete    um_detector;
};

class Utilities{
public:
    std::string loadFile(const std::string&);
    std::string GetSelectEntries(const fetries&, const GeoInfo&) const;
};

class CountryBorder : public Utilities{
    void       **m_map;
    StPoligon  st_poligon;
public:
    CountryBorder() = delete;
    CountryBorder(void **map) : m_map(map){}
    CountryBorder(const CountryBorder&) = delete;
    CountryBorder(CountryBorder&&) = delete;
    ~CountryBorder();
    
    void clear_entire_map(); // In addition to removing everything that has been added to the map, this method will also clear all added objects.
    void set_country_border(const fcountries&, const std::string&, const Colors& = Colors()); // Add a boundary object for a single country.
    
    StPoligon  &get_st_poligon();
    
    void show(const fcountries&);
    void hide(const fcountries&);
    bool is_show(const fcountries&);
    
    void set_color(const fcountries&, const Colors&);
    void set_fill_color(const fcountries&, const Colors&);
    void set_line_width(const fcountries&, const float&);
    
    Colors get_color(const fcountries&) const;
    Colors get_fill_color(const fcountries&) const;
    float  get_line_width(const fcountries&) const;
    
    std::vector<fcountries>  get_all_keys() const;
    std::vector<std::string> get_all_select_entries(const fetries&) const;
    std::vector<std::reference_wrapper<const EntriesStr>> get_all_entries() const;
    std::vector<std::reference_wrapper<const Properties>> get_all_properti() const;
    
private:
    void Destroy();
    bool GetTheCountryProfile(JsonPoligonData&, const std::string&);
};

using um_reg_offi = std::unordered_map<fcountries, std::vector<GeoInfo>>;
using um_det_reg  = std::unordered_map<void*, fcountries>;

struct StRegionOf{
    um_reg_offi region_off;
    um_det_reg  detect_reg;
};

class RegionBorder : public Utilities{
    void **m_map;
private:
    StRegionOf st_region;
public:
    RegionBorder() = delete;
    RegionBorder(void **pmap) : m_map(pmap){}
    RegionBorder(const RegionBorder&) = delete;
    RegionBorder(RegionBorder&&) = delete;
    ~RegionBorder();
    
    void clear_entire_map();
    void set_region_offices(const fcountries&, const std::string&, const Colors& = Colors()); // Add a polygon feature for the regional settlements of the specified country.
    StRegionOf &get_st_region(); // This method returns a reference to the data structure that stores all the data.
    
    void show(const fcountries&, const std::string&); // The first parameter should be the ID, and the second should be the ID of the regional office
    void hide(const fcountries&, const std::string&);
    bool is_show(const fcountries&, const std::string&);
    
    void set_color(const fcountries&, const std::string&, const Colors&);
    void set_color_fill(const fcountries&, const std::string&, const Colors&);
    void set_line_width(const fcountries&, const std::string&, const float&);
    
    std::vector<fcountries>  get_all_keys() const;
    std::vector<std::string> get_all_select_entries(const fcountries&, const fetries&) const; // Returns an array based on the specified parameter.
    std::vector<std::pair<std::string, std::string>> get_all_pair_select_entries(const fcountries&, const fetries&, const fetries&) const;
    std::unordered_map<std::string, std::string> get_all_map_select_entries(const fcountries&, const fetries&, const fetries&) const;
    std::vector<std::reference_wrapper<const EntriesStr>> get_all_entries(const fcountries&) const; // Returns an array of structures for the specified country.

private:
    void Destroy();
    bool GetTheRegionalProfile(std::vector<JsonRegionData>&, const std::string&);
    void RefreshVisualization(const std::vector<void*>&);
};

struct ObjectOffset{
    Geodata coord_start;          // Initial coordinates.
    Geodata coord_end;            // End coordinates.
    Geodata current;              // To save the current coordinates.
    double  counter_min = 0.01f;   //
    double  counter_max = 900.f;  // lifespan of an object.
    double  speed = 120000;       // Object speed. in m/h
    double  distance = 0.f;
    bool    release  = false;
    float   timers[2]{};
};

struct ObjectSettings{
    std::function<bool(void*, ObjectOffset&)> func;
    ObjectOffset offset;
};

struct PropertyDescript{
    ObjectOffset offset;
    std::string  path;   // Path to the object's illustration.
    std::string  name;   // Object Name.
    std::string  type;   // object type.
    std::string  img;
};

struct SpatialObject{
    std::mutex lock_update;
    std::unordered_map<void*, ObjectSettings> func_update;
    std::unordered_map<void*, ObjectOffset> passive_obj;
};

class AirObject{
    void **m_map;
private:
    SpatialObject sp_object;
public:
    AirObject() = delete;
    AirObject(void**);
    AirObject(const AirObject&) = delete;
    AirObject(AirObject&&) = delete;
    ~AirObject();
    
    void add_object(const PropertyDescript&, const fobject& = fobject::passive); // Add an object to the map with the specified settings.
    void remove_object(void*, const fobject&);
    double get_distance(const Geodata&, const Geodata&) const; // Returns the distance between two points in meters.
    std::vector<void*> get_all_object(const fobject&) const;
    
private:
    void StartAsync();
    void *CreateAirObject(const PropertyDescript&);
};

class Visualize{
    CountryBorder *m_country;
    RegionBorder  *m_region;
    AirObject     *m_air_obj;
private:
    void *m_map;
public:
    Visualize();
    Visualize(void*);
    ~Visualize();
    
    void connect(void*);
    
    CountryBorder &country();
    RegionBorder  &region();
    AirObject     &air_object();
};

#endif
