//
//  Downloader.m
//  NetworkCapture
//
//  Created by Rob Jonson on 03/12/2014.
//  Copyright (c) 2014 HobbyistSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Downloader.h"
#import "AFNetworking.h"


@interface Downloader ()

@property (assign) IBOutlet NSWindow *window;

@end


@implementation Downloader

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)download:(id)sender
{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableStatusCodes=nil;
    manager.responseSerializer.acceptableContentTypes=nil;
    manager.securityPolicy.allowInvalidCertificates = self.allowInvalidSSL;
    
    if ([self.username length] || [self.password length])
    {
        if (!self.username)
        {
            self.username=@"";
        }
        
        if (!self.password)
        {
            self.password=@"";
        }
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.username
                                                                  password:self.password];
    }

    [manager GET:self.urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self saveResponse:operation.response
                      data:responseObject
                     error:nil];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self saveResponse:nil
                      data:nil
                     error:error];
    }];
    
    
//    [self saveResponse:response
//                  data:data
//                 error:connectionError];
    
}

-(void)saveResponse:(NSHTTPURLResponse*)httpResponse data:(NSData*)data error:(NSError*)connectionError
{
    NSSavePanel *openPanel = [NSSavePanel savePanel];
    [openPanel setCanCreateDirectories:YES];
    
    NSString *name=[httpResponse.URL lastPathComponent];
    if (!name)
    {
        name=@"networkCapture";
    }
    [openPanel setNameFieldStringValue:name];
    
    [openPanel setPrompt:@"Save output"];
    if (connectionError)
    {
        [openPanel setPrompt:@"Save output (Error occured downloading)"];
    }
    
    [openPanel setMessage:@"Pick destination"];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL *url=[openPanel URL];
            NSString *baseFilename=[url path];
            
            if (connectionError)
            {
                NSData *errorData=[self dataForError:connectionError];
                [self saveData:errorData
                  fullFilename:[baseFilename stringByAppendingPathExtension:@"error"]
                    allowEmpty:YES];
            }
            else
            {
                [self saveData:data
                  fullFilename:[baseFilename stringByAppendingPathExtension:@"data"]
                    allowEmpty:YES];
                
                NSString *status=[NSString stringWithFormat:@"%ld",(long)httpResponse.statusCode];
                
                [self saveString:status
                    fullFilename:[baseFilename stringByAppendingPathExtension:@"status"]
                      allowEmpty:YES];
                
                NSDictionary *headers=[httpResponse allHeaderFields];
                [self saveData:[self hsJsonFrom:headers withPrettyPrintNSJSONSerialization:NO]
                  fullFilename:[baseFilename stringByAppendingPathExtension:@"headers"]
                    allowEmpty:YES];
            }
        }
    }];
}

#pragma mark output functions

-(NSData*)dataForError:(NSError*)error
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:error forKey:@"NSError"];
    [archiver finishEncoding];
    
    return data;
}

-(NSData*) hsJsonFrom:(id)jsonObject withPrettyPrintNSJSONSerialization:(BOOL)prettyPrint
{
    NSData *jsonData = nil;
    NSError *error;
    
    jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                               options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                 error:&error];
    
    if (! jsonData)
    {
        NSLog(@"error generating NSJSONSerialization data: %@ - %@",error.localizedDescription,self);
    }
    
    return jsonData;
}

-(BOOL)saveData:(NSData*)data fullFilename:(NSString*)saveFilename allowEmpty:(BOOL)allowEmpty
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL successFile;
    
    if(!allowEmpty && [data length]==0)
    {
        NSLog(@"attempted to save an empty file : %@",saveFilename);
        return NO;
    }
    
    NSString *saveDir=[saveFilename stringByDeletingLastPathComponent];
    
    if (saveDir)
    {
        [defaultManager createDirectoryAtPath:saveDir
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error];
    }
    
    if ([defaultManager fileExistsAtPath:saveFilename])
    {
        [defaultManager removeItemAtPath:saveFilename error:&error];
    }
    
    successFile = [defaultManager  createFileAtPath:saveFilename 
                                           contents:data 
                                         attributes:nil];
    
    
    return successFile;
}

-(BOOL)saveString:(NSString*)string fullFilename:(NSString*)saveFilename allowEmpty:(BOOL)allowEmpty
{
    NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
    return [self saveData:data fullFilename:saveFilename allowEmpty:allowEmpty];
}

@end
