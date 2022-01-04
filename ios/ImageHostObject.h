//
//  ImageHostObject.h
//  JsiImage
//
//  Created by Marc Rousavy on 04.01.22.
//  Copyright © 2021 Facebook. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <jsi/jsi.h>
#import "../cpp/JSI Utils/JsiPromise.h"

using namespace facebook;

class JSI_EXPORT ImageHostObject: public jsi::HostObject {
public:
  ImageHostObject(UIImage* image, std::shared_ptr<JsiPromise::PromiseVendor> promiseVendor): image(image), _promiseVendor(promiseVendor) { };

public:
  jsi::Value get(jsi::Runtime&, const jsi::PropNameID& name) override;
  std::vector<jsi::PropNameID> getPropertyNames(jsi::Runtime& rt) override;

public:
  UIImage* image;
  
private:
  std::shared_ptr<JsiPromise::PromiseVendor> _promiseVendor;
};
