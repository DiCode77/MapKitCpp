//
//  AirOoject.h
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef MapKit_obj_h
#define MapKit_obj_h

#include <MapKit/MapKit.h>

@interface AirAnnotation : NSObject <MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

#endif
