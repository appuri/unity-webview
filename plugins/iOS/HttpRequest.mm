/*
 * HttpRequest
 * a simple async http request library for objective-c
 */

#import <UIKit/UIKit.h>
// these functions are defined inside appController.mm
// as appcontroller.mm is auto-gen'd we'll have to be careful when upgrading Unity version.
extern UIViewController *UnityGetGLViewController();

@interface HttpRequest : NSObject {
    NSString *name;
    NSURL *url;
    NSMutableURLRequest *request;
    NSMutableData *responseData;
    NSURLConnection *connection;
}

-(id)initWithName:(NSString *)objectName withMethod:(NSString *)method withURL:(NSString *)urlStr;

-(void)setHeader:(NSString *)header withString:(NSString *)value;

-(void)setBody:(NSData *)body;

-(void)load;

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

-(void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end


@implementation HttpRequest

- (id)initWithname:(NSString *)objectName withMethod:(NSString *)method withURL:(NSString *)urlStr {
    NSLog(@"*** [HttpRequest init:%@, %@, %@] ***", objectName, method, urlStr);
    self = [super init];
    name = [objectName retain];
    url = [[NSURL URLWithString:urlStr] retain];
    NSLog(@"*** request = [[NSMutableURLRequest requestWithURL] ***");
    request = [[NSMutableURLRequest requestWithURL:url] retain];
    NSLog(@"*** [request setHTTPMethod:%@] ***", method);
    [request setHTTPMethod:method];
    if (method == @"POST") {
        NSLog(@"*** [request is POST] ***");
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    return self;
}

- (void)dealloc
{
    [name release];
    [url release];
    [request release];
    [responseData release];
    [connection release];
    [super dealloc];
}

-(void)setBody:(NSData *)data {
    [request setHTTPBody:data];
}

- (void)load {
    NSLog(@"*** [HttpRequest load:%@] ***", url);
    connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
    NSLog(@"*** [HttpRequest loaded] ***");
}

-(void)setHeader:(NSString *)header withString:(NSString *)value {
    NSLog(@"*** [HttpRequest setHader:%@ withString:%@] ***", header, value);
    [request setValue:value forHTTPHeaderField:header];
    NSLog(@"*** [HttpRequest header setted] ***");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    responseData = [[[NSMutableData alloc] init] retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UnitySendMessage([name UTF8String], "Fail", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] UTF8String]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UnitySendMessage([name UTF8String], "Success", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] UTF8String]);
}

@end

extern "C" {
    void *_HttpRequest_Init(const char *name, const char *method, const char *url);
    void _HttpRequest_SetHeader(void *instance, const char *header, const char *value);
    void _HttpRequest_SetBody(void *instance, const char *body, size_t length);
    void _HttpRequest_Destroy(void *instance);
    void _HttpRequest_Load(void *instance);
}

void *_HttpRequest_Init(const char *name, const char *method, const char *url)  {
    id instance = [[HttpRequest alloc] initWithname:[NSString stringWithUTF8String:name] withMethod: [NSString stringWithUTF8String:method] withURL:[NSString stringWithUTF8String:url]];
    return (void *)instance;
}

void _HttpRequest_SetHeader(void *instance, const char *header, const char *value) {
    NSLog(@"SetHeader %s = %s", header, value);
    HttpRequest *client = (HttpRequest *)instance;
    [client setHeader:[NSString stringWithUTF8String:header] withString:[NSString stringWithUTF8String:value]];
}

void _HttpRequest_SetBody(void *instance, const char *body, size_t length) {
    HttpRequest *client = (HttpRequest *)instance;
    [client setBody:[NSData dataWithBytes:(const void *)body length:(NSUInteger)length]];
}

void _HttpRequest_Destroy(void *instance) {
    HttpRequest *client = (HttpRequest *)instance;
    [client release];
}

void _HttpRequest_Load(void *instance) {
    HttpRequest *client = (HttpRequest *)instance;
    [client load];
}

