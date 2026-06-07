import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _stt = SpeechToText();

  final RxBool isListening = false.obs;
  final RxBool isAvailable = false.obs;
  final RxString transcribedText = ''.obs;

  Future<void> init() async {
    isAvailable.value = await _stt.initialize(
      onError: (_) => isListening.value = false,
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
    );
  }

  Future<void> startListening({required void Function(String) onResult}) async {
    if (!isAvailable.value) return;
    isListening.value = true;
    await _stt.listen(
      onResult: (result) {
        transcribedText.value = result.recognizedWords;
        onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        localeId: Get.locale?.languageCode == 'ur' ? 'ur_PK' : 'en_US',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    isListening.value = false;
  }

  void dispose() {
    _stt.cancel();
    isListening.value = false;
  }
}
