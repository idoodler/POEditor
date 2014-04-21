//
//  NSString+POEditor.h
//  Fily
//
//  Created by David Gölzhäuser on 19.04.14.
//  Copyright (c) 2014 David Gölzhäuser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POEditor : NSObject

/**
 Downloads the necessary data.
 @param authToken This is the authentication token of your API, you can optain it here: https://poeditor.com/account/api
 @param projectID The id of your POEditor project, you can optain it here: https://poeditor.com/account/api
 @note You may call this methode on the application start
*/
+(void)downloadDataWithAuthenticationToken:(NSString *)authToken andProjectID:(NSString *)projectID;

/**
 Returns the translated string for "key" if there is no string for "key", "key" will be returned instead.
 @param key This is string you like to get tle localized string for.
*/
+(NSString *)localizedStringWithKey:(NSString *)key;

/**
 Return the Dictionary of Contrubutors in this formate @{@[Name, Email], Language}, e.g. @{@[David, me@icloud.com], German (de)}
*/
+(NSDictionary *)contributors;

@end
