//
//  ViewController.m
//  Contact
//
//  Created by multicoreViral on 3/29/16.
//  Copyright © 2016 multicore. All rights reserved.
//

#import "ViewController.h"
@import AddressBook;
@import AddressBookUI;
#import <sqlite3.h>
@interface ViewController (){
    NSMutableArray *contactList;
    
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(leftButton_Clicked)];
    self.navigationItem.leftBarButtonItem = leftItem;
    

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightButton_Clicked)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    BOOL isContactSave = [[NSUserDefaults standardUserDefaults] objectForKey:@"isContactSave"];
    if (!isContactSave) {
        [self btnGetAllContacts:nil];
    }
    else{
        contactList = [NSMutableArray new];
        [contactList addObjectsFromArray:[self getAllInsertedContact]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)leftButton_Clicked{
    UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are sure to sync contact ?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"No",@"Yes", nil];
    
    [aView show];
}
-(void)rightButton_Clicked{
    AddContactVC *obj = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactVC"];
    obj.delegate = self;
    obj.isFromAddEdit = 0;
    [self.navigationController pushViewController:obj animated:YES];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        //Do nothing
    }
    else if (buttonIndex==1){
        [self syncContact];
    }
}
- (IBAction)btnGetAllContacts:(id)sender {
    
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        dispatch_release(semaphore);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook];
    }
    
}

// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        [dOfPerson setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"fname"];
        [dOfPerson setObject:[NSString stringWithFormat:@"%@", lastName] forKey:@"lname"];
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            
        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                break ;
            }
            
        }
        
        // User Image
        NSData *imageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image!=nil) {
            [dOfPerson setObject:image forKey:@"Image"];
        }
        
        
        [contactList addObject:dOfPerson];
        
    }
    [self insertIntoDb];
    NSLog(@"Contacts = %@",contactList);
}
-(void) insertIntoDb{
    for (int i=0; i<contactList.count; i++) {
        NSDictionary *dic = [contactList objectAtIndex:i];
        NSString *strfname = [dic objectForKey:@"fname"];
        NSString *strlname = [dic objectForKey:@"lname"];
        NSString *stremail = [dic objectForKey:@"email"];
        NSString *strphone = [dic objectForKey:@"Phone"];
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
        
        NSString *strQuery=[NSString stringWithFormat:@"insert into ContactList(Cl_FName,Cl_LName,Cl_Email,Cl_MobileNum,Cl_Image,Cl_IsFromContactBook)values('%@','%@','%@','%@','%@','1')",strfname,strlname,stremail,strphone,strimage];
        [Database executeScalarQuery:strQuery];
        
        NSString *strQuery2=[NSString stringWithFormat:@"select max(Cl_ID) from ContactList"];
        NSMutableArray *arrAll = [Database executeQuery:strQuery2];
        NSLog(@"arrAll %@",arrAll);
        
        NSString *strid = [[arrAll objectAtIndex:0] valueForKey:@"max(Cl_ID)"];
        NSString *stridPng = [NSString stringWithFormat:@"%@.png",strid];
        NSString *strQuery3=[NSString stringWithFormat:@"Update ContactList set Cl_Image='%@' where Cl_ID='%d'",stridPng,[strid intValue]];
        [Database executeScalarQuery:strQuery3];
        
        UIImage *imgUser = [dic objectForKey:@"Image"];
        if (imgUser!=nil) {
            [self saveImage:imgUser imageName:stridPng];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isContactSave"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [contactList removeAllObjects];
    
    [contactList addObjectsFromArray:[self getAllInsertedContact]];
    
    [tblView reloadData];
}
-(void)syncContact{
    NSString *strQuery1=[NSString stringWithFormat:@"Delete from ContactList where Cl_IsFromContactBook='1'"];
    [Database executeScalarQuery:strQuery1];
    
    [contactList removeAllObjects];
    
    [self btnGetAllContacts:nil];
}
-(void) saveImage:(UIImage*)img imageName:(NSString*)imgName{
    NSData *pngData = UIImagePNGRepresentation(img);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",imgName]]; //Add the file name
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
    [pngData writeToFile:filePath atomically:YES]; //Write the file
}
-(NSMutableArray*)getAllInsertedContact{
    NSString *strQuery=[NSString stringWithFormat:@"select * from ContactList ORDER BY Cl_FName"];
    NSMutableArray *arr = [Database executeQuery:strQuery];
    
    
    return arr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return contactList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TblViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    NSMutableDictionary *dic = [contactList objectAtIndex:indexPath.row];
    
    NSString *strFname = [dic objectForKey:@"Cl_FName"];
    NSString *strLname = [dic objectForKey:@"Cl_LName"];
    NSString *strFinalName;
    if (strFname.length==0 && strLname!=0) {
        strFinalName = strLname;
        
    }
    else if (strFname!=0 && strLname==0){
        strFinalName = strFname;
    }
    else if (strFname==0 && strLname==0){
        strFinalName = @"";
    }
    else if (strFname!=0 && strLname!=0){
        strFinalName = [NSString stringWithFormat:@"%@ %@",strFname,strLname];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",strFinalName];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AddContactVC *obj = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactVC"];
    obj.delegate = self;
    obj.isFromAddEdit = 1;
    obj.dicSel = [contactList objectAtIndex:indexPath.row];
    obj.indPath = (int)indexPath.row;
    [self.navigationController pushViewController:obj animated:YES];
}
-(void)updateArray:(NSMutableDictionary*)dic{
    
    NSLog(@"updateArray");
    [contactList addObject:dic];
    
//    [tblView reloadData];
    
    [tblView reloadData];
}
-(void)updateArrayAtIPath:(NSMutableDictionary*)dic iPath:(int)ipath{
    [contactList replaceObjectAtIndex:ipath withObject:dic];
    
    [tblView reloadData];
}
@end
