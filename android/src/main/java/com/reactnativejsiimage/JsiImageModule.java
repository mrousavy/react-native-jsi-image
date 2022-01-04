package com.reactnativejsiimage;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

@ReactModule(name = JsiImageModule.NAME)
public class JsiImageModule extends ReactContextBaseJavaModule {
    public static final String NAME = "JsiImage";

    public JsiImageModule(ReactApplicationContext reactContext) {
        super(reactContext);
        // TODO: call nativeInstall()
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    static {
        System.loadLibrary("jsi-image");
    }

    public static native void nativeInstall();
}
