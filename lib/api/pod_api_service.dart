import 'dart:convert'; // Required for jsonEncode
import 'package:podpal/models/pod_status_model.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class PodApiService {
  Future<PodStatusModel> fetchPodStatus({
    required String baseUrl,
    required bool useMockData,
  }) async {
    if (useMockData) {
      return _fetchMockPodStatus();
    } else {
      return _fetchRealPodStatus(baseUrl);
    }
  }


  Future<void> sendPanelHeightToPod({ required String baseUrl, required int heightPercentage,}) async {
    // Ensure the base URL is not empty
    if (baseUrl.isEmpty) {
      throw Exception('Cannot send panel height: No Pod URL has been set.');
    }

    final fullUrl = '$baseUrl/panel/height';
    final payload = {'panel_height': heightPercentage};
    final jsonPayload = jsonEncode(payload);

    developer.log(
      'Attempting to POST to $fullUrl with body: $jsonPayload',
      name: 'PodApiService',
    );

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonPayload,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to set panel height. Status code: ${response.statusCode}, Body: ${response.body}');
      }
      developer.log(
        'Successfully set panel height. Response: ${response.body}',
        name: 'PodApiService',
      );
    } catch (e) {
      print(e);
      throw Exception(
          'Failed to connect to set panel height. Please check the Pod URL and connection.');
    }
  }

  Future<void> sendPlanToPod({
    required String baseUrl,
    required Map<String, dynamic> plan,
  }) async {
    // Ensure the base URL is not empty
    if (baseUrl.isEmpty) {
      throw Exception('Cannot send plan: No Pod URL has been set.');
    }

    final fullUrl = '$baseUrl/plan/update';

    final String jsonPayload = jsonEncode(plan);

    // This guarantees it will print to the terminal even if the request fails.
    developer.log(
      'Attempting to POST to $fullUrl with body: $jsonPayload',
      name: 'PodApiService',
    );

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        // Use the pre-encoded string here.
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        developer.log(
          'Successfully sent plan to Pod. Response: ${response.body}',
          name: 'PodApiService',
        );
      } else {
        throw Exception(
            'Failed to send plan. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print(e);
      throw Exception(
          'Failed to connect to send plan. Please check the Pod URL and connection.');
    }
  }

  Future<String> fetchPlantImage(String laptopUrl) async {
    if (laptopUrl.isEmpty) {
      throw Exception('Cannot get image: No Laptop Webcam Server URL has been set.');
    }

    final fullUrl = '$laptopUrl/get_image';
    developer.log(
      'Attempting to GET image from $fullUrl',
      name: 'PodApiService',
    );

    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('image_base64')) {
          developer.log('Successfully fetched and decoded image.', name: 'PodApiService');
          return data['image_base64'];
        } else {
          throw Exception('Image data not found in response.');
        }
      } else {
        throw Exception('Failed to get image. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching plant image: $e', name: 'PodApiService');
      throw Exception('Failed to connect to the webcam server. Please check the URL and connection.');
    }
  }

  Future<PodStatusModel> _fetchMockPodStatus() async {
    print("--- 🤫 USING MOCK DATA VIA UI SWITCH 🤫 ---");
    await Future.delayed(const Duration(seconds: 1));

    return PodStatusModel(
      temperature: 24.5,
      humidity: 68.0,
      moisture: 850,
      ledStatus: "ON",
      // --- MOCK DATA ADDED HERE ---
      ldrValue1: 450, // A sample light value
      ldrValue2: 465, // A sample light value
      ldrValue3: 455, // A sample light value
      coverAngle1: 90,  // Left panel is "Inner"
      coverAngle2: 90,  // Right panel is "Normal"
      coverAngle3: 90,  // Back panel is "Outer"
      waterLevel: "OK",
      nutrientLevel: "LOW",
    );
  }

  // The real data function is now corrected.
  Future<PodStatusModel> _fetchRealPodStatus(String baseUrl) async {
    final fullUrl = '$baseUrl/status';
    try {
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        print("RAW JSON FROM DEVICE: ${response.body}");
        return podStatusModelFromJson(response.body);
      } else {
        throw Exception('Failed to load pod status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to connect to the PodPal device. Please check the URL and your connection.');
    }
  }
}