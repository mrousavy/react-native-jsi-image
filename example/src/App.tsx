import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { Image, loadImageFromFile } from 'react-native-jsi-image';

export default function App() {
  React.useEffect(() => {
    const interval = setInterval(() => {
      console.log('loading image from file...');
      const image = loadImageFromFile('');
      console.log('loaded image from file!');
      console.log(`image: ${image}`);
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
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
