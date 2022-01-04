import { Platform } from 'react-native';
import type { Image } from './Image';

const LINKING_ERROR =
  `The package 'react-native-jsi-image' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

// @ts-expect-error JSI unknown
if (typeof global.jsiImageCreateFromFile !== 'function') {
  throw new Error(LINKING_ERROR);
}

/**
 * Loads an Image from the given file path.
 * @param filePath The file path of the image file.
 * @returns An in-memory Image
 */
export function loadImageFromFile(filePath: string): Image {
  // @ts-expect-error JSI unknown
  return global.jsiImageCreateFromFile(filePath);
}

export * from './Image';
