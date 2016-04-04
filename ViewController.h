//
//  ViewController.h
//  Contact
//
//  Created by multicoreViral on 3/29/16.
//  Copyright © 2016 multicore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
#import "tblViewCell.h"
#import "AddContactVC.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AddContactVCDelegate,UIAlertViewDelegate>{
    IBOutlet UITableView *tblView;
}


@end

