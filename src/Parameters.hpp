//
//  Parameters.hpp
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef Parameters_hpp
#define Parameters_hpp

struct fsize{
    long x;
    long y;
    
    fsize() : x(0), y(0){}
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
    long x;
    long y;
    
    fpoint() : x(0), y(0){}
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


#endif
