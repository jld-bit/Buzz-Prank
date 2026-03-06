import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

export default function PrankButton({ onPress, label }) {
  return (
    <View style={styles.wrap}>
      <Pressable onPress={onPress} style={({ pressed }) => [styles.button, pressed && styles.buttonPressed]}>
        <Text style={styles.label}>{label}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  button: {
    width: 230,
    height: 230,
    borderRadius: 115,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FF5D67',
    borderWidth: 10,
    borderColor: '#B92236',
    shadowColor: '#FF5D67',
    shadowOpacity: 0.6,
    shadowRadius: 16,
    elevation: 10,
  },
  buttonPressed: {
    transform: [{ scale: 0.96 }],
  },
  label: {
    color: '#FFFFFF',
    fontSize: 44,
    fontWeight: '900',
    letterSpacing: 3,
  },
});
