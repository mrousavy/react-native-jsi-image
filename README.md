# 🖼️ react-native-jsi-image

**A writeable in-memory Image JSI Host Object.**

JSI-Image is a modern library that provides Image primitives for the native iOS and Android Platforms, neatly packaged together in one single fast JavaScript API.

There are 3 ways to create a JSI-Image instance:

* Load from a file
* Load from a Web-URL
* Returned by another library, such as [VisionCamera](https://github.com/mrousavy/react-native-vision-camera)'s `takePhoto(...)` function.

## Why

Traditionally, Images in React Native could not be handled efficiently. To demonstrate this, let's take a look at how a Camera library might take a photo:

1. [js] User taps capture button, `takePhoto(...)` is called.
2. [native] Camera takes a photo. The library now has `UIImage` instance (photo) in-memory.
3. [native] Library creates a new file on disk. (**slow!** 🐌)
4. [native] Library writes the `UIImage` instance to the file. (**slow!** 🐌)
5. [native] Library returns the path to the file to the caller (JS)
6. [js] App now navigates to the "captured media" screen to display the media.
7. [js] App passes the file path to a `<FastImage>` component.
8. [native] `<FastImage>` component has to load the image from file. (**slow!** 🐌)
9. [native] `<FastImage>` component then displays the `UIImage` from the file.

With JSI-Image, all the unnecessary slow file operations can be skipped, since the Image can be passed around in-memory.

1. [js] User taps capture button, `takePhoto(...)` is called.
2. [native] Camera takes a photo. The library now has `UIImage` instance (photo) in-memory.
5. [native] Library returns the `UIImage` instance to the caller (JS) (**fast!** 🔥)
6. [js] App now navigates to the "captured media" screen to display the media.
7. [js] App passes the in-memory `Image` instance to a `<FastImage>` component.
8. [native] `<FastImage>` component then displays the already in-memory `UIImage` instance. (**fast!** 🔥)

## Benchmarks

### Without JSI-Image

```
[log] Successfully took photo in 312ms!
```

### With JSI-Image

```
[log] Successfully took photo in 95ms!
```

JSI-Image improved capture speed (`takePhoto(...)`) by more than **3x**!

These improvements are even greater at more complicated image processing, such as rotating an image, applying image filters, resizing images, etc.

## Installation

```sh
yarn add react-native-jsi-image
cd ios && pod install
```

## Usage

### Load from URL

```ts
import { loadImageFromUrl } from "react-native-jsi-image"

const image = await loadImageFromUrl('https://...')
console.log(`Successfully loaded ${image.width} x ${image.height} image!`)
```

### Load from File

```ts
import { loadImageFromFile } from "react-native-jsi-image"

const image = await loadImageFromFile('file:///Users/Marc/image.png')
console.log(`Successfully loaded ${image.width} x ${image.height} image!`)
```

### Inspect Image

```ts
const image = ...
const size = image.width * image.height
const realSize = size * image.scale
const orientation = image.orientation

for (const pixel of image.data) {
  console.log(`Pixel: ${pixel}`)
}
```

### Rotate/Flip Image

```ts
const image = ...
console.log(image.isFlipped) // false
const flipped = image.flip()
console.log(flipped.isFlipped) // true

if (image.orientation === "up") {
  // rotates image in-memory
  image.orientation = "right"
}
```

### Save modified Image to File

```ts
let image = ...
image = rotateImageCorrectly(image)
await image.save('file:///tmp/temp-image.png') // or .jpg
```

### For Library Developers

To use JSI-Image in your native library, your functions must be JSI functions.

#### Accept `Image` Parameter

In your JSI Module:

```cpp
#include <JsiImage/ImageHostObject.h>

// ...

jsi::Value myFunction(jsi::Runtime& runtime,
                      jsi::Value& thisArg,
                      jsi::Value* arguments,
                      size_t count) {
  auto imageHostObject = arguments[0].asObject(runtime).asHostObject<ImageHostObject>(runtime);
  auto uiImage = imageHostObject->image;
  // use uiImage here
}
```

In your TypeScript declaration:

```ts
import { Image } from 'react-native-jsi-image'

export function myFunction(image: Image): void
```

#### Return `Image` from your native module

In your JSI Module:

```cpp
#include <JsiImage/ImageHostObject.h>

// ...

jsi::Value myFunction(jsi::Runtime& runtime,
                      jsi::Value& thisArg,
                      jsi::Value* arguments,
                      size_t count) {
  UIImage* image = // ...

  auto instance = std::make_shared<ImageHostObject>(image, promiseVendor);
  return jsi::Object::createFromHostObject(runtime, instance);
}
```

In your TypeScript declaration:

```ts
import { Image } from 'react-native-jsi-image'

export function myFunction(): Image
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
