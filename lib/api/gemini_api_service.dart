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

  Future<String> getAiReport(
    List<Map<String, dynamic>> historicalData,
    String plantType,
    String plantStage,
    String plantName,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
    final historyString = historicalData
        .map((record) => record.toString())
        .join('\n');

    final prompt = """
      You are an advanced AI agronomist and data analyst for the PodPal Smart Planter system. Your task is to generate a professional, in-depth daily health report.

      ## CONTEXT ##
      - Plant Type: $plantType
      - Current Growth Stage: $plantStage
      - Report Generation Date: ${DateTime.now().toIso8601String()}

      ## INPUT DATA SCHEMA ##
      - 'timestamp': The time of the reading.
      - 'temperature': Ambient temperature in Celsius.
      - 'humidity': Ambient humidity percentage.
      - 'moisture': Soil moisture reading from the sensor (lower is drier, higher is wetter).
      - 'water_level': The current level of the main water reservoir ('OK', 'LOW'). This is about the TANK, not the plant's hydration.
      - 'nutrient_level': The current level of the nutrient solution reservoir ('OK', 'LOW'). This is about the TANK, not the plant's nutrition.

      ## TASK ##
      Analyze the last 12 hours of hardware sensor data provided below. Based on the plant's profile and the data schema, generate a detailed health report. Use a professional and analytical tone. Provide quantitative insights where possible (e.g., "temperature fluctuated by 5°C").

      The report MUST include the following sections using Markdown headings:
      
      ### Executive Summary
      A one-paragraph overview of the plant's overall condition and the performance of the automated system.
      
      ### Environmental Analysis
      - **Temperature & Humidity:** Comment on the stability and whether the levels were within the optimal range for this plant.
      - **Soil Moisture:** Analyze the moisture trend. Does it show clear cycles of watering and drying? Was the plant ever at risk of being too dry or too wet?
      
      ### Resource Levels
      - **Water Reservoir:** State the current water tank level. If it is 'LOW', emphasize that it needs to be refilled soon.
      - **Nutrient Reservoir:** State the current nutrient tank level. If it is 'LOW', emphasize that it needs to be refilled soon.

      ### Overall Plant Health Assessment
      Provide your expert conclusion on the plant's current health based on the data. Is it thriving, stable, or showing signs of stress?

      ### Proactive Recommendations
      Provide 1-2 actionable recommendations. This could be to refill a reservoir, a suggestion for the next AI growth plan, or a confirmation that the current plan is working perfectly.

      ## INPUT DATA (Last 12 Hours) ##
      $historyString

      ## OUTPUT FORMATTING ##
      Respond ONLY with the formatted report text using the specified Markdown headings. Do not include any other explanatory text.
      """;

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        return response.text!;
      } else {
        throw Exception('Failed to generate report: Empty response from API.');
      }
    } catch (e) {
      developer.log(
        "Error calling Gemini API for Report: $e",
        name: "GeminiApiService",
      );
      throw Exception('Failed to parse Report from Gemini API. Error: $e');
    }
  }

  /// Generates an optimal threshold plan from the AI.
  Future<Map<String, dynamic>> generateAiPlan(
    List<Map<String, dynamic>> historicalData,
    String plantType,
    String plantStage,
    String plantImageBase64,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    // Convert historical data to a more readable format for the prompt
    final historyString = historicalData
        .map((record) => record.toString())
        .join('\n');

    final imageBytes = base64Decode(plantImageBase64);


    final prompt = """
    You are an expert autonomous agronomist AI. Your task is to set a complete optimal growth plan (thresholds) for a smart plant pod.

    ## Visual Analysis ##
    First, analyze the provided image of the plant. Assess its overall health, size, coloration, and look for any signs of nutrient deficiency, overwatering, underwatering, or pest issues. The visual context is critical.

    ## Plant Profile ##
    Plant Type: $plantType
    Current Stage: $plantStage

    ## System Capabilities (Thresholds to set) ##
    light_threshold_open: (list of 3 integers)
    fan_on_humidity: (integer)
    fan_on_temperature: (integer)
    watering_threshold: (integer)
    watering_duration_ms: (integer)
    low_humidity_watering_threshold: (integer)
    light_on_hour: (integer, 0-23)
    light_off_hour: (integer, 0-23)
    nutrient_on_hour: (integer, 0-23)
    nutrient_duration_ms: (integer)

    ## Recent Historical Sensor Data ##
    $historyString

    ## Task ##
    Based on your VISUAL ANALYSIS of the image, the plant profile, and the historical sensor data, generate the optimal set of thresholds. For example, if you see yellowing leaves in the image, you might adjust the nutrient schedule. If the plant looks droopy, you might adjust the watering threshold.
    Respond as a single, minified JSON object with ONLY the keys listed in the 'System Capabilities' section.
    """;

    try {
      // CHANGE 2: Construct a multimodal request with both the text and the image.
      // WHY: The API needs to receive both parts in a single 'multi' content block.
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes), // Assumes the image is a JPEG
        ])
      ];

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
