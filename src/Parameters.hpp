//
//  Parameters.hpp
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef Parameters_hpp
#define Parameters_hpp

struct fsize{
    double x;
    double y;
    
    fsize() : x(0.f), y(0.f){}
    fsize(long x, long y) : fsize(){
        this->x = x;
        this->y = y;
    }
    
    fsize(const fsize &size) : fsize(){
        this->x = size.x;
        this->y = size.y;
    }
    
    bool operator== (const fsize &size) const{
        return this->x == size.x && this->y == size.y;
    }
    
    bool operator!= (const fsize &size) const{
        return this->x != size.x && this->y != size.y;
    }
};

struct fpoint{
    double x;
    double y;
    
    fpoint() : x(0.f), y(0.f){}
    fpoint(long x, long y) : fpoint(){
        this->x = x;
        this->y = y;
    }
    
    fpoint(const fpoint &point) : fpoint(){
        this->x = point.x;
        this->y = point.y;
    }
    
    bool operator== (const fpoint &point) const{
        return this->x == point.x && this->y == point.y;
    }
    
    bool operator!= (const fpoint &point) const{
        return this->x != point.x && this->y != point.y;
    }
};

const fsize  fSizeDefault  = { -1, -1 };
const fpoint fPointDefault = { -1, -1 };

enum class fscale{
    fnone,
    fnone_fix_point,
    fauto,
    fauto_fix_point,
    fwidth,
    fwidth_fix_point,
    fheight,
    fheight_fix_point
};

// These are the styles supported by the map.
enum class fmap_type{
    standard,
    sate_llite,
    hybrid,
    sate_llite_flyover,
    hybrid_flyover,
    muted_standard
};

/*
 standard:
 +roads
 +cities
 +rivers
 +borders
 
 sate_llite:
 +satellite images
 -city names
 -roads
 
 hybrid:
 +satellite
 +roads
 +city names
 
 sate_llite_flyover:
 +houses
 +trees
 +terrain
 +3D
 
 hybrid_flyover:
 +3D
 +city names
 +roads
 
 muted_standard:
 +Standard layout
 +Muted colors
 +Less visual clutter
 */

enum class fmap_modes{
    explore,
    driveng,
    transit
};

enum class ffunc_conn{
    evt_height_changed,
    evt_geocode_location,
    evt_update_completer
};

enum class fcountries{
    ukraine,
    poland,
    slovakia,
    hungary,
    romania,
    usa,
    china,
    end
};

enum class fetries{
    name,
    iso,
    id,
    group,
    type
};

#endif
