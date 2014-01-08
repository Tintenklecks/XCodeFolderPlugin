//
//  XCodeFolderPlugin.m
//  XCodeFolderPlugin
//
//  Created by Ingo Böhme on 08.01.14.
//    Copyright (c) 2014 AMOS. All rights reserved.
//
// Just adds some important folders to the file menu to be
// opened with the finder

#import "XCodeFolderPlugin.h"

static XCodeFolderPlugin *sharedPlugin;

@interface XCodeFolderPlugin()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray *folders;
@property (nonatomic, strong) NSMenuItem *subMenu;
@property (nonatomic, strong) NSMenu *fileSubMenu;

@end

@implementation XCodeFolderPlugin



- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        self.folders = [[NSMutableArray alloc] initWithCapacity:0];
        
        // Sample Menu Item:
        NSMenuItem *mainMenuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (!mainMenuItem) return self;
        [[mainMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        _subMenu = [[NSMenuItem alloc] initWithTitle:@"Open Xcode folder" action:nil keyEquivalent:@""];
        [[mainMenuItem submenu] addItem:_subMenu];
        
        _fileSubMenu = [[NSMenu alloc] init];
        [_subMenu setSubmenu:_fileSubMenu];
        
        
        

        
        // ADD Folder menus
        
        [self addFolderMenuWithCaption:@"Custom Templates" andPath:@"~/Library/Developer/Xcode/Templates/"];
        [self addFolderMenuWithCaption:@"XCode Templates" andPath:@"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates"];
        [self addFolderMenuWithCaption:@"Snapshots" andPath:@"~/Library/Developer/Xcode/Snapshots/"];
        [self addFolderMenuWithCaption:@"Derived Data" andPath:@"~/Library/Developer/Xcode/DerivedData/"];
        [self addFolderMenuWithCaption:@"XCode Plugins" andPath:@"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"];
        [self addFolderMenuWithCaption:@"just a spacer ;-)" andPath:@""];
        [self addFolderMenuWithCaption:@"iOS File/Project Templates" andPath:@"~/Library/Developer/Xcode/Templates/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/"];
        [self addFolderMenuWithCaption:@"just a spacer ;-)" andPath:@""];
        [self addFolderMenuWithCaption:@"iOS Simulator" andPath:@"~/Library/Application Support/iPhone Simulator/"];
        
        
        
        
    }
    return self;
}







+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

-(void) addFolderMenuWithCaption: (NSString*) caption andPath: (NSString*) path {
    static int counter = -1;
    
    if ([path length]==0) {
        [_fileSubMenu addItem:[NSMenuItem separatorItem]];
        return;

    }
    counter ++;
    
    NSMenuItem *subMenuItem =[[NSMenuItem alloc] initWithTitle:caption action:@selector(doMenuAction:) keyEquivalent:@""];
    [subMenuItem setTarget:self];
    [subMenuItem setTag:counter];
    
    [_fileSubMenu  addItem:subMenuItem];

    [_folders addObject:path];

    
    
}



// Sample Action, for menu item:
- (void)doMenuAction: (NSMenuItem*) sender
{
    if (sender.tag >= 0 && sender.tag<[_folders count]) {
        NSString *path = [_folders objectAtIndex:sender.tag ]; // Get path from array
        path = [path  stringByReplacingOccurrencesOfString:@"~" withString:NSHomeDirectory()]; // replace ~ in path with user home folder
        NSURL *folderURL = [NSURL fileURLWithPath:path isDirectory:YES];
        [[NSWorkspace sharedWorkspace] openURL: folderURL];
    }
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
