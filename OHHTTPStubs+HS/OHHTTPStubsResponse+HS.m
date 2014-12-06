//
//  OHHttpStubsResponse.m
//  VLCStreamer2
//
//  Created by Rob Jonson on 04/12/2014.
//
//

#import "OHHTTPStubsResponse+HS.h"

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
        
        NSData *status=[self testBundleResourceName:name type:@"status"];
        NSString *statusString=[[[NSString alloc] initWithData:status encoding:NSUTF8StringEncoding] autorelease];
        int statusCode=[statusString intValue];
        
        NSData *headers=[self testBundleResourceName:name type:@"headers"];
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
    [unarchiver release];
    
    return error;
}

@end
