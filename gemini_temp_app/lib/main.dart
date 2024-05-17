import 'dart:convert';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
class GeminiTempMain extends ConsumerWidget {
  const GeminiTempMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          const GeminiTempBg(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CommunityMaterialIcons.leaf_maple,
                    size: 100, color: Colors.white.withOpacity(0.75)),
                const GeminiTempDisplay(),
                const SizedBox(height: 24),
                const GeminiTempInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GeminiTempBg extends StatelessWidget {
  const GeminiTempBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.purple,
        Colors.deepPurple,
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    );
  }
}

class GeminiTempDisplay extends StatelessWidget {
  const GeminiTempDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CommunityMaterialIcons.thermometer_lines,
            size: 100, color: Colors.white.withOpacity(0.75)),
        const SizedBox(width: 16),
        Consumer(builder: (context, ref, child) {
          final dataRetrieved = ref.watch(geminiRetrievalLocalVMProvider);
          final tempValue = ref.watch(tempDisplayValueProvider);

          if (dataRetrieved) {
            return Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(
                minHeight: 150,
                minWidth: 150,
              ),
              child: const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            );
          }

          return Text(tempValue.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 100,
                fontWeight: FontWeight.bold,
              ));
        }),
        const SizedBox(width: 20),
        Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              return Text(ref.watch(tempInverseConversionProvider).label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30));
            },
          ),
        )
      ],
    );
  }
}

class GeminiTempInput extends ConsumerWidget {
  const GeminiTempInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: 350,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                width: 20,
                color: Colors.white.withOpacity(0.25),
                strokeAlign: BorderSide.strokeAlignOutside)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // temp selector
            const GeminiTempSelector(),

            Expanded(
              child: TextFormField(
                controller: ref.read(tempFieldController),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 80,
                    color: Colors.black),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: '- -',
                  hintStyle: TextStyle(color: Colors.grey),
                  hintMaxLines: null,
                ),
                maxLength: 3,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  ref.read(tempInputValueProvider.notifier).state = value;
                },
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: ref.watch(tempInputValueProvider).isNotEmpty
                    ? () {
                        ref
                            .read(geminiRetrievalLocalVMProvider.notifier)
                            .convertTemp();
                      }
                    : null,
                child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                        color: ref.watch(tempInputValueProvider).isNotEmpty
                            ? Colors.purple
                            : Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 30)),
              ),
            ),
          ],
        ));
  }
}

class GeminiTempSelector extends ConsumerWidget {
  const GeminiTempSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversion = ref.watch(tempConversionOptionProvider);

    // color configuration
    final selectedColor = Colors.purple.withOpacity(0.5);
    final unselectedColor = Colors.purple.withOpacity(0.125);

    const selectedLabel = Colors.white;
    final unselectedLabel = Colors.purple.withOpacity(0.5);

    return Column(
      children: List.generate(GeminiTempOptions.values.length, (index) {
        var tempOption = GeminiTempOptions.values[index];

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              ref
                  .read(geminiRetrievalLocalVMProvider.notifier)
                  .onSelectConversion(tempOption);
            },
            child: Container(
              margin: EdgeInsets.only(
                  bottom: index < GeminiTempOptions.values.length - 1 ? 20 : 0),
              decoration: BoxDecoration(
                  color: conversion == tempOption
                      ? selectedColor
                      : unselectedColor,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Text(tempOption.label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: conversion == tempOption
                          ? selectedLabel
                          : unselectedLabel,
                      fontSize: 30)),
            ),
          ),
        );
      }),
    );
  }
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
          apiKey: 'AIzaSyDvJGeUKMR_slPotd_SJNhM884nLXEUxXs');

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
