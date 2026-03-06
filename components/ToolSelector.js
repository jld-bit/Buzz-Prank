import React from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

export default function ToolSelector({ tools, selectedToolId, unlockedToolIds, onSelectTool }) {
  return (
    <View style={styles.wrapper}>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.scrollContent}>
        {tools.map((tool) => {
          const selected = selectedToolId === tool.id;
          const unlocked = unlockedToolIds.has(tool.id);

          return (
            <TouchableOpacity
              key={tool.id}
              style={[styles.toolPill, selected && styles.toolPillSelected, !unlocked && styles.toolPillLocked]}
              onPress={() => onSelectTool(tool.id)}
              activeOpacity={0.8}
            >
              <Text style={[styles.toolLabel, selected && styles.toolLabelSelected]}>{tool.label}</Text>
              {!unlocked && <Text style={styles.lockedText}>🔒</Text>}
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    marginTop: 14,
    marginBottom: 24,
  },
  scrollContent: {
    gap: 10,
    paddingHorizontal: 6,
  },
  toolPill: {
    backgroundColor: '#20263A',
    borderRadius: 999,
    paddingHorizontal: 16,
    paddingVertical: 12,
    flexDirection: 'row',
    gap: 8,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#313955',
  },
  toolPillSelected: {
    backgroundColor: '#FFD449',
    borderColor: '#FFD449',
  },
  toolPillLocked: {
    opacity: 0.8,
  },
  toolLabel: {
    color: '#CDD6EF',
    fontWeight: '700',
  },
  toolLabelSelected: {
    color: '#1E1C15',
  },
  lockedText: {
    fontSize: 14,
  },
});
