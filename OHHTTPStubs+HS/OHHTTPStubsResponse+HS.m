//
//  OHHttpStubsResponse.m
//  VLCStreamer2
//
//  Created by Rob Jonson on 04/12/2014.
//
//

#if !__has_feature(objc_arc)
#error requires ARC
#endif


#import "OHHTTPStubsResponse+HS.h"
#import <XCTest/XCTest.h>


@implementation OHHTTPStubsResponse (HS)



+(OHHTTPStubsResponse*)responseWithHSFilesNamed:(NSString*)name
{
    NSData *errorData=[self testBundleResourceName:name type:@"error"];
    if (errorData)
    {
        NSError *error=[self errorFromData:errorData];
        
        return [OHHTTPStubsResponse responseWithError:error];
    }
    else
    {
        NSData *data=[self testBundleResourceName:name type:@"data"];
        NSAssert(data, @"no data for response: %@",name);
        
        NSData *status=[self testBundleResourceName:name type:@"status"];
        NSAssert(status, @"no status for response: %@",name);
        NSString *statusString=[[NSString alloc] initWithData:status encoding:NSUTF8StringEncoding];
        int statusCode=[statusString intValue];
        
        NSData *headers=[self testBundleResourceName:name type:@"headers"];
        NSAssert(headers, @"no headers for response: %@",name);
        NSDictionary *headerDict=[self hsJsonObjectFrom:headers];
        
        OHHTTPStubsResponse *response=[OHHTTPStubsResponse responseWithData:data
                                                                 statusCode:statusCode
                                                                    headers:headerDict];
        
        return response;
    }
}

#pragma mark data access

+(NSData*)testBundleResourceName:(NSString*)name type:(NSString*)type
{
    NSBundle *testBundle=[NSBundle bundleForClass:self.class];
    NSString *itemPath=[testBundle pathForResource:name ofType:type];
    return [NSData dataWithContentsOfFile:itemPath];
}

+(id)hsJsonObjectFrom:(NSData*)data
{
    NSError *error;
    id object=[NSJSONSerialization JSONObjectWithData:data
                                              options:0
                                                error:&error];
    if (!object)
    {
        NSLog(@"error generating json object: %@ - %@",error.localizedDescription,self);
    }
    
    return object;
}

+(NSError*)errorFromData:(NSData*)data
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSError *error = [unarchiver decodeObjectForKey:@"NSError"];
    [unarchiver finishDecoding];
    
    return error;
}

@end
