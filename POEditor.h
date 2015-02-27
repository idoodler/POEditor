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
 @return NSString
*/
+(NSString *)localizedStringWithKey:(NSString *)key;

/**
 Return the Dictionary of Contrubutors in this formate @{@[Name, Email], Language}, e.g. @{@[David, me@icloud.com], German (de)}
 @return NSDictionary
*/
+(NSDictionary *)contributors;

//Extended functions

/**
 Returns all projects
 @param token The authToken
 @note Returns the projects in this formate @[@{ProjectName : ProjectIP}]
 @return NSArray
 */
+(NSArray *)projects:(NSString *)token;

/**
 Returns the available languages for the project in this formate: @[@[Language Name, Percentage, Language Code]]
 @param projectID This is the project ID of the Project, please take a look at [POEditor projects];
 @param token The authToken
 @return NSArray
 */
+(NSArray *)languagesForProjectID:(NSString *)projectID andToken:(NSString *)token;

/**
 Returns an array of all strings for the project.
 @prarm projectID The Project ID please take a look at [POEditor projects];
 @param langCode The language code of the country
 @param token The authToken
 @note Take a look at [[NSLocale preferredLanguages] objectAtIndex:0]
 @return NSArray
 */
+(NSArray *)stringsFromProjectID:(NSString *)projectID languageCode:(NSString *)langCode andToken:(NSString *)token;

/**
 This will commit a new term to your project
 @param term The term you want to commit
 @param nativeTerm This can be a blank string
 @param projectID The project Id you want to commit the term
 @param langCode The language code you want to commit the term
 @param token The authToken
 @return BOOL
 */
+(BOOL)commitTerm:(NSString *)term andNativeTerm:(NSString *)nativeTerm projectID:(NSString *)projectID language:(NSString *)langCode andToken:(NSString *)token;

/**
 Returns the filepath of all unlocalized strings (saved as a .plist)
 @return NSString
 */
+(NSString *)unlocalizedPath;

/**
 Returns the filepath of all strings for the matching language (saved as a .plist)
 */
+(NSString *)languagePath;


@end
