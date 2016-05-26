//
//  Downloader.h
//  NetworkCapture
//
//  Created by Rob Jonson on 03/12/2014.
//  Copyright (c) 2014 HobbyistSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject <NSURLConnectionDelegate>

@property (strong) NSString *urlString;
@property (assign) BOOL allowInvalidSSL;
@property (strong) NSString *username;
@property (strong) NSString *password;

@end
