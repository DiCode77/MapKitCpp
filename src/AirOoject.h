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
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@end

#endif
