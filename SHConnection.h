//
//  SHConnection.h
//  SmartOrderEntry
//
//  Created by Shingo Hashimoto on 2014/02/28.
//
//

#import <Foundation/Foundation.h>

typedef int SHConnectionType;
enum SHConnectionType {
    SHConnectionTypeGET = 1,
    SHConnectionTypePOST = 2
    };

@interface SHConnection : NSObject


- (void)requestWithUrl:(NSString*)urlString
                 owner:(id)owner
                method:(SHConnectionType)method
               getargs:(NSDictionary*)getargs
              postargs:(NSDictionary*)postargs
             onSuccess:(void (^)(NSData *data, NSURLResponse *response))successBlock
               onError:(void (^)(NSError *error))errorBlock;

@end
