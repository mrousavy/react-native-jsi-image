//
//  JsiImage.mm
//  JsiImage
//
//  Created by Marc Rousavy on 04.01.22.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import "JsiImage.h"
#import "ImageHostObject.h"

#import <React/RCTBridge+Private.h>
#import <React/RCTUtils.h>
#import <jsi/jsi.h>

using namespace facebook;

@implementation JsiImage
@synthesize bridge = _bridge;
@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

static void install(jsi::Runtime & jsiRuntime)
{
  // jsiImageCreateFromFile(filePath)
  auto jsiImageCreateFromFile = jsi::Function::createFromHostFunction(jsiRuntime,
                                                                      jsi::PropNameID::forAscii(jsiRuntime, "jsiImageCreateFromFile"),
                                                                      1,
                                                                      [](jsi::Runtime& runtime,
                                                                         const jsi::Value& thisValue,
                                                                         const jsi::Value* arguments,
                                                                         size_t count) -> jsi::Value {
    if (count != 1) {
      throw jsi::JSError(runtime, "jsiImageCreateFromFile(..) expects one argument (string)!");
    }
    auto string = arguments[0].asString(runtime).utf8(runtime);
    auto path = [NSString stringWithUTF8String:string.c_str()];
    
    auto image = [[UIImage alloc] initWithContentsOfFile:path];
    if (image == nil) {
      auto message = "Failed to load image from path \"" + string + "\"!";
      throw jsi::JSError(runtime, message);
    }
    
    auto instance = std::make_shared<ImageHostObject>(image);
    return jsi::Object::createFromHostObject(runtime, instance);
  });
  jsiRuntime.global().setProperty(jsiRuntime, "jsiImageCreateFromFile", std::move(jsiImageCreateFromFile));
}

- (void)setup
{
  RCTCxxBridge *cxxBridge = (RCTCxxBridge *)self.bridge;
  if (!cxxBridge.runtime) {
    // retry 10ms later - THIS IS A WACK WORKAROUND. wait for TurboModules to land.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [self setup];
    });
    return;
  }
  
  install(*(jsi::Runtime *)cxxBridge.runtime);
}

- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;
  _setBridgeOnMainQueue = RCTIsMainQueue();
  [self setup];
}

@end
