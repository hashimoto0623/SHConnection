//
//  SHConnection.m
//  SmartOrderEntry
//
//  Created by Shingo Hashimoto on 2014/02/28.
//
//

#import "SHConnection.h"




@interface NSString(CSTM)
- (NSString*)escapedUrlString;
@end


@implementation NSString(CSTM)
- (NSString*)escapedUrlString{
    NSString *escapedUrlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,
                                                                                                       (CFStringRef)self,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                       kCFStringEncodingUTF8 ));
    return escapedUrlString;
}
@end



@implementation SHConnection


- (void)dealloc{
    [super dealloc];
}


/**
 通信開始(POST)
 @param _get URL
 @param args 引数
 */
- (void)requestWithUrl:(NSString*)urlString
                 owner:(id)owner
                method:(SHConnectionType)method
               getargs:(NSDictionary*)getargs
              postargs:(NSDictionary*)postargs
             onSuccess:(void (^)(NSData *data, NSURLResponse *response))successBlock
               onError:(void (^)(NSError *error))errorBlock{

    NSURL *url = nil;
    NSMutableArray *getArgsJoinKeyValue = [[NSMutableArray alloc] initWithCapacity:0];
    if (getargs) {
        for (NSString *key in getargs){
            id value = [getargs objectForKey:key];
            [getArgsJoinKeyValue addObject:[NSString stringWithFormat:@"%@=%@",key, value]];
        }
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString, [getArgsJoinKeyValue componentsJoinedByString:@"&"]]];
    }else{
        url = [NSURL URLWithString:urlString];
    }
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    //  post連結
    NSMutableArray *argsJoinKeyValue = [[NSMutableArray alloc] initWithCapacity:0];
    if (postargs) {
        for (NSString *key in postargs){
            NSString *value = [postargs objectForKey:key];
            [argsJoinKeyValue addObject:[NSString stringWithFormat:@"%@=%@",key, value.escapedUrlString]];
        }
        NSString *postString = [argsJoinKeyValue componentsJoinedByString:@"&"];
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [
                        NSURLConnection
                        sendSynchronousRequest : request
                        returningResponse : &response
                        error : &error
                        ];
        if (error) {
            errorBlock(error);
        }else{
            successBlock(data, response);
        }
    });
}



@end

