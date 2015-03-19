//
//  TAPhoneFormattingManager.h
//  Pods
//
//  Created by Hariton Batkov on 3/18/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TACountriesUtils.h"

@protocol TAPhoneFormattingDelegate;

/**
 * This class needed to handle events while user will type phone number;
 * Class handles: choose country by tapping on button, choose country by entering code, format just entered phone.
 */
@interface TAPhoneFormattingManager : NSObject
@property (nonatomic, weak) id <TAPhoneFormattingDelegate> delegate;

@property (nonatomic, strong, readonly) NSString * formattedPhone;
/* Should be called from '-textField:shouldChangeCharactersInRange:replacementString:'
 * for text field UITextField that will contain Country Code
 * Note: country code get and set with '+' sign
 */
- (BOOL) countryCodeTextField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
           replacementString:(NSString *)string;

/* Should be called from '-textField:shouldChangeCharactersInRange:replacementString:'
 * for text field UITextField that will contain Phone Number
 */
- (BOOL) phoneNumberTextField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string;

+ (instancetype) phoneFormattingManager:(id <TAPhoneFormattingDelegate>) delegate;

- (void) format;

@end

@protocol TAPhoneFormattingDelegate <NSObject>

- (NSString *) countryCodeForPhoneFormattingManager:(TAPhoneFormattingManager *)formattingManager;
- (NSString *) phoneNumberForPhoneFormattingManager:(TAPhoneFormattingManager *)formattingManager;
- (void) phoneFormattingManager:(TAPhoneFormattingManager *)formattingManager setCountryCode:(NSString *) code;
- (void) phoneFormattingManager:(TAPhoneFormattingManager *)formattingManager setPhoneNumber:(NSString *) phoneNumber;
@optional
- (void) phoneFormattingManager:(TAPhoneFormattingManager *)formattingManager countryDetected:(TACountry *)country;

@end