//
// NuSMTP.m
//
// Class wrapper for Ian Baird's SKPSMTPMessage classes.
// Copyright (c) 2009 Jeff Buck
//

#import <Foundation/Foundation.h>
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@interface NuSMTPMessage : NSObject <SKPSMTPMessageDelegate>
{
    SKPSMTPMessage* msg;
}

- (id) initWithFromEmail:(NSString*)fromEmail
                 toEmail:(NSString*)toEmail
               relayHost:(NSString*)relayHost
                   login:(NSString*)login
                password:(NSString*)password
                 subject:(NSString*)subject;

- (void) setCCEmail:(NSString*)ccEmail;
- (void) setBCCEmail:(NSString*)bccEmail;

- (void) addTextPart:(NSString*)part;
- (void) addDataPart:(NSData*)data mimeType:(NSString*)mimetype name:(NSString*)name;

@end

@implementation NuSMTPMessage

- (id) initWithFromEmail:(NSString*)fromEmail
                 toEmail:(NSString*)toEmail
               relayHost:(NSString*)relayHost
                   login:(NSString*)login
                password:(NSString*)password
                 subject:(NSString*)subject
{
    self = [super init];
	
    if (self)
    {
        msg = [[SKPSMTPMessage alloc] init];
        
        msg.fromEmail = fromEmail;
        msg.toEmail = toEmail;
        
        msg.relayHost = relayHost;
        
        msg.requiresAuth = YES;
        msg.login = login;
        msg.pass = password;
        msg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
        
        msg.subject = subject;
        msg.parts = [NSMutableArray array];

        msg.delegate = self;
    }

	return self;
}

- (void)dealloc
{
    [msg release];

    [super dealloc];
}

- (void) setDelegate:(id<SKPSMTPMessageDelegate>)delegate
{
	msg.delegate = delegate;
}

- (void) setCCEmail:(NSString*)ccEmail
{
    if (msg != nil)
		msg.ccEmail = ccEmail;
}

- (void) setBCCEmail:(NSString*)bccEmail
{
    if (msg != nil)
		msg.bccEmail = bccEmail;
}

- (void) setValidateSSLChain:(BOOL)validateFlag
{
    if (msg != nil)
		msg.validateSSLChain = validateFlag;
}


// Delegate methods
- (void)messageSent:(SKPSMTPMessage *)message
{
    [message release];
    
    NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    [message release];
    
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}


// Building up the message body
- (void) addTextPart:(NSString*)part
{
    NSDictionary *partDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"text/plain",kSKPSMTPPartContentTypeKey,
                                 part,kSKPSMTPPartMessageKey,
                                 @"8bit",kSKPSMTPPartContentTransferEncodingKey,
                                 nil];

    [msg.parts addObject:partDict];
}

- (void) addDataPart:(NSData*)data mimeType:(NSString*)mimetype name:(NSString*)name
{
	NSString* contentType = [NSString stringWithFormat:@"%@;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"",
                                mimetype, name];
    NSString* contentDisposition = [NSString stringWithFormat:@"attachment;\r\n\tfilename=\"%@\"", name];

    NSDictionary *partDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                contentType, kSKPSMTPPartContentTypeKey,
                                contentDisposition, kSKPSMTPPartContentDispositionKey,
                                [data encodeBase64ForData], kSKPSMTPPartMessageKey,
                                @"base64",kSKPSMTPPartContentTransferEncodingKey,
                                nil];

    [msg.parts addObject:partDict];
}


- (int) send
{
	return [msg send];
}

@end