#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerURLEncodedFormRequest.h"

@interface AppDelegate() <GCDWebServerDelegate>
{
    GCDWebServer *_webServer;
}


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // 在沙盒目录下起一个服务
  [self startWebServer];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// 起一个服务
- (void)startWebServer {
    _webServer = [[GCDWebServer alloc] init];
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *assetPath = [NSString stringWithFormat:@"%@/assets/sources/", cachePath];
    [_webServer addGETHandlerForBasePath:@"/" directoryPath:assetPath indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
    //设置监听
    [_webServer addHandlerForMethod:@"OPTIONS"      //跨域请求会先发起该类型的请求
                            pathRegex:@"^/"           //接口正则匹配
                         requestClass:[GCDWebServerURLEncodedFormRequest class]
                         processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                             GCDWebServerDataResponse *response;
                             NSLog(@"request %@",request);
                             //对请求来源做合法性判断
 //                             NSString *origin = [request.headers objectForKey:@"Origin"];
 //                             NSString *referer = [request.headers objectForKey:@"Referer"];
 //
 //                             if ([origin containsString:@"xxxxxxx"] && [referer containsString:@"yyyyyy"]) {//合法规则跟后台协商
 //                                 //请求合法，继续其他操作
 //                             }else{
 //                                 //请求不合法，返回对应的状态
 //                                 response = [GCDWebServerDataResponse responseWithText:@"failure"];
 //                             }

                             //响应
                             response = [GCDWebServerDataResponse responseWithStatusCode:200];
                             //响应头设置，跨域请求需要设置，只允许设置的域名或者ip才能跨域访问本接口）
                             [response setValue:@"*" forAdditionalHeader:@"Access-Control-Allow-Origin"];
                             [response setValue:@"Content-Type" forAdditionalHeader:@"Access-Control-Allow-Headers"];
                             //设置options的实效性（我设置了12个小时=43200秒）
                             [response setValue:@"43200" forAdditionalHeader:@"Access-Control-max-age"];
                             return response;
                         }];
  
    _webServer.delegate  = self;
    NSError *error = nil;
    // 设置服务的地址和端口号
    [_webServer startWithOptions:@{GCDWebServerOption_BindToLocalhost: @YES, GCDWebServerOption_Port: @(9999)} error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
}

- (void)webServerDidStart:(GCDWebServer *)server {
    NSLog(@"%@", server.serverURL);
}


- (void)webServerDidDisconnect:(GCDWebServer *)server {
    NSLog(@"断开连接");
//    [self startWebServer];
}

- (void)webServerDidStop:(GCDWebServer*)server {
    NSLog(@"服务停止");
}


@end
