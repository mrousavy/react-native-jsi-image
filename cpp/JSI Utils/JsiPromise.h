#pragma once

#include <jsi/jsi.h>
#import <ReactCommon/CallInvoker.h>

namespace JsiPromise {

using namespace facebook;

class Promise {
public:
  Promise(std::function<void(jsi::Value)> resolve, std::function<void(std::string&)> reject): _resolve(std::move(resolve)), _reject(std::move(reject)) {}
public:
  bool isResolved;
  void resolve(jsi::Value&& value) {
    _resolve(std::forward<jsi::Value>(value));
  }
  void reject(std::string& errorMessage) {
    _reject(errorMessage);
  }
  
private:
  std::function<void(jsi::Value)> _resolve;
  std::function<void(std::string&)> _reject;
};

jsi::Value createPromise(jsi::Runtime& runtime, std::shared_ptr<react::CallInvoker> callInvoker, std::function<void(std::shared_ptr<Promise>)> func);

}

