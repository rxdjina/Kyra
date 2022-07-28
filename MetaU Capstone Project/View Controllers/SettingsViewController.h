//
//  SettingsViewController.h
//  MetaU Capstone Project
//
//  Created by Rodjina Pierre Louis on 7/28/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *updatedPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmUpdatedPasswordTextField;

@property (strong, nonatomic) IBOutlet UIButton *updateEmailButton;
@property (strong, nonatomic) IBOutlet UIButton *updatePasswordButton;

@end

NS_ASSUME_NONNULL_END
