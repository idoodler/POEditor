POEditor
========

An easy to use class to get localisations from POEditor

An easy to use class to get localisations from POEditor. Just drag POEditor.h and POEditor.m to Xcode. Then import POEditor.h and start to use it.

I recogment to call 
```Objective-c
[POEditor downloadDataWithAuthenticationToken:@"Your_Token" andProjectID:@"Your_Project_ID"];
```
everytime the user starts the application, so the data always is up-to-date. Then you can replace 
```Objective-C
NSLocalizedString(@"String", nil)
```
with 

```Objective-C
[POEditor localizedStringWithKey:@"String"]
```
In addition you can get the contributors of your project. Just call 

```Objective-C
[POEditor contributors];
```
this will return a 
```Objective-C
NSDictionary
```
in this formate: 
```Objective-C
@{@[Name, Email], Language}
```
I implemented Xcodes dokumentation function to make it even easier to understand. Have fun and please make an issue if you miss a feature of find a bug. Have a nice day!
