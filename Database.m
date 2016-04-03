//
//  Database.m
//  50 Most Popular Tourist Attractions
//
//  Created by  on 1/24/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import "Database.h"
#import <sqlite3.h>


@implementation Database

#pragma mark - View lifecycle
+(NSString *)getDatabasePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"ContactDb.sqlite"];
	return writableDBPath;
}




+(NSMutableArray *)executeQuery:(NSString*)str
{
	sqlite3_stmt *statement= nil;
	sqlite3 *database;
	NSString *strPath = [self getDatabasePath];
	NSMutableArray *allDataArray = [[NSMutableArray alloc] init];
	if (sqlite3_open([strPath UTF8String],&database) == SQLITE_OK) 
	{
        int errorCode = sqlite3_prepare_v2(database, [str UTF8String], -1, &statement, NULL);
        if(errorCode != SQLITE_OK) {
            NSLog(@"Connect to table failed: %d", errorCode);
        }
		if (sqlite3_prepare_v2(database, [str UTF8String], -1, &statement, NULL) == SQLITE_OK)
		{
            
			while (sqlite3_step(statement) == SQLITE_ROW) 
			{
				int i = 0;
				NSInteger iColumnCount = sqlite3_column_count(statement);
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				while (i< iColumnCount) {
					NSString *str = [self encodedString:(const unsigned char*)sqlite3_column_text(statement, i)];
					NSString *strFieldName = [self encodedString:(const unsigned char*)sqlite3_column_name(statement, i)];
					[dict setObject:str forKey:strFieldName];
					i++;
				}
				[allDataArray addObject:dict];
			}
		}
		else {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
		
		sqlite3_finalize(statement);
	} 
	sqlite3_close(database);
	return allDataArray;
}


+(BOOL)executeScalarQuery:(NSString*)str{
	
	sqlite3_stmt *statement= nil;
	sqlite3 *database;
	BOOL fRet = NO;
	NSString *strPath = [self getDatabasePath];
	if (sqlite3_open([strPath UTF8String],&database) == SQLITE_OK) {
		if (sqlite3_prepare_v2(database, [str UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE){
                fRet =YES;
//                self.lastRowId = sqlite3_last_insert_rowid(database);
//                NSLog(@"lastRowId %ld",lastRowId);
            }
				
		}
		
		sqlite3_finalize(statement);
	} 
	sqlite3_close(database);
	return fRet;
}


+(NSString*)encodedString:(const unsigned char *)ch
{
	NSString *retStr;
	if(ch == nil)
		retStr = @"";
    else
        retStr = [NSString stringWithCString:(char*)ch encoding:NSUTF8StringEncoding];
    return retStr;
}


@end
