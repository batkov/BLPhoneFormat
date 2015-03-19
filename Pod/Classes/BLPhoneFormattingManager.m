// BLPhoneFormattingManager.m
// Copyright (c) 2015, Hariton Batkov

#import "BLPhoneFormattingManager.h"

#import "RMPhoneFormat.h"


@interface BLPhoneFormattingManager ()
@property (nonatomic, strong, readwrite) NSString * formattedPhone;
@end

@implementation BLPhoneFormattingManager

+ (instancetype) phoneFormattingManager:(id <BLPhoneFormattingDelegate>) delegate {
    BLPhoneFormattingManager * manager = [self new];
    manager.delegate = delegate;
    return manager;
}

- (BOOL) countryCodeTextField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {
    NSUInteger length = string.length;
    unichar replacementCharacters[length];
    int filteredLength = 0;
    
    for (int i = 0; i < length; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (c >= '0' && c <= '9')
            replacementCharacters[filteredLength++] = c;
    }
    
    if (filteredLength == 0 && (range.length == 0 || range.location == 0))
        return false;
    
    if (range.location == 0)
        range.location++;
    
    NSString *replacementString = [[NSString alloc] initWithCharacters:replacementCharacters length:filteredLength];
    
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
    if (newText.length > 5)
    {
        for (int i = 0; i < (int)newText.length - 1; i++)
        {
            int countryCode = [[newText substringWithRange:NSMakeRange(1, newText.length - 1 - i)] intValue];
            BLCountry *country = [BLCountriesUtils countryByCode:countryCode];
            if (country != nil)
            {
                NSString * newPhone = [[NSString alloc] initWithFormat:@"%@%@", [newText substringFromIndex:newText.length - i], [self phoneNumber]];
                [self setPhoneNumber:[self filterPhoneText:newPhone]];
                newText = [newText substringToIndex:newText.length - i];
                [self setCountry:country];
            }
        }
        
        if (newText.length > 5)
            newText = [newText substringToIndex:5];
    }
    
    textField.text = newText;
    
    [self updatePhoneText];
    
    [self updateCountry];
    
    [self updateTitleText];
    
    return false;
}

- (BOOL) phoneNumberTextField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {
    NSUInteger stringLength = string.length;
    unichar replacementCharacters[stringLength];
    int filteredLength = 0;
    
    for (int i = 0; i < stringLength; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (c >= '0' && c <= '9')
            replacementCharacters[filteredLength++] = c;
    }
    
    NSString *replacementString = [[NSString alloc] initWithCharacters:replacementCharacters length:filteredLength];
    
    unichar rawNewString[replacementString.length];
    int rawNewStringLength = 0;
    
    NSUInteger replacementLength = replacementString.length;
    for (int i = 0; i < replacementLength; i++)
    {
        unichar c = [replacementString characterAtIndex:i];
        if ((c >= '0' && c <= '9'))
            rawNewString[rawNewStringLength++] = c;
    }
    
    NSString *resultString = [[NSString alloc] initWithCharacters:rawNewString length:rawNewStringLength];
    
    NSMutableString *rawText = [[NSMutableString alloc] initWithCapacity:16];
    NSString *currentText = textField.text;
    NSUInteger length = currentText.length;
    
    NSUInteger originalLocation = range.location;
    NSInteger originalEndLocation = range.location + range.length;
    NSInteger endLocation = originalEndLocation;
    
    for (int i = 0; i < length; i++)
    {
        unichar c = [currentText characterAtIndex:i];
        if ((c >= '0' && c <= '9'))
            [rawText appendString:[[NSString alloc] initWithCharacters:&c length:1]];
        else
        {
            if (originalLocation > i)
            {
                if (range.location > 0)
                    range.location--;
            }
            
            if (originalEndLocation > i)
                endLocation--;
        }
    }
    
    NSInteger newLength = endLocation - range.location;
    if (newLength == 0 && range.length == 1 && range.location > 0)
    {
        range.location--;
        newLength = 1;
    }
    if (newLength < 0)
        return false;
    
    range.length = newLength;
    
    @try
    {
        NSInteger caretPosition = range.location + resultString.length;
        
        [rawText replaceCharactersInRange:range withString:resultString];
        
        NSString *countryCodeText = [self countryCode].length > 1 ? [self countryCode] : @"";
        NSString * phone = [[NSString alloc] initWithFormat:@"%@%@", countryCodeText, rawText];
        NSString *formattedText = [[RMPhoneFormat instance] format:phone implicitPlus:false];
        if (countryCodeText.length > 1)
        {
            int i = 0;
            int j = 0;
            while (i < (int)formattedText.length && j < (int)countryCodeText.length)
            {
                unichar c1 = [formattedText characterAtIndex:i];
                unichar c2 = [countryCodeText characterAtIndex:j];
                if (c1 == c2)
                    j++;
                i++;
            }
            
            formattedText = [formattedText substringFromIndex:i];
            
            i = 0;
            while (i < (int)formattedText.length)
            {
                unichar c = [formattedText characterAtIndex:i];
                if (c == '(' || c == ')' || (c >= '0' && c <= '9'))
                    break;
                
                i++;
            }
            
            formattedText = [self filterPhoneText:[formattedText substringFromIndex:i]];
        }
        
        NSUInteger formattedTextLength = formattedText.length;
        NSUInteger rawTextLength = rawText.length;
        
        NSInteger newCaretPosition = caretPosition;
        
        for (int j = 0, k = 0; j < formattedTextLength && k < rawTextLength; )
        {
            unichar c1 = [formattedText characterAtIndex:j];
            unichar c2 = [rawText characterAtIndex:k];
            if (c1 != c2)
                newCaretPosition++;
            else
                k++;
            
            if (k == caretPosition)
            {
                break;
            }
            
            j++;
        }
        
        textField.text = formattedText;
        
        [self updateTitleText];
        
        if (caretPosition >= (int)textField.text.length)
            caretPosition = textField.text.length;
        
        UITextPosition *startPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCaretPosition];
        UITextPosition *endPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCaretPosition];
        UITextRange *selection = [textField textRangeFromPosition:startPosition toPosition:endPosition];
        textField.selectedTextRange = selection;
    }
    @catch (NSException *e)
    {
    }
    
    return false;
}

- (NSString *)filterPhoneText:(NSString *)text
{
    int i = 0;
    while (i < (int)text.length)
    {
        unichar c = [text characterAtIndex:i];
        if ((c >= '0' && c <= '9'))
            return text;
        
        i++;
    }
    
    return @"";
}

- (void)updatePhoneText
{
    NSString *rawText = [self phoneNumber];
    NSString * countryCodeText = [self countryCode];
    NSString *formattedText = [[RMPhoneFormat instance] format:[[NSString alloc] initWithFormat:@"%@%@", countryCodeText, rawText] implicitPlus:false];
    if (countryCodeText.length > 1)
    {
        int i = 0;
        int j = 0;
        while (i < (int)formattedText.length && j < (int)countryCodeText.length)
        {
            unichar c1 = [formattedText characterAtIndex:i];
            unichar c2 = [countryCodeText characterAtIndex:j];
            if (c1 == c2)
                j++;
            i++;
        }
        
        formattedText = [formattedText substringFromIndex:i];
        
        i = 0;
        while (i < (int)formattedText.length)
        {
            unichar c = [formattedText characterAtIndex:i];
            if (c == '(' || c == ')' || (c >= '0' && c <= '9'))
                break;
            
            i++;
        }
        
        formattedText = [formattedText substringFromIndex:i];
        [self setPhoneNumber:[self filterPhoneText:formattedText]];
    }
    else
        [self setPhoneNumber:[self filterPhoneText:[[RMPhoneFormat instance] format:[[NSString alloc] initWithFormat:@"%@", [self phoneNumber]] implicitPlus:false]]];
}

- (void)updateTitleText
{
    NSString *rawString = [[NSString alloc] initWithFormat:@"%@%@", [self countryCode], [self phoneNumber]];
    
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i = 0; i < (int)rawString.length; i++)
    {
        unichar c = [rawString characterAtIndex:i];
        if (c >= '0' && c <= '9')
            [string appendString:[[NSString alloc] initWithCharacters:&c length:1]];
    }
    
    if (string.length == 0 || [self phoneNumber].length == 0 || [self countryCode].length <= 1)
        self.formattedPhone = @"";
    else
        self.formattedPhone = [[RMPhoneFormat instance] format:string implicitPlus:true];
}
- (void) format {
    [self updateTitleText];
    [self updateCountry];
}

- (void)updateCountry
{
    int countryCode = [[[self countryCode] substringFromIndex:1] intValue];
    [self setCountry:[BLCountriesUtils countryByCode:countryCode]];
}

- (NSString *) countryCode {
    return [self.delegate countryCodeForPhoneFormattingManager:self];
}

- (NSString *) phoneNumber {
    return [self.delegate phoneNumberForPhoneFormattingManager:self];
}

- (void) setPhoneNumber:(NSString *)phoneNumber {
    [self.delegate phoneFormattingManager:self setPhoneNumber:phoneNumber];
}

- (void) setCountryCode:(NSString *)countryCode {
    [self.delegate phoneFormattingManager:self setCountryCode:countryCode];
}

- (void) setCountry:(BLCountry *)country {
    if (![self.delegate respondsToSelector:@selector(phoneFormattingManager:countryDetected:)])
        return;
    [self.delegate phoneFormattingManager:self countryDetected:country];
}

@end

