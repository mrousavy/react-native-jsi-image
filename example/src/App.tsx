import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import {
  Image,
  loadImageFromFile,
  loadImageFromUrl,
} from 'react-native-jsi-image';

const TEST_PATH = '/tmp/test.png';

export default function App() {
  React.useEffect(() => {
    const interval = setInterval(async () => {
      console.log('loading image from file...');
      const image = await loadImageFromUrl(
        'https://cpmr-islands.org/wp-content/uploads/sites/4/2019/07/test.png'
      );
      console.log('loaded image from file!');

      console.log(`image: ${image}`);
      console.log(
        `orientation: ${image.orientation} (${
          image.isFlipped ? 'flipped' : 'normal'
        })`
      );
      const flipped = image.flip();
      console.log(
        `flipped: ${flipped.orientation} (${
          flipped.isFlipped ? 'flipped' : 'normal'
        })`
      );

      console.log(`saving to "${TEST_PATH}"...`);
      await image.save(TEST_PATH);
      console.log(`saved to "${TEST_PATH}"!`);

      console.log(`loading from "${TEST_PATH}"...`);
      const fromDisk = await loadImageFromFile(TEST_PATH);
      console.log(`loaded ${fromDisk.toString()} image from "${TEST_PATH}"!`);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <View style={styles.container}>
      <Text>Hello!</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'white',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
