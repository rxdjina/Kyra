//
//  CreateSessionViewController.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateSessionViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *sessionNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;

@end

NS_ASSUME_NONNULL_END
