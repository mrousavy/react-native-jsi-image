//
//  ImageHostObject.mm
//  JsiImage
//
//  Created by Marc Rousavy on 04.01.22.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "ImageHostObject.h"
#import "../cpp/JSI Utils/TypedArray.h"
#import "../cpp/JSI Utils/JsiPromise.h"

std::vector<jsi::PropNameID> ImageHostObject::getPropertyNames(jsi::Runtime& rt) {
  std::vector<jsi::PropNameID> result;
  result.push_back(jsi::PropNameID::forUtf8(rt, std::string("toString")));
  result.push_back(jsi::PropNameID::forUtf8(rt, std::string("width")));
  result.push_back(jsi::PropNameID::forUtf8(rt, std::string("height")));
  return result;
}

NSString* imageOrientationToString(UIImageOrientation orientation) {
  switch (orientation) {
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
      return @"up";
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
      return @"down";
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
      return @"left";
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      return @"right";
  }
}

bool isFlipped(UIImageOrientation orientation) {
  switch (orientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      return true;
    default:
      return false;
  }
}

jsi::Value ImageHostObject::get(jsi::Runtime& runtime, const jsi::PropNameID& propNameId) {
  auto propName = propNameId.utf8(runtime);
  
  // -------- Props --------
  
  if (propName == "width") {
    return jsi::Value((double) _image.size.width);
  }
  
  if (propName == "height") {
    return jsi::Value((double) _image.size.height);
  }
  
  if (propName == "scale") {
    return jsi::Value((double) _image.scale);
  }
  
  if (propName == "orientation") {
    NSString* string = imageOrientationToString(_image.imageOrientation);
    return jsi::String::createFromUtf8(runtime, string.UTF8String);
  }
  
  if (propName == "isFlipped") {
    return jsi::Value(isFlipped(_image.imageOrientation));
  }
  
  if (propName == "data") {
    auto pngData = UIImagePNGRepresentation(_image);
    if (pngData == nil) {
      throw jsi::JSError(runtime, "Underlying Image has no data!");
    }
    size_t length = static_cast<size_t>(pngData.length);
    // Create Uint8Array
    auto bitArray = TypedArray<TypedArrayKind::Uint8Array>(runtime, length);
    // Get writeable ArrayBuffer
    auto buffer = bitArray.getBuffer(runtime);
    // Copy PNG Data to ArrayBuffer's buffer
    memcpy(buffer.data(runtime), pngData.bytes, length);
    return bitArray;
  }
  
  // -------- Functions --------
  
  if (propName == "flip") {
    auto flip = [this] (jsi::Runtime& runtime,
                        const jsi::Value&,
                        const jsi::Value*,
                        size_t) -> jsi::Value {
      auto flippedImage = [_image imageWithHorizontallyFlippedOrientation];
      auto newHostObject = std::make_shared<ImageHostObject>(flippedImage, _promiseVendor);
      return jsi::Object::createFromHostObject(runtime, newHostObject);
    };
    return jsi::Function::createFromHostFunction(runtime,
                                                 jsi::PropNameID::forUtf8(runtime, "flip"),
                                                 0,
                                                 flip);
  }
  
  if (propName == "save") {
    auto flip = [this] (jsi::Runtime& runtime,
                        const jsi::Value&,
                        const jsi::Value* arguments,
                        size_t count) -> jsi::Value {
      if (count != 1) {
        throw jsi::JSError(runtime, "Image.save(..) expects one argument (string)!");
      }
      auto string = arguments[0].asString(runtime).utf8(runtime);
      
      _promiseVendor->createPromise([this, string](std::shared_ptr<JsiPromise::Promise> promise) -> void {
        NSString* path = [NSString stringWithUTF8String:string.c_str()];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          if ([path.lowercaseString hasSuffix:@".png"]) {
            // Write .png file
            [UIImagePNGRepresentation(_image) writeToFile:path atomically:YES];
            promise->resolve(jsi::Value::undefined());
          } else if ([path.lowercaseString hasSuffix:@".jpg"]) {
            // Write .jpg file
            [UIImageJPEGRepresentation(_image, 1.0) writeToFile:path atomically:YES];
            promise->resolve(jsi::Value::undefined());
          } else {
            // Unknown file type!
            promise->reject("Unknown file extension! File path must end with either \".png\" or \".jpg\"!");
          }
        });
      });
      auto flippedImage = [_image imageWithHorizontallyFlippedOrientation];
      auto newHostObject = std::make_shared<ImageHostObject>(flippedImage, _promiseVendor);
      return jsi::Object::createFromHostObject(runtime, newHostObject);
    };
    return jsi::Function::createFromHostFunction(runtime,
                                                 jsi::PropNameID::forUtf8(runtime, "flip"),
                                                 0,
                                                 flip);
  }
  
  if (propName == "toString") {
    auto toString = [this] (jsi::Runtime& runtime,
                            const jsi::Value&,
                            const jsi::Value*,
                            size_t) -> jsi::Value {
      auto width = _image.size.width;
      auto height = _image.size.height;
      
      NSMutableString* string = [NSMutableString stringWithFormat:@"%f x %f Photo", width, height];
      return jsi::String::createFromUtf8(runtime, string.UTF8String);
    };
    return jsi::Function::createFromHostFunction(runtime,
                                                 jsi::PropNameID::forUtf8(runtime, "toString"),
                                                 0,
                                                 toString);
  }
  
  return jsi::Value::undefined();
}
