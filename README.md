NetworkCapture
==============

NetworkCapture for OHHTTPStubs. Easily capture and recreate http content.

Network capture is built to make it ridiculously easy to capture the output of an existing http service, and recreate it for OHHTPStubs. 

    [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                 statusCode:200
                                    headers:@{@"Content-Type":@"application/json"}];

becomes

    [OHHTTPStubsResponse responseWithHSFilesNamed:@"testURL"];

You run the app to capture the output you want to use in future tests:

![alt text][1]


This is then saved as a set of files

![alt text][2]


  [1]: https://cloud.githubusercontent.com/assets/586910/5328300/4bb0de30-7d6e-11e4-8c64-f72246b9df3a.png
  [2]: https://cloud.githubusercontent.com/assets/586910/5328304/8f1311c0-7d6e-11e4-8737-139122bda811.png

Add these to your XCode Test bundle. You can now create an OHHTPStubsResponse in a single line.

    [OHHTTPStubsResponse responseWithHSFilesNamed:@"testURL"];


the complete stub might be

        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithHSFilesNamed:@"testURL"];
    }];


Network capture will capture headers, content body and status code - or an error code if there is a connection error.

To recreate the stub, you will need the OHHTTPStubsResponse+HS category

 - OHHTTPStubsResponse+HS.h
 - OHHTTPStubsResponse+HS.m

(both are in the OHHTTPStubs+HS folder)
