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
#import <React/RCTUtils.h>

#import "../cpp/JSI Utils/JsiPromise.h"

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

static void install(jsi::Runtime* jsiRuntime, std::shared_ptr<react::CallInvoker> callInvoker)
{
  auto promiseVendor = std::make_shared<JsiPromise::PromiseVendor>(jsiRuntime, callInvoker);
  auto& runtime = *jsiRuntime;
  
  // jsiImageLoadFromFile(filePath)
  auto jsiImageLoadFromFile = jsi::Function::createFromHostFunction(runtime,
                                                                    jsi::PropNameID::forAscii(runtime, "jsiImageLoadFromFile"),
                                                                    1,
                                                                    [callInvoker, promiseVendor](jsi::Runtime& runtime,
                                                                                                 const jsi::Value& thisValue,
                                                                                                 const jsi::Value* arguments,
                                                                                                 size_t count) -> jsi::Value {
    if (count != 1) {
      throw jsi::JSError(runtime, "jsiImageLoadFromFile(..) expects one argument (string)!");
    }
    auto string = arguments[0].asString(runtime).utf8(runtime);
    
    auto promise = promiseVendor->createPromise([&runtime, promiseVendor, string](std::shared_ptr<JsiPromise::Promise> promise) -> void {
      dispatch_async([JsiImage queue], ^{
        auto path = [NSString stringWithUTF8String:string.c_str()];
        
        auto image = [[UIImage alloc] initWithContentsOfFile:path];
        if (image == nil) {
          auto message = "Failed to load image from path \"" + string + "\"!";
          promise->reject(message);
          return;
        }
        
        auto instance = std::make_shared<ImageHostObject>(image, promiseVendor);
        // success! Image loaded.
        promise->resolve(jsi::Object::createFromHostObject(runtime, instance));
      });
    });
    return promise;
  });
  runtime.global().setProperty(runtime, "jsiImageLoadFromFile", std::move(jsiImageLoadFromFile));
  
  
  // jsiImageLoadFromUrl(filePath)
  auto jsiImageLoadFromUrl = jsi::Function::createFromHostFunction(runtime,
                                                                   jsi::PropNameID::forAscii(runtime, "jsiImageLoadFromUrl"),
                                                                   1,
                                                                   [callInvoker, promiseVendor](jsi::Runtime& runtime,
                                                                                                const jsi::Value& thisValue,
                                                                                                const jsi::Value* arguments,
                                                                                                size_t count) -> jsi::Value {
    if (count != 1) {
      throw jsi::JSError(runtime, "jsiImageLoadFromUrl(..) expects one argument (string)!");
    }
    auto string = arguments[0].asString(runtime).utf8(runtime);
    
    auto promise = promiseVendor->createPromise([&runtime, promiseVendor, string](std::shared_ptr<JsiPromise::Promise> promise) -> void {
      dispatch_async([JsiImage queue], ^{
        auto url = [NSString stringWithUTF8String:string.c_str()];
        auto image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        if (image == nil) {
          auto message = "Failed to load image from URL \"" + string + "\"!";
          promise->reject(message);
          return;
        }
        
        auto instance = std::make_shared<ImageHostObject>(image, promiseVendor);
        // success! Image loaded.
        promise->resolve(jsi::Object::createFromHostObject(runtime, instance));
      });
    });
    return promise;
  });
  runtime.global().setProperty(runtime, "jsiImageLoadFromUrl", std::move(jsiImageLoadFromUrl));
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
  
  install((jsi::Runtime *)cxxBridge.runtime, self.bridge.jsCallInvoker);
}

- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;
  _setBridgeOnMainQueue = RCTIsMainQueue();
  [self setup];
}

@end
