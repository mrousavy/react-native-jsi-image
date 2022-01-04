import { Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-jsi-image' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

// @ts-expect-error JSI unknown
if (!global.__isJsiImageInstalled) {
  throw new Error(LINKING_ERROR);
}

export * from './Image';
