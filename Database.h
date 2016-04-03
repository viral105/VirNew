//
//  Database.h
//  50 Most Popular Tourist Attractions
//
//  Created by  on 1/24/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Database : NSObject
{
    
}

+(NSString* )getDatabasePath;
+(NSMutableArray *)executeQuery:(NSString*)str;
+(NSString*)encodedString:(const unsigned char *)ch;
+(BOOL)executeScalarQuery:(NSString*)str;

@end
