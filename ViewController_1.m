//
//  ViewController.m
//  Demo1
//
//  Created by multicoreViral on 4/4/16.
//  Copyright © 2016 multicore. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"

@interface ViewController (){
    NSMutableDictionary *dicMain;
}
@property (nonatomic,strong)NSMutableDictionary *dicMain;
@end

@implementation ViewController
@synthesize dicMain;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dicMain = [NSMutableDictionary new];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getData{
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    NSString *strUrl = @"https://itunes.apple.com/search?media=music&entity=song&term=swift";
    
    
    [operationManager GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.dicMain = (NSMutableDictionary*)responseObject;
        
        [self downloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];
}
-(void)downloadData{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *URL = [NSURL URLWithString:[[[self.dicMain valueForKey:@"results"] objectAtIndex:0] valueForKey:@"previewUrl"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURL *documentsDirectoryURL = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    NSURL *urlFilePath = [documentsDirectoryURL URLByAppendingPathComponent:@"music.mp3"];
    if ([fm fileExistsAtPath:[urlFilePath absoluteString]]) {
        [fm removeItemAtPath:[urlFilePath absoluteString] error:NULL];
    }
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return urlFilePath;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", response);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory1 = [paths objectAtIndex:0];
        
        NSString *strDownloadAudioFilePath= [documentsDirectory1 stringByAppendingPathComponent:@"music.mp3"];
        
        if ([fm fileExistsAtPath:strDownloadAudioFilePath]) {
            NSLog(@"file exists");
            {
                if ([fm fileExistsAtPath:strDownloadAudioFilePath]) {
                    [fm removeItemAtPath:strDownloadAudioFilePath error:NULL];
                }
                BOOL fileCopied = [fm moveItemAtPath:strDownloadAudioFilePath toPath:strDownloadAudioFilePath error:&error];
                
                if (fileCopied) {
                    NSLog(@"file copied");
                }
                else{
                    NSLog(@"file not copied");
                }
            }
        }
        else{
            NSLog(@"file does not download");
        }
    }];
    [downloadTask resume];
}
-(void)uploadData{
    NSData *data = [NSData dataWithContentsOfURL:[dicSelEmoji valueForKey:@"FilePath"]];
    
    NSString *strUrl = [AFNetworkingDataTransaction getServiceURL:IMAGES_UPLOAD withParameters:nil];
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.requestSerializer.timeoutInterval = 60.0;
    
    NSString *strT1 = [Validation GetUTCDate];
    [operationManager.requestSerializer setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:DIC_LOGGED_IN_USER] valueForKey:LOGGED_IN_USER_EMAIL] forHTTPHeaderField:HEADER_USERNAME_KEY];
    [operationManager.requestSerializer setValue:strT1 forHTTPHeaderField:@"T1"];
    [operationManager.requestSerializer setValue:[Validation getEncryptedTextForString:strT1 isGeneral:FALSE] forHTTPHeaderField:@"T2"];
    
    NSMutableDictionary *dicForPost = [[NSMutableDictionary alloc] init];
    
    [dicForPost setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:DIC_LOGGED_IN_USER] valueForKey:LOGGED_IN_USER_ID] forKey:@"UserID"];
    [dicForPost setObject:[NSString stringWithFormat:@"%@",[dicSelEmoji valueForKey:@"Name"]] forKey:@"Name"];
    [dicForPost setObject:@"" forKey:@"Description"];
    [dicForPost setObject:[NSString stringWithFormat:@"%@",[dicSelEmoji valueForKey:@"EmoCatID"]] forKey:@"EmoCatID"];
    [dicForPost setObject:[NSString stringWithFormat:@"%@",[dicSelEmoji valueForKey:@"EmoSubCatID"]] forKey:@"EmoSubCatID"];
    [dicForPost setObject:[NSString stringWithFormat:@"%@",[dicSelEmoji valueForKey:@"EmoSubCatID"]] forKey:@"ID"];
    [dicForPost setObject:((data==nil)?@"":data) forKey:@"ImageData"];
    
    [operationManager POST:strUrl parameters:dicForPost constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        if (data.length > 0) {
            [formData appendPartWithFileData:data name:@"ImageData" fileName:@"photo.png" mimeType:@"multipart/form-data"];
        }
    }
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
                       NSLog(@"JSON: %@", NSStringFromClass([self class]));
                       
                       NSDictionary *dicResponse  = [NSDictionary dictionaryWithDictionary:(NSDictionary *)responseObject];
                       if ([self checkForUserStatus:[dicResponse objectForKey:USER_STATUS]]) {
                           [self deleteFileAfterUpload:[dicSelEmoji valueForKey:@"strImgFileName"]];
                           
                           if ([self getRemainingImageUploadCount]==0) {
                               [self checkAndUpdateUserImagesGalleryVC];
                           }
                       }
                       else{
                           [self callLogOutService];
                       }
                       
                       
                   }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog(@"Error: %@ ***** %@", operation.responseString, error);
                       NSLog(@"Error: %@", [error description]);
                   }
     
     ];
}
@end
