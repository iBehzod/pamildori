import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  
  // Initialize audio player resources
  Future<void> init() async {
    // Preload sounds for faster playback
    await _preloadSounds();
  }
  
  Future<void> _preloadSounds() async {
    try {
      await AudioCache.instance.loadAll([
        AppConstants.soundBell,
        AppConstants.soundBreak,
        AppConstants.soundComplete,
        AppConstants.soundStart,
      ]);
      debugPrint('Sound assets preloaded');
    } catch (e) {
      debugPrint('Error preloading sounds: $e');
    }
  }

  // Play a sound from assets
  Future<void> playSound(String soundAsset) async {
    if (_isMuted) return;
    
    try {
      await _audioPlayer.stop();
      final source = AssetSource(soundAsset);
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }
  
  // Play pomodoro start sound
  Future<void> playStartSound() async {
    await playSound(AppConstants.soundStart);
  }
  
  // Play break sound
  Future<void> playBreakSound() async {
    await playSound(AppConstants.soundBreak);
  }
  
  // Play complete sound
  Future<void> playCompleteSound() async {
    await playSound(AppConstants.soundComplete);
  }
  
  // Play alarm/bell sound
  Future<void> playBellSound() async {
    await playSound(AppConstants.soundBell);
  }
  
  // Toggle sound mute
  void toggleMute() {
    _isMuted = !_isMuted;
  }
  
  // Mute sounds
  void mute() {
    _isMuted = true;
  }
  
  // Unmute sounds
  void unmute() {
    _isMuted = false;
  }
  
  // Get current mute status
  bool get isMuted => _isMuted;
  
  // Dispose resources when service is no longer needed
  void dispose() {
    _audioPlayer.dispose();
  }
} 