//
//  ImageHostObject.mm
//  JsiImage
//
//  Created by Marc Rousavy on 04.01.22.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageHostObject.h"

ImageHostObject::ImageHostObject(UIImage* image): image(image) {
  // ...
}

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
  auto funcName = "Image." + propName;
  
  if (propName == "toString") {
    auto toString = [this] (jsi::Runtime& runtime, const jsi::Value&, const jsi::Value*, size_t) -> jsi::Value {
      auto width = image.size.width;
      auto height = image.size.height;
      
      NSMutableString* string = [NSMutableString stringWithFormat:@"%f x %f Photo", width, height];
      return jsi::String::createFromUtf8(runtime, string.UTF8String);
    };
    return jsi::Function::createFromHostFunction(runtime, jsi::PropNameID::forUtf8(runtime, "toString"), 0, toString);
  }
  
  if (propName == "width") {
    return jsi::Value((double) image.size.width);
  }
  
  if (propName == "height") {
    return jsi::Value((double) image.size.height);
  }
  
  if (propName == "orientation") {
    NSString* string = imageOrientationToString(image.imageOrientation);
    return jsi::String::createFromUtf8(runtime, string.UTF8String);
  }
  
  if (propName == "isFlipped") {
    return jsi::Value(isFlipped(image.imageOrientation));
  }
  
  if (propName == "flip") {
    auto flip = [this] (jsi::Runtime& runtime, const jsi::Value&, const jsi::Value*, size_t) -> jsi::Value {
      auto flippedImage = [image imageWithHorizontallyFlippedOrientation];
      auto newHostObject = std::make_shared<ImageHostObject>(flippedImage);
      return jsi::Object::createFromHostObject(runtime, newHostObject);
    };
    return jsi::Function::createFromHostFunction(runtime, jsi::PropNameID::forUtf8(runtime, "flip"), 0, flip);
  }
  
  return jsi::Value::undefined();
}
