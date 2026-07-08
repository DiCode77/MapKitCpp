//
//  AirOoject.h
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef AirOoject_h
#define AirOoject_h

#include <MapKit/MapKit.h>
#include "Parameters.hpp"

@interface AirAnnotation : NSObject <MKAnnotation>{
@public
    ObjectButton button;
}
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, retain) NSString *path;
@property(nonatomic, copy) NSString   *title;
@property(nonatomic, copy) NSString   *subtitle;
@property(nonatomic, assign) BOOL      show_callout;
@property(nonatomic, assign) NSInteger size_emoji;
@end

#endif
