//
//  AddContactVC.h
//  Contact
//
//  Created by multicoreViral on 3/29/16.
//  Copyright © 2016 multicore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"

@protocol AddContactVCDelegate <NSObject>

-(void)updateArray:(NSMutableDictionary*)dic;
-(void)updateArrayAtIPath:(NSMutableDictionary*)dic iPath:(int)ipath;

@end
@interface AddContactVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>{
    
    IBOutlet UIButton *btnImage;
    IBOutlet UITextField *tfFName;
    IBOutlet UITextField *tfLName;
    
    IBOutlet UITextField *tfMobile;
    IBOutlet UITextField *tfEmail;
    
}
- (IBAction)btnImage_Clicked:(id)sender;
@property (nonatomic,strong) id<AddContactVCDelegate> delegate;

@property (nonatomic,assign) int isFromAddEdit; // 0 if from add 1 if from edit
@property (nonatomic,strong) NSMutableDictionary *dicSel;
@property (nonatomic,assign) int indPath;
@end
