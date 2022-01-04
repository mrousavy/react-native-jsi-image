import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import {
  Image,
  loadImageFromFile,
  loadImageFromUrl,
} from 'react-native-jsi-image';

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
