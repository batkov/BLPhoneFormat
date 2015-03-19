//
//  BLPhoneFormattingManager.h
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BLCountriesUtils.h"

@protocol BLPhoneFormattingDelegate;

/**
 * This class needed to handle events while user will type phone number;
 * Class handles: choose country by tapping on button, choose country by entering code, format just entered phone.
 */
@interface BLPhoneFormattingManager : NSObject
@property (nonatomic, weak) id <BLPhoneFormattingDelegate> delegate;

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

+ (instancetype) phoneFormattingManager:(id <BLPhoneFormattingDelegate>) delegate;

- (void) format;

@end

@protocol BLPhoneFormattingDelegate <NSObject>

- (NSString *) countryCodeForPhoneFormattingManager:(BLPhoneFormattingManager *)formattingManager;
- (NSString *) phoneNumberForPhoneFormattingManager:(BLPhoneFormattingManager *)formattingManager;
- (void) phoneFormattingManager:(BLPhoneFormattingManager *)formattingManager setCountryCode:(NSString *) code;
- (void) phoneFormattingManager:(BLPhoneFormattingManager *)formattingManager setPhoneNumber:(NSString *) phoneNumber;
@optional
- (void) phoneFormattingManager:(BLPhoneFormattingManager *)formattingManager countryDetected:(BLCountry *)country;

@end