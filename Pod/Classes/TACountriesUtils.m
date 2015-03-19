//
// TACountriesUtils.m
// Copyright (c) 2015, Hariton Batkov
// All rights reserved.
//

#import "TACountriesUtils.h"

@implementation TACountriesUtils

+ (NSArray *)countryCodes {
    static NSArray *list = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Telegram-iOS-SDK.bundle/PhoneCountries" ofType:@"txt"];
                      NSData *stringData = [NSData dataWithContentsOfFile:filePath];
                      NSString *data = nil;
                      if (stringData != nil)
                          data = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
                      
                      if (data == nil)
                          return;
                      
                      NSString *delimiter = @";";
                      NSString *endOfLine = @"\n";
                      
                      NSMutableArray *array = [[NSMutableArray alloc] init];
                      
                      NSInteger currentLocation = 0;
                      while (true)
                      {
                          NSRange codeRange = [data rangeOfString:delimiter options:0 range:NSMakeRange(currentLocation, data.length - currentLocation)];
                          if (codeRange.location == NSNotFound)
                              break;
                          
                          NSInteger countryCode = [[data substringWithRange:NSMakeRange(currentLocation, codeRange.location - currentLocation)] integerValue];
                          
                          NSRange idRange = [data rangeOfString:delimiter options:0 range:NSMakeRange(codeRange.location + 1, data.length - (codeRange.location + 1))];
                          if (idRange.location == NSNotFound)
                              break;
                          
                          NSString *countryId = [[data substringWithRange:NSMakeRange(codeRange.location + 1, idRange.location - (codeRange.location + 1))] lowercaseString];
                          
                          NSRange nameRange = [data rangeOfString:endOfLine options:0 range:NSMakeRange(idRange.location + 1, data.length - (idRange.location + 1))];
                          if (nameRange.location == NSNotFound)
                              nameRange = NSMakeRange(data.length, INT_MAX);
                          
                          NSString *countryName = [data substringWithRange:NSMakeRange(idRange.location + 1, nameRange.location - (idRange.location + 1))];
                          if ([countryName hasSuffix:@"\r"])
                              countryName = [countryName substringToIndex:countryName.length - 1];
                          
                          [array addObject:[TACountry countryWithName:countryName ID:countryId code:countryCode]];
                          
                          currentLocation = nameRange.location + nameRange.length;
                          if (nameRange.length > 1)
                              break;
                      }
                      
                      list = array;
                  });
    return list;
}

+ (TACountry *)countryByCode:(int)code {
    for (TACountry *country in [self countryCodes]) {
        if (country.code == code)
            return country;
    }
    
    return nil;
}

+ (TACountry *)countryByCountryId:(NSString *)countryId {
    NSString *normalizedCountryId = [countryId lowercaseString];
    for (TACountry *country in [self countryCodes]) {
        if ([country.ID isEqualToString:normalizedCountryId]) {
            return country;
        }
    }
    return nil;
}

@end

@interface TACountry ()
+ (instancetype) countryWithName:(NSString *)name ID:(NSString *)ID code:(NSInteger)code;
@end

@implementation TACountry

+ (instancetype) countryWithName:(NSString *)name ID:(NSString *)ID code:(NSInteger)code {
    TACountry * country = [[self alloc] init];
    country.name = name;
    country.ID = ID;
    country.code = code;
    return country;
}

@end
