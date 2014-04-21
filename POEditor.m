//
//  NSString+POEditor.m
//  Fily
//
//  Created by David Gölzhäuser on 19.04.14.
//  Copyright (c) 2014 David Gölzhäuser. All rights reserved.
//

#import "POEditor.h"

@implementation POEditor

+(NSString *)localizedStringWithKey:(NSString *)key {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self languagePath]];
    if ([dict objectForKey:key]) {
        return [dict objectForKey:key];
    } else {
        return key;
    }
}

+(NSDictionary *)contributors {
    return [NSDictionary dictionaryWithContentsOfFile:[self contributorsPath]];
}

+(void)downloadDataWithAuthenticationToken:(NSString *)authToken andProjectID:(NSString *)projectID {
    NSMutableDictionary *contributorsDictionary = [NSMutableDictionary new];
    NSURL *contUrl = [NSURL URLWithString:@"http://poeditor.com/api/"];
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
                    NSString *language = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:languages[0]];
                    [contributorsDictionary setObject:@[name, email] forKey:[language stringByAppendingString:[NSString stringWithFormat:@" (%@)", languages[0]]]];
                }
                [contributorsDictionary writeToFile:[self contributorsPath] atomically:YES];
            }
        }
    }];
    
    NSMutableArray *languageArray = [NSMutableArray new];
    NSURL *langUrl = [NSURL URLWithString:@"http://poeditor.com/api/"];
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
                    NSURL *stringUrl = [NSURL URLWithString:@"http://poeditor.com/api/"];
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
                                NSMutableDictionary *mutableDict = [NSMutableDictionary new];
                                for (NSInteger i = 0; array.count>i; i++) {
                                    NSDictionary *listDictionary = [array objectAtIndex:i];
                                    NSDictionary *defenition = [listDictionary objectForKey:@"definition"];
                                    [mutableDict setObject:[defenition objectForKey:@"form"] forKey:[listDictionary objectForKey:@"term"]];
                                }
                                [mutableDict writeToFile:[self languagePath] atomically:YES];
                            }
                        }
                    }];
                }
            }
        }
    }];
}

+(NSString *)languagePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences/POEditorTranslations.plist"];
}

+(NSString *)contributorsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences/POEditorContributors.plist"];
}

@end
