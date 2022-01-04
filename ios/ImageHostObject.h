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

using namespace facebook;

class JSI_EXPORT ImageHostObject: public jsi::HostObject {
public:
  ImageHostObject(UIImage* image);

public:
  jsi::Value get(jsi::Runtime&, const jsi::PropNameID& name) override;
  std::vector<jsi::PropNameID> getPropertyNames(jsi::Runtime& rt) override;

private:
  UIImage* image;
};
