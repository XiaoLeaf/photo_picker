#import "PhotoPickerPlugin.h"
#import <ZLPhotoBrowser/ZLPhotoBrowser.h>

@implementation PhotoPickerPlugin {
    FlutterResult flutterResult;
    UIViewController *controller;
    NSMutableArray<PHAsset *> *selectedAssets;
    __block NSMutableArray *resultList;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"photo_picker"
            binaryMessenger:[registrar messenger]];
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    PhotoPickerPlugin *instance = [[PhotoPickerPlugin alloc] initWithViewController:viewController];
//  PhotoPickerPlugin* instance = [[PhotoPickerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        controller = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"Leaf封装的图片选择插件");
    if (!flutterResult) {
        flutterResult([FlutterError errorWithCode:@"pick_request" message:@"Canceled" details:nil]);
        flutterResult = nil;
    }
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"pickPhoto" isEqualToString:call.method]) {
      NSInteger maxCount = [call.arguments integerValue];
      flutterResult = result;
      ZLPhotoActionSheet *photoActionSheet = [[ZLPhotoActionSheet alloc] init];
      [photoActionSheet.configuration setMaxSelectCount:maxCount];
      [photoActionSheet.configuration setAllowSelectGif:NO];
      [photoActionSheet.configuration setAllowEditVideo:NO];
      [photoActionSheet.configuration setAllowEditImage:YES];
      [photoActionSheet.configuration setAllowMixSelect:NO];
      [photoActionSheet.configuration setAllowSelectVideo:NO];
      [photoActionSheet.configuration setAllowTakePhotoInLibrary:NO];
      [photoActionSheet.configuration setStatusBarStyle:UIStatusBarStyleLightContent];
      //    [photoActionSheet.configuration setNavBarColor:[UtilsMacro colorWithHexString:@"FE560F"]];
      photoActionSheet.sender = controller;
      if (maxCount > 1) {
          [photoActionSheet setArrSelectedAssets:selectedAssets];
      }
      [photoActionSheet showPhotoLibrary];
      
      [photoActionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
          self->selectedAssets = [[NSMutableArray alloc] initWithArray:assets];
          self->resultList = [[NSMutableArray alloc] init];
          for (int i = 0; i < [images count]; i++) {
              NSData *data = UIImagePNGRepresentation([images objectAtIndex:i]);
              NSString *fileExtension = @"photo_picker%@.png";
              NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
              NSString *tmpFile = [NSString stringWithFormat:fileExtension, guid];
              NSString *tmpDirectory = NSTemporaryDirectory();
              NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
              if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
                  [self->resultList addObject:tmpPath];
              }
          }
          NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:self->resultList,@"result", nil];
          //        NSLog(@"resultDict:%@",resultDict);
          self->flutterResult(resultDict);
      }];
      
      [photoActionSheet setCancleBlock:^{
          NSDictionary *resultDict;
          if (!self->resultList) {
              resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:@[],@"result", nil];
          } else {
              resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:self->resultList,@"result", nil];
          }
          //        NSLog(@"cancel---resultDict:%@",resultDict);
          self->flutterResult(resultDict);
      }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
