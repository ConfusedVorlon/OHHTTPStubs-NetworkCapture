//
//  OHHTTPStubsResponsetest.m
//  VLCStreamer2
//
//  Created by Rob Jonson on 04/12/2014.
//
//

#import <XCTest/XCTest.h>
#import "OHHTTPStubs.h"
#import "OHHTTPStubsResponse+HS.h"

@interface OHHTTPStubsResponsetest : XCTestCase

@end

@implementation OHHTTPStubsResponsetest

- (void)setUp {
    [super setUp];


    
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}


- (void)testHSStub
{
    XCTestExpectation *httpResponse = [self expectationWithDescription:@"httpResponse"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithHSFilesNamed:@"testResponse"];
    }];
    
    NSURL *url=[NSURL URLWithString:@"http://localhost:54340/t"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                         queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                             
                                             NSHTTPURLResponse *http=(NSHTTPURLResponse*)response;
                                             
                                             XCTAssertEqual(200, http.statusCode,@"status code");
                                             
                                             NSDictionary *headers=[http allHeaderFields];
                                             NSString *accessControl=[headers objectForKey:@"Access-Control-Allow-Origin"];
                                             
                                             XCTAssertEqualObjects(@"*", accessControl,@"header has access control");
                                             
                                             NSString *responseString=[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                             NSRange range=[responseString rangeOfString:@"This a test page"
                                                                                 options:NSLiteralSearch];
                                             
                                             BOOL hasStreamer=(range.location!=NSNotFound);
                                             
                                             XCTAssertTrue(hasStreamer,@"expected content");
                                             
                                             [httpResponse fulfill];
                                         }];
    
    //timeout is treated as an error
    [self waitForExpectationsWithTimeout:1
                                 handler:nil];
}

- (void)testHSErrorStub
{
    XCTestExpectation *httpResponse = [self expectationWithDescription:@"httpResponse"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithHSFilesNamed:@"errorResponse"];
    }];
    
    NSURL *url=[NSURL URLWithString:@"http://localhost:54340/t"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           
                                           XCTAssertNotNil(connectionError);
                                           XCTAssertEqual(-1012,connectionError.code,@"code should be as expected");
                                           XCTAssertEqualObjects(@"NSURLErrorDomain",connectionError.domain,@"domain");
                                           XCTAssertEqualObjects(@"http://localhost:8080",[connectionError.userInfo objectForKey:@"NSErrorFailingURLStringKey"],@"domain");
                                           
                                           [httpResponse fulfill];
                                       }];
    
    //timeout is treated as an error
    [self waitForExpectationsWithTimeout:1
                                 handler:nil];
}

@end
