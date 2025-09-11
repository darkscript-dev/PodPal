import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class GeminiApiService {
  // IMPORTANT: Paste your actual API Key here
  final String _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  Future<Map<String, dynamic>> generatePlantProfile(
    String plantType,
    String plantStage,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    final prompt = """
     You are a creative assistant. For a '$plantType' plant that is currently a '$plantStage', 
      generate a fun name, a short, quirky one-sentence personality, and two interests appropriate for its type and age.
      For example, a seed might be "dreaming of sunshine", while a mature plant might be "enjoying its leafy view".
      Respond ONLY with a minified JSON object with the keys: "name", "personality", "interests".
      """;

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        developer.log(
          "Plant Profile Raw Response: ${response.text}",
          name: "GeminiApiService",
        );


        final cleanedText =
            response.text!
                .replaceAll("```json", "")
                .replaceAll("```", "")
                .trim();

        developer.log(
          "Plant Profile Cleaned JSON: $cleanedText",
          name: "GeminiApiService",
        );

        return json.decode(cleanedText);
      } else {
        throw Exception('Failed to generate plant profile: Empty response.');
      }
    } catch (e) {
      developer.log(
        "Error calling Gemini API for Plant Profile: $e",
        name: "GeminiApiService",
      );
      throw Exception(
        'Failed to parse Plant Profile from Gemini API. Error: $e',
      );
    }
  }

  /// Generates an optimal threshold plan from the AI.
  Future<Map<String, dynamic>> generateAiPlan(
    List<Map<String, dynamic>> historicalData,
    String plantType,
    String plantStage,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    // Convert historical data to a more readable format for the prompt
    final historyString = historicalData
        .map((record) => record.toString())
        .join('\n');

    final prompt = """
      You are an expert autonomous agronomist AI. Your task is to set a complete optimal growth plan (thresholds) 
      for a smart plant pod, tailored specifically for the plant it's growing.

      ## Plant Profile ##
      - Plant Type: $plantType
      - Current Stage: $plantStage

      Your recommendations must be based on the plant's profile. A '$plantType' at the '$plantStage' stage has very 
      specific needs for light, water, humidity, AND nutrients. For example, a seedling needs gentle care, 
      while a mature, fruiting plant needs more light and regular nutrients.

      ## System Capabilities (Thresholds to set) ##
      # The light level (from 0-1023) above which the servo covers should open.
      light_threshold_open: (list of 3 integers) One for each LDR/servo pair [Left, Right, Back].
      fan_on_humidity: (integer)
      fan_on_temperature: (integer)
      watering_threshold: (integer)
      watering_duration_ms: (integer)
      low_humidity_watering_threshold: (integer)
      light_on_hour: (integer, 0-23)
      light_off_hour: (integer, 0-23)
      nutrient_on_hour: (integer, 0-23) The hour of the day to dose nutrients.
      nutrient_duration_ms: (integer) The duration in milliseconds to run the nutrient pump.

      ## Recent Historical Data ##
      $historyString

      ## Task ##
      Based on the provided historical data AND the plant profile, generate the optimal set of thresholds. 
      You must now also manage the new nutrient dosing system. 
      Provide your response as a single, minified JSON object with ONLY the keys listed in the 'System Capabilities' section above.
      """;

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        developer.log(
          "AI Plan Raw Response: ${response.text}",
          name: "GeminiApiService",
        );

        final cleanedText =
            response.text!
                .replaceAll("```json", "")
                .replaceAll("```", "")
                .trim();

        developer.log(
          "AI Plan Cleaned JSON: $cleanedText",
          name: "GeminiApiService",
        );

        return json.decode(cleanedText);
      } else {
        throw Exception('Failed to generate AI plan: Empty response from API.');
      }
    } catch (e) {
      developer.log(
        "Error calling Gemini API for AI Plan: $e",
        name: "GeminiApiService",
      );
      throw Exception('Failed to parse AI Plan from Gemini API. Error: $e');
    }
  }
}
