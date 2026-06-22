//
//  AirOoject.h
//  MapKitCpp
//
//  Created by DiCode77.
//

#ifndef AirOoject_h
#define AirOoject_h

#include <MapKit/MapKit.h>

@interface AirAnnotation : NSObject <MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, retain) NSString *path;
@end

#endif
