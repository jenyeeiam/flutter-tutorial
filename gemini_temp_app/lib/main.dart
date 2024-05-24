import 'dart:convert';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

String getApiKey() {
  return const String.fromEnvironment('GEMINI_API_KEY');
}

void main() {
  runApp(const ProviderScope(child: GeminiTempApp()));
}

// main app
class GeminiTempApp extends StatelessWidget {
  const GeminiTempApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GeminiTempMain(),
    );
  }
}

// widget classes
import 'components/gemini_temp_main.dart';

import 'components/gemini_temp_bg.dart';

import 'components/gemini_temp_display.dart';

import 'components/gemini_temp_input.dart';

import 'components/gemini_temp_selector.dart';

}

// providers

final tempFieldController = Provider((ref) {
  return TextEditingController();
});

final tempDisplayValueProvider = StateProvider<double>((ref) {
  return 0;
});

final tempInputValueProvider = StateProvider<String>((ref) {
  return '';
});

final tempRetrievalFlagProvider = StateProvider<bool>((ref) {
  return false;
});

final tempConversionOptionProvider = StateProvider<GeminiTempOptions>(
    (ref) => GeminiTempOptions.celsius2fahrenheit);

final tempInverseConversionProvider = Provider((ref) {
  final selectedConversion = ref.watch(tempConversionOptionProvider);
  return selectedConversion == GeminiTempOptions.celsius2fahrenheit
      ? GeminiTempOptions.fahrenheit2celsius
      : GeminiTempOptions.celsius2fahrenheit;
});

final geminiRetrievalLocalVMProvider =
    StateNotifierProvider<GeminiTempLocalRetrievalViewModel, bool>((ref) {
  return GeminiTempLocalRetrievalViewModel(ref, false);
});

// viewmodel
class GeminiTempLocalRetrievalViewModel extends StateNotifier<bool> {
  final Ref ref;
  GeminiTempLocalRetrievalViewModel(this.ref, super._state);

  Future<void> convertTemp() async {
    state = true;

    var tempValue = ref.read(tempInputValueProvider);
    var selectedConversion = ref.read(tempConversionOptionProvider);

    var fromToConversion = selectedConversion.name.split('2');
    var fromValue = fromToConversion[0];
    var toValue = fromToConversion[1];

    final req = GeminiTempRequest(
      conversion: selectedConversion,
      temp: double.parse(tempValue),
    );

    var prompt = '''generate a JSON payload that returns the conversion
    of weather from farenheit to celsius and viceversa; 
    return a JSON payload containing the following properties -
    conversion: which is the value of the conversion, 
    in this case it should read "${req.conversion.name}" depending on the conversion;
    inputValue, which is the value of ${req.temp} to convert from $fromValue; 
    outputValue, which is the result from the conversion to $toValue.
    Do not return code, just the resulting JSON payload.
    Do not return the word JSON in the payload''';

    try {
      final content = [Content.text(prompt)];
      final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: getApiKey());

      final response = await model.generateContent(content);
      var jsonResponse = json.decode(response.text!);
      var geminiResponse = GeminiTempResponse.fromJSON(jsonResponse);
      ref.read(tempDisplayValueProvider.notifier).state =
          geminiResponse.outputValue;
    } on Exception {
      ref.read(tempDisplayValueProvider.notifier).state = 0;
    }

    state = false;
  }

  void resetValues() {
    ref.read(tempFieldController).clear();
    ref.read(tempInputValueProvider.notifier).state = '';
    ref.read(tempDisplayValueProvider.notifier).state = 0;
  }

  void onSelectConversion(GeminiTempOptions tempOption) {
    resetValues();
    ref.read(tempConversionOptionProvider.notifier).state = tempOption;
  }
}

// enums and model classes
enum GeminiTempOptions {
  fahrenheit2celsius('°F'),
  celsius2fahrenheit('°C');

  final String label;
  const GeminiTempOptions(this.label);
}

class GeminiTempRequest {
  final GeminiTempOptions conversion;
  final double temp;

  GeminiTempRequest({required this.conversion, required this.temp});

  String toJson() {
    return json.encoder.convert({
      'conversion': conversion.name,
      'temp': temp,
    });
  }
}

class GeminiTempResponse {
  final GeminiTempOptions conversion;
  final double inputValue;
  final double outputValue;

  const GeminiTempResponse({
    required this.inputValue,
    required this.outputValue,
    required this.conversion,
  });

  factory GeminiTempResponse.fromJSON(Map<String, dynamic> json) {
    return GeminiTempResponse(
      inputValue: json['inputValue'],
      outputValue: json['outputValue'],
      conversion: GeminiTempOptions.values
          .firstWhere((c) => c.name == json['conversion']),
    );
  }

  static GeminiTempResponse empty() {
    return const GeminiTempResponse(
        conversion: GeminiTempOptions.celsius2fahrenheit,
        inputValue: 0,
        outputValue: 0);
  }
}