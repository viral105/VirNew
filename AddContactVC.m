//
//  AddContactVC.m
//  Contact
//
//  Created by multicoreViral on 3/29/16.
//  Copyright © 2016 multicore. All rights reserved.
//

#import "AddContactVC.h"

@interface AddContactVC ()

@end

@implementation AddContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftButton_Clicked)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightButton_Clicked)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (self.isFromAddEdit==0) {
        self.navigationItem.title = @"Add Contact";
        [btnImage setBackgroundImage:[UIImage imageNamed:@"defaultphoto.png"] forState:UIControlStateNormal];
    }
    else{
        self.navigationItem.title = @"Edit Contact";
        
        tfFName.text = [self.dicSel objectForKey:@"Cl_FName"];
        tfLName.text = [self.dicSel objectForKey:@"Cl_LName"];
        tfMobile.text = [self.dicSel objectForKey:@"Cl_MobileNum"];
        tfEmail.text = [self.dicSel objectForKey:@"Cl_Email"];
        
        [self setImageFromDocDir:[self.dicSel objectForKey:@"Cl_Image"]];
    }
}
- (void)setImageFromDocDir:(NSString*)imgName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",imgName]];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    if (img!=nil) {
        [btnImage setBackgroundImage:img forState:UIControlStateNormal];
    }
    else{
        [btnImage setBackgroundImage:[UIImage imageNamed:@"defaultphoto.png"] forState:UIControlStateNormal];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)leftButton_Clicked{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightButton_Clicked{

    if (tfFName.text.length==0) {
        UIAlertView *aview = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter first name." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [aview show];
        return;
    }
    else if (tfLName.text.length==0) {
        UIAlertView *aview = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter last name." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [aview show];
        return;
    }
    else if (tfEmail.text.length==0) {
        UIAlertView *aview = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter email." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [aview show];
        return;
    }
    else if (tfMobile.text.length==0) {
        UIAlertView *aview = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter mobile." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [aview show];
        return;
    }
    if (self.isFromAddEdit==0) {
        [self insertIntoDb];
    }
    else{
        [self updateIntoDb];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnImage_Clicked:(id)sender {
    [self hideKeyboard];
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Photo", nil];
    
    aSheet.delegate = self;
    [aSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        if ([UIImagePickerController isSourceTypeAvailable:1]) {
            UIImagePickerController *pickerVC= [[UIImagePickerController alloc] init];
            pickerVC.delegate = self;
            pickerVC.allowsEditing = YES;
            pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
//            pickerVC.showsCameraControls = FALSE;
//            pickerVC.navigationBarHidden = NO;
//            pickerVC.toolbarHidden = YES;
//            pickerVC.cameraViewTransform = CGAffineTransformScale(self.pickerVC.cameraViewTransform,1, 1.33333);
            
            
            [self presentViewController:pickerVC animated:NO completion:nil];
        }
    }
    else if (buttonIndex==1){
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image;
    
    image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [btnImage setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void) insertIntoDb{
    NSString *strfname = tfFName.text;
    NSString *strlname = tfLName.text;
    NSString *stremail = tfEmail.text;
    NSString *strphone = tfMobile.text;
    NSString *strimage;
    
    if (strfname.length==0) {
        strfname = @"";
    }
    if (strlname.length==0) {
        strlname = @"";
    }
    if (stremail.length==0) {
        stremail = @"";
    }
    if (strphone.length==0) {
        strphone = @"";
    }
    strimage = @"";
    
    NSString *strQuery=[NSString stringWithFormat:@"insert into ContactList(Cl_FName,Cl_LName,Cl_Email,Cl_MobileNum,Cl_Image,Cl_IsFromContactBook)values('%@','%@','%@','%@','%@','0')",strfname,strlname,stremail,strphone,strimage];
    [Database executeScalarQuery:strQuery];
    
    NSString *strQuery2=[NSString stringWithFormat:@"select max(Cl_ID) from ContactList"];
    NSMutableArray *arrAll = [Database executeQuery:strQuery2];
    NSLog(@"arrAll %@",arrAll);
    
    NSString *strid = [[arrAll objectAtIndex:0] valueForKey:@"max(Cl_ID)"];
    NSString *stridPng = [NSString stringWithFormat:@"%@.png",strid];
    NSString *strQuery3=[NSString stringWithFormat:@"Update ContactList set Cl_Image='%@' where Cl_ID='%d'",stridPng,[strid intValue]];
    [Database executeScalarQuery:strQuery3];
    
    NSString *strQuery4=[NSString stringWithFormat:@"select * from ContactList where Cl_ID='%d'",[strid intValue]];
    NSMutableArray *arr = [Database executeQuery:strQuery4];
    
    [self.delegate updateArray:[NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:0]]];
    
    [self saveImageToDocDir:stridPng];
    
    NSLog(@"arr %@",[arr objectAtIndex:0]);
    
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) updateIntoDb{
    NSString *strfname = tfFName.text;
    NSString *strlname = tfLName.text;
    NSString *stremail = tfEmail.text;
    NSString *strphone = tfMobile.text;
    NSString *strimage;
    
    if (strfname.length==0) {
        strfname = @"";
    }
    if (strlname.length==0) {
        strlname = @"";
    }
    if (stremail.length==0) {
        stremail = @"";
    }
    if (strphone.length==0) {
        strphone = @"";
    }
    strimage = @"";
    

    NSString *strid = [self.dicSel objectForKey:@"Cl_Image"];
    NSString *strQuery=[NSString stringWithFormat:@"update ContactList set Cl_FName='%@',Cl_LName='%@',Cl_Email='%@',Cl_MobileNum='%@' where Cl_ID='%d'",strfname,strlname,stremail,strphone,[strid intValue]];
    NSMutableArray *arr = [Database executeQuery:strQuery];
    
    [self saveImageToDocDir:[NSString stringWithFormat:@"%@",strid]];
    [self.dicSel setObject:strfname forKey:@"Cl_FName"];
    [self.dicSel setObject:strlname forKey:@"Cl_LName"];
    [self.dicSel setObject:stremail forKey:@"Cl_Email"];
    [self.dicSel setObject:strphone forKey:@"Cl_MobileNum"];
    
    [self.delegate updateArrayAtIPath:self.dicSel iPath:self.indPath];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)saveImageToDocDir:(NSString*)imgName {
    if (btnImage.currentBackgroundImage!=nil) {
        NSData *pngData = UIImagePNGRepresentation(btnImage.currentBackgroundImage);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSError *error;
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",imgName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
        [pngData writeToFile:filePath atomically:YES];
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideKeyboard];
    return YES;
}
-(void)hideKeyboard{
    [tfEmail resignFirstResponder];
    [tfFName resignFirstResponder];
    [tfLName resignFirstResponder];
    [tfMobile resignFirstResponder];
}
@end
