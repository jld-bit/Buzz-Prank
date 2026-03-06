import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  Vibration,
  Alert,
} from 'react-native';
import { Audio } from 'expo-av';
import { Accelerometer } from 'expo-sensors';
import { CameraView, useCameraPermissions } from 'expo-camera';
import mobileAds, {
  BannerAd,
  BannerAdSize,
  RewardedAd,
  RewardedAdEventType,
  TestIds,
} from 'react-native-google-mobile-ads';
import ToolSelector from './components/ToolSelector';
import PrankButton from './components/PrankButton';

const TOOLS = [
  {
    id: 'clipper',
    label: 'Clipper Buzz',
    soundPath: 'assets/sounds/buzz.wav',
    premium: false,
  },
  {
    id: 'laser',
    label: 'Laser Buzz',
    soundPath: 'assets/sounds/buzz.wav',
    premium: false,
  },
  {
    id: 'robot',
    label: 'Robot Buzz',
    soundPath: 'assets/sounds/buzz.wav',
    premium: true,
  },
  {
    id: 'cartoon',
    label: 'Cartoon Buzz',
    soundPath: 'assets/sounds/buzz.wav',
    premium: true,
  },
];

const rewarded = RewardedAd.createForAdRequest(TestIds.REWARDED, {
  requestNonPersonalizedAdsOnly: true,
});

export default function App() {
  const [selectedToolId, setSelectedToolId] = useState(TOOLS[0].id);
  const [unlockedToolIds, setUnlockedToolIds] = useState(new Set(TOOLS.filter((t) => !t.premium).map((t) => t.id)));
  const [removeAdsPurchased, setRemoveAdsPurchased] = useState(false);
  const [cameraPermission, requestCameraPermission] = useCameraPermissions();
  const [torchOn, setTorchOn] = useState(false);
  const [rewardedReady, setRewardedReady] = useState(false);
  const lastShakeAt = useRef(0);

  const selectedToolIndex = useMemo(
    () => TOOLS.findIndex((tool) => tool.id === selectedToolId),
    [selectedToolId]
  );

  useEffect(() => {
    mobileAds().initialize();
    Audio.setAudioModeAsync({
      playsInSilentModeIOS: true,
      shouldDuckAndroid: true,
      allowsRecordingIOS: false,
    });
  }, []);

  useEffect(() => {
    const unsubLoaded = rewarded.addAdEventListener(RewardedAdEventType.LOADED, () => {
      setRewardedReady(true);
    });

    const unsubEarned = rewarded.addAdEventListener(RewardedAdEventType.EARNED_REWARD, () => {
      const locked = TOOLS.find((tool) => !unlockedToolIds.has(tool.id));
      if (!locked) return;

      setUnlockedToolIds((prev) => {
        const next = new Set(prev);
        next.add(locked.id);
        return next;
      });
      Alert.alert('Unlocked!', `${locked.label} is now available.`);
    });

    rewarded.load();

    return () => {
      unsubLoaded();
      unsubEarned();
    };
  }, [unlockedToolIds]);

  useEffect(() => {
    Accelerometer.setUpdateInterval(250);
    const sub = Accelerometer.addListener(({ x, y, z }) => {
      const totalForce = Math.sqrt(x * x + y * y + z * z);
      const now = Date.now();
      if (totalForce > 1.8 && now - lastShakeAt.current > 900) {
        lastShakeAt.current = now;
        const nextIdx = (selectedToolIndex + 1) % TOOLS.length;
        setSelectedToolId(TOOLS[nextIdx].id);
      }
    });

    return () => sub.remove();
  }, [selectedToolIndex]);

  const playBuzz = useCallback(async () => {
    const selectedTool = TOOLS.find((tool) => tool.id === selectedToolId);

    if (!selectedTool || !unlockedToolIds.has(selectedTool.id)) {
      Alert.alert('Tool locked', 'Watch a rewarded ad to unlock more buzz tools.');
      return;
    }

    const { sound } = await Audio.Sound.createAsync({ uri: selectedTool.soundPath }, { shouldPlay: true });
    sound.setOnPlaybackStatusUpdate((status) => {
      if (status.didJustFinish) {
        sound.unloadAsync();
      }
    });

    Vibration.vibrate([0, 120, 80, 120]);

    if (!cameraPermission?.granted) {
      const permission = await requestCameraPermission();
      if (!permission.granted) {
        return;
      }
    }

    for (let i = 0; i < 6; i += 1) {
      setTorchOn((prev) => !prev);
      await new Promise((resolve) => setTimeout(resolve, 90));
    }
    setTorchOn(false);
  }, [cameraPermission?.granted, requestCameraPermission, selectedToolId, unlockedToolIds]);

  const watchRewardedAd = useCallback(() => {
    if (!rewardedReady) {
      Alert.alert('Ad loading', 'Rewarded ad is still loading. Please try again in a moment.');
      return;
    }

    rewarded.show();
    setRewardedReady(false);
    rewarded.load();
  }, [rewardedReady]);

  const handleSelectTool = useCallback(
    (toolId) => {
      const isUnlocked = unlockedToolIds.has(toolId);
      if (isUnlocked) {
        setSelectedToolId(toolId);
      } else {
        Alert.alert('Locked Tool', 'Watch a rewarded ad to unlock this buzz effect.');
      }
    },
    [unlockedToolIds]
  );

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      <View style={styles.header}>
        <Text style={styles.title}>Buzz Prank</Text>
        <Text style={styles.subtitle}>Shake phone to switch tools</Text>
      </View>

      <ToolSelector
        tools={TOOLS}
        selectedToolId={selectedToolId}
        unlockedToolIds={unlockedToolIds}
        onSelectTool={handleSelectTool}
      />

      <PrankButton onPress={playBuzz} label="BUZZ" />

      <View style={styles.actionRow}>
        <Text style={styles.actionButton} onPress={watchRewardedAd}>
          Unlock Tool (Rewarded Ad)
        </Text>
        <Text style={styles.actionButton} onPress={() => setRemoveAdsPurchased(true)}>
          Remove Ads (Purchase)
        </Text>
      </View>

      {!removeAdsPurchased && (
        <View style={styles.bannerWrap}>
          <BannerAd
            unitId={TestIds.BANNER}
            size={BannerAdSize.ANCHORED_ADAPTIVE_BANNER}
            requestOptions={{ requestNonPersonalizedAdsOnly: true }}
          />
        </View>
      )}

      {cameraPermission?.granted && (
        <View style={styles.hiddenCamera}>
          <CameraView style={styles.cameraView} facing="back" enableTorch={torchOn} />
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0D0F1A',
    paddingHorizontal: 16,
    justifyContent: 'space-between',
  },
  header: {
    alignItems: 'center',
    marginTop: 20,
  },
  title: {
    color: '#F8FBFF',
    fontSize: 34,
    fontWeight: '900',
    letterSpacing: 0.8,
  },
  subtitle: {
    color: '#88A0C6',
    marginTop: 8,
    fontSize: 15,
  },
  actionRow: {
    gap: 12,
    marginBottom: 10,
  },
  actionButton: {
    textAlign: 'center',
    color: '#1A1A1A',
    backgroundColor: '#FFD449',
    fontWeight: '800',
    paddingVertical: 12,
    borderRadius: 14,
    overflow: 'hidden',
  },
  bannerWrap: {
    alignItems: 'center',
    marginBottom: 14,
  },
  hiddenCamera: {
    position: 'absolute',
    width: 1,
    height: 1,
    opacity: 0,
    top: 0,
    left: 0,
  },
  cameraView: {
    width: '100%',
    height: '100%',
  },
});
