//
//  NSString+POEditor.m
//  Fily
//
//  Created by David Gölzhäuser on 19.04.14.
//  Copyright (c) 2014 David Gölzhäuser. All rights reserved.
//

#import "POEditor.h"

@implementation POEditor
NSMutableDictionary *contributorsDictionary;
NSMutableDictionary *langDict;
NSString *userToken;

+(NSString *)localizedStringWithKey:(NSString *)key {
    @try {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self languagePath]];
        if ([dict objectForKey:key] && ![[dict objectForKey:key] isEqualToString:@""]) {
            return [dict objectForKey:key];
        } else {
            [self logUnlocalizedStirng:key];
            return key;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error at line %d:\n%@", __LINE__, exception);
        return @"Unlocalized String!!";
    }
}

+(void)logUnlocalizedStirng:(NSString *)string {
    //[Crashlytics setObjectValue:string forKey:@"Unlocalized String"];
    NSMutableArray *arr = [NSMutableArray new];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self unlocalizedPath]]) {
        arr = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self unlocalizedPath]] options:kNilOptions error:nil];
        if (![arr containsObject:string]) {
            [arr addObject:string];
        }
    } else {
        [arr addObject:string];
    }
    [arr writeToFile:[self unlocalizedPath] atomically:YES];
}

+(NSDictionary *)contributors {
    return [NSDictionary dictionaryWithContentsOfFile:[self contributorsPath]];
}

+(void)downloadDataWithAuthenticationToken:(NSString *)authToken andProjectID:(NSString *)projectID {
    NSAssert(authToken, @"You need to pass the authToken, you can find it here: https://poeditor.com/account/api");
    NSAssert(projectID, @"You need to pass the projectID, you can find it here: https://poeditor.com/account/api");
    @try {
        contributorsDictionary = [NSMutableDictionary new];
        langDict = [NSMutableDictionary new];
        NSURL *contUrl = [NSURL URLWithString:@"https://poeditor.com/api/"];
        NSMutableURLRequest *contRequest = [NSMutableURLRequest requestWithURL:[contUrl standardizedURL]];
        [contRequest setHTTPMethod:@"POST"];
        NSString *postContData = [NSString stringWithFormat:@"api_token=%@&action=list_contributors&id=%@", authToken, projectID];
        [contRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [contRequest setHTTPBody:[postContData dataUsingEncoding:NSUTF8StringEncoding]];
        [NSURLConnection sendAsynchronousRequest:contRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                if (![[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] isEqualToString:@"{\"response\":{\"status\":\"fail\",\"message\":\"Please use a POST request.\",\"code\":4012}}"]) {
                    NSError *error;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSArray *array = [dict objectForKey:@"list"];
                    for (NSInteger i = 0; array.count>i; i++) {
                        NSDictionary *listDictionary = [array objectAtIndex:i];
                        NSArray *projects = [listDictionary objectForKey:@"projects"];
                        NSDictionary *item0 = [projects objectAtIndex:0];
                        NSArray *languages = [item0 objectForKey:@"languages"];
                        
                        NSString *name = [listDictionary objectForKey:@"name"];
                        NSString *email = [listDictionary objectForKey:@"email"];
                        NSString *language;
#if TARGET_IPHONE_SIMULATOR //Bacause it wont work on the simulator
                        language = @"Deutschland";
#else
                        language = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:languages[0]];
#endif
                        [contributorsDictionary setObject:@[name, email] forKey:[language stringByAppendingString:[NSString stringWithFormat:@" (%@)", languages[0]]]];
                    }
                    [contributorsDictionary writeToFile:[self contributorsPath] atomically:YES];
                }
            }
        }];
        NSMutableArray *languageArray = [NSMutableArray new];
        NSURL *langUrl = [NSURL URLWithString:@"https://poeditor.com/api/"];
        NSMutableURLRequest *langRequest = [NSMutableURLRequest requestWithURL:[langUrl standardizedURL]];
        [langRequest setHTTPMethod:@"POST"];
        NSString *postLangData = [NSString stringWithFormat:@"api_token=%@&action=list_languages&id=%@", authToken, projectID];
        [langRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [langRequest setHTTPBody:[postLangData dataUsingEncoding:NSUTF8StringEncoding]];
        [NSURLConnection sendAsynchronousRequest:langRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                if (![[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] isEqualToString:@"{\"response\":{\"status\":\"fail\",\"message\":\"Please use a POST request.\",\"code\":4012}}"]) {
                    NSError *error;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSArray *array = [dict objectForKey:@"list"];
                    for (NSInteger i = 0; array.count>i; i++) {
                        NSDictionary *listDictionary = [array objectAtIndex:i];
                        [languageArray addObject:[listDictionary objectForKey:@"code"]];
                    }
                    if ([languageArray containsObject:[[NSLocale preferredLanguages] objectAtIndex:0]]) {
                        NSURL *stringUrl = [NSURL URLWithString:@"https://poeditor.com/api/"];
                        NSMutableURLRequest *stringRequest = [NSMutableURLRequest requestWithURL:[stringUrl standardizedURL]];
                        [stringRequest setHTTPMethod:@"POST"];
                        NSString *postStringData = [NSString stringWithFormat:@"api_token=%@&action=view_terms&id=%@&language=%@", authToken, projectID, [[NSLocale preferredLanguages] objectAtIndex:0]];
                        [stringRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                        [stringRequest setHTTPBody:[postStringData dataUsingEncoding:NSUTF8StringEncoding]];
                        [NSURLConnection sendAsynchronousRequest:stringRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            if (!connectionError) {
                                if (![[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] isEqualToString:@"{\"response\":{\"status\":\"fail\",\"message\":\"Please use a POST request.\",\"code\":4012}}"]) {
                                    NSError *error;
                                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                    NSArray *array = [dict objectForKey:@"list"];
                                    for (NSInteger i = 0; array.count>i; i++) {
                                        NSDictionary *listDictionary = [array objectAtIndex:i];
                                        NSDictionary *defenition = [listDictionary objectForKey:@"definition"];
                                        [langDict setObject:[defenition objectForKey:@"form"] forKey:[listDictionary objectForKey:@"term"]];
                                    }
                                    [langDict writeToFile:[self languagePath] atomically:YES];
                                }
                            }
                        }];
                    }
                }
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Error at line %d, no data has been dowloaded:\n%@", __LINE__, exception);
    }
}

+(NSString *)languagePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences/POEditorTranslations.plist"];
}

+(NSString *)contributorsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences/POEditorContributors.plist"];
}

+(NSString *)unlocalizedPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences/UnlocalizedStrings.plist"];
}

//Extended functions

+(NSArray *)projects:(NSString *)token {
    NSMutableArray *returnArray = [NSMutableArray new];
    NSURL *baseURL = [NSURL URLWithString:@"https://poeditor.com/api/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL standardizedURL]];
    [request setHTTPMethod:@"POST"];
    NSString *data = [NSString stringWithFormat:@"api_token%@&action=list_projects", token];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        if (![responseString isEqualToString:@"{\"response\":{\"status\":\"fail\",\"message\":\"Please use a POST request.\",\"code\":4012}}"]) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            NSArray *listArray = [responseDict objectForKey:@"list"];
            for (NSDictionary *dict in listArray) {
                [returnArray addObject:@{[dict objectForKey:@"name"]: [dict objectForKey:@"id"]}];
            }
        }
    } else {
        return nil;
    }
    
    return (NSArray *)returnArray;
    
}

+(NSArray *)languagesForProjectID:(NSString *)projectID andToken:(NSString *)token {
    NSAssert(projectID, @"You need to pass peojectID, you can find it here: https://poeditor.com/account/api");
    NSMutableArray *returnArray = [NSMutableArray new];
    NSURL *baseURL = [NSURL URLWithString:@"https://poeditor.com/api/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL standardizedURL]];
    [request setHTTPMethod:@"POST"];
    NSString *data = [NSString stringWithFormat:@"api_token=%@&action=list_languages&id=%@", token, projectID];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        if (![responseString isEqualToString:@"{\"response\":{\"status\":\"fail\",\"message\":\"Please use a POST request.\",\"code\":4012}}"]) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            NSArray *listArray = [responseDict objectForKey:@"list"];
            for (NSDictionary *dict in listArray) {
                [returnArray addObject:@[[dict objectForKey:@"name"], [dict objectForKey:@"percentage"], [dict objectForKey:@"code"]]];
            }
        }
    } else {
        return nil;
    }
    
    return (NSArray *)returnArray;
}

+(NSArray *)stringsFromProjectID:(NSString *)projectID languageCode:(NSString *)langCode andToken:(NSString *)token {
    NSAssert(projectID, @"You need to pass peojectID, you can find it here: https://poeditor.com/account/api");
    NSAssert(langCode, @"You need to pass langCode");
    NSMutableArray *returnArray = [NSMutableArray new];
    NSURL *baseURL = [NSURL URLWithString:@"https://poeditor.com/api/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL standardizedURL]];
    [request setHTTPMethod:@"POST"];
    NSString *data = [NSString stringWithFormat:@"api_token=%@&action=view_terms&id=%@&language=%@", token, projectID, langCode];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        if (![responseString isEqualToString:@"{\"response\":{\"status\":\"fail\",\"message\":\"Please use a POST request.\",\"code\":4012}}"]) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            NSArray *listArray = [responseDict objectForKey:@"list"];
            for (NSDictionary *dict in listArray) {
                [returnArray addObject:@[[dict objectForKey:@"term"], [[dict objectForKey:@"definition"] objectForKey:@"form"]]];
            }
        }
    } else {
        return nil;
    }
    
    return (NSArray *)returnArray;
}

+(BOOL )commitTerm:(NSString *)term andNativeTerm:(NSString *)nativeTerm projectID:(NSString *)projectID language:(NSString *)langCode andToken:(NSString *)token {
    NSAssert(term, @"You need to pass term, the term you want to translate");
    NSAssert(nativeTerm, @"You need to pass nativeTerm, the  translated term");
    NSAssert(projectID, @"You need to pass peojectID, you can find it here: https://poeditor.com/account/api");
    NSAssert(langCode, @"You need to pass langCode of the translated term (nativeTerm)");
    NSURL *baseURL = [NSURL URLWithString:@"https://poeditor.com/api/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL standardizedURL]];
    [request setHTTPMethod:@"POST"];
    NSString *jsonString = [NSString stringWithFormat:@"[{\"term\":{\"term\":\"%@\",\"context\":\"\"},\"definition\":{\"forms\":[\"%@\"],\"fuzzy\":\"0\"}}]", term, nativeTerm];
    NSString *data = [NSString stringWithFormat:@"api_token=%@&action=update_language&id=%@&language=%@&data=%@", token, projectID, langCode, jsonString];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        if (![responseString isEqualToString:@"{\"response\":{\"status\":\"fail\",\"message\":\"Please use a POST request.\",\"code\":4012}}"]) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
            if ([[[responseDict objectForKey:@"response"] objectForKey:@"status"] isEqualToString:@"success"]) {
                return YES;
            }
        }
    } else {
        return NO;
    }
    
    return NO;
}


@end
