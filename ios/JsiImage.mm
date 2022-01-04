//
//  JsiImage.mm
//  JsiImage
//
//  Created by Marc Rousavy on 04.01.22.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import "JsiImage.h"
#import "ImageHostObject.h"

#import <React/RCTBridge.h>
#import <ReactCommon/RCTTurboModule.h>
#import <React/RCTBridge+Private.h>
#import <ReactCommon/CallInvoker.h>

#import <jsi/jsi.h>

using namespace facebook;

@implementation JsiImage
@synthesize bridge = _bridge;
@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

+ (dispatch_queue_t)queue {
  return dispatch_queue_create("jsi-image-loader-queue", DISPATCH_QUEUE_CONCURRENT);
}

static void install(jsi::Runtime& jsiRuntime)
{
  // jsiImageLoadFromFile(filePath)
  auto jsiImageLoadFromFile = jsi::Function::createFromHostFunction(jsiRuntime,
                                                                    jsi::PropNameID::forAscii(jsiRuntime, "jsiImageLoadFromFile"),
                                                                    1,
                                                                    [](jsi::Runtime& runtime,
                                                                       const jsi::Value& thisValue,
                                                                       const jsi::Value* arguments,
                                                                       size_t count) -> jsi::Value {
    if (count != 1) {
      throw jsi::JSError(runtime, "jsiImageLoadFromFile(..) expects one argument (string)!");
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
  jsiRuntime.global().setProperty(jsiRuntime, "jsiImageLoadFromFile", std::move(jsiImageLoadFromFile));
  
  
  // jsiImageLoadFromUrl(filePath)
  auto jsiImageLoadFromUrl = jsi::Function::createFromHostFunction(jsiRuntime,
                                                                   jsi::PropNameID::forAscii(jsiRuntime, "jsiImageLoadFromUrl"),
                                                                   1,
                                                                   [](jsi::Runtime& runtime,
                                                                      const jsi::Value& thisValue,
                                                                      const jsi::Value* arguments,
                                                                      size_t count) -> jsi::Value {
    if (count != 1) {
      throw jsi::JSError(runtime, "jsiImageLoadFromUrl(..) expects one argument (string)!");
    }
    auto string = arguments[0].asString(runtime).utf8(runtime);
    
    auto promiseCtor = runtime.global().getPropertyAsFunction(runtime, "Promise");
    
    auto runPromise = jsi::Function::createFromHostFunction(runtime,
                                                            jsi::PropNameID::forUtf8(runtime, "jsiLoadImageFromUrl"),
                                                            2,
                                                            [string](jsi::Runtime& runtime,
                                                                     const jsi::Value& thisValue,
                                                                     const jsi::Value* arguments,
                                                                     size_t count) -> jsi::Value {
      auto resolveLocal = arguments[0].asObject(runtime).asFunction(runtime);
      auto resolve = std::make_shared<jsi::Function>(std::move(resolveLocal));
      auto rejectLocal = arguments[1].asObject(runtime).asFunction(runtime);
      auto reject = std::make_shared<jsi::Function>(std::move(rejectLocal));
      
      dispatch_async([JsiImage queue], ^{
        auto url = [NSString stringWithUTF8String:string.c_str()];
        auto image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        if (image == nil) {
          auto message = "Failed to load image from URL \"" + string + "\"!";
          auto error = jsi::JSError(runtime, message);
          reject->call(runtime, error.value());
          return;
        }
        
        auto instance = std::make_shared<ImageHostObject>(image);
        resolve->call(runtime, jsi::Object::createFromHostObject(runtime, instance));
      });
      
      return jsi::Value::undefined();
    });
    
    // return new Promise((resolve, reject) => ...)
    return promiseCtor.callAsConstructor(runtime, runPromise);
  });
  jsiRuntime.global().setProperty(jsiRuntime, "jsiImageLoadFromUrl", std::move(jsiImageLoadFromUrl));
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
  
  install(*(jsi::Runtime *)cxxBridge.runtime, self.bridge.jsCallInvoker);
}

- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;
  _setBridgeOnMainQueue = RCTIsMainQueue();
  [self setup];
}

@end
