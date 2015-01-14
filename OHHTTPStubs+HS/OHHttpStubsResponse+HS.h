//
//  OHHttpStubsResponse.h
//  VLCStreamer2
//
//  Created by Rob Jonson on 04/12/2014.
//
//

#import <Foundation/Foundation.h>
#import "OHHTTPStubsResponse.h"
#import "OHHTTPStubs.h"

@interface OHHTTPStubsResponse(HS)

+(OHHTTPStubsResponse*)responseWithHSFilesNamed:(NSString*)name;

@end
