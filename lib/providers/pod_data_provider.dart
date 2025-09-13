import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:podpal/api/gemini_api_service.dart';
import 'package:podpal/api/pod_api_service.dart';
import 'package:podpal/api/database_service.dart';
import 'package:podpal/models/pod_status_model.dart';
import 'package:podpal/models/plant_profile_model.dart';

class PodDataProvider with ChangeNotifier {
  // --- SERVICE INSTANCES ---
  // These handle the actual external communications.
  final PodApiService _apiService = PodApiService();
  final GeminiApiService _geminiService = GeminiApiService();
  final DatabaseService _dbService = DatabaseService();

  // --- STATE VARIABLES ---
  // Private variables hold the state. Public getters expose it safely.

  // Pod Status State
  PodStatusModel? _podStatus;
  bool _isLoading = false;
  String? _errorMessage;
  String _lastUsedUrl = '';

  // Plant Profile State
  PlantProfileModel? _plantProfile;
  bool _isGeneratingProfile = false;
  String? _profileError;

  // AI Guardian Plan State
  bool _isUpdatingAiPlan = false;
  String? _aiPlanError;
  Map<String, dynamic>? _lastAiPlan;

  // --- GETTERS (How the UI reads the state) ---
  PodStatusModel? get podStatus => _podStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  PlantProfileModel? get plantProfile => _plantProfile;
  bool get isGeneratingProfile => _isGeneratingProfile;
  String? get profileError => _profileError;

  bool get isUpdatingAiPlan => _isUpdatingAiPlan;
  String? get aiPlanError => _aiPlanError;
  Map<String, dynamic>? get lastAiPlan => _lastAiPlan;


  bool _isGeneratingReport = false;
  String? _aiReport;
  String? _reportError;

  // NEW: AI Report Getters
  bool get isGeneratingReport => _isGeneratingReport;
  String? get aiReport => _aiReport;
  String? get reportError => _reportError;

  // --- METHODS (How the UI triggers actions) ---

  /// Loads saved data from phone storage when the app first starts.
  Future<void> initProvider() async {
    final prefs = await SharedPreferences.getInstance();
    _lastUsedUrl = prefs.getString('ngrok_url') ?? '';

    final isSetupComplete = prefs.getBool('setupComplete') ?? false;
    if (isSetupComplete) {
      final savedProfileString = prefs.getString('plantProfile');
      if (savedProfileString != null) {
        try {
          final profileMap = json.decode(savedProfileString);
          _plantProfile = PlantProfileModel(
            name: profileMap['name'],
            personality: profileMap['personality'],
            interests: profileMap['interests'],
            plantType: profileMap['plantType'] ?? 'Unknown Plant', // Load plant type
            plantStage: profileMap['plantStage'] ?? 'plant',      // Load plant stage
            birthday: DateTime.parse(profileMap['birthday']),
          );
        } catch (e) {
          print("Error loading saved profile: $e");
          // Consider clearing corrupted profile data
          // await prefs.remove('plantProfile');
          // await prefs.setBool('setupComplete', false);
        }
      }
    }
    notifyListeners();
  }

  Future<void> setPanelHeight(int heightPercentage) async {
    try {
      await _apiService.sendPanelHeightToPod(
        baseUrl: _lastUsedUrl,
        heightPercentage: heightPercentage,
      );
    } catch (e) {
      // We can re-throw the exception so the UI can catch it and show a message.
      print("Error in setPanelHeight: $e");
      throw e;
    }
  }
  /// The core logic for the "AI Guardian Angel".
  /// Fetches historical data, asks AI for a plan, and sends it to the pod.
  Future<void> requestAndUpdateAiPlan() async {
    _isUpdatingAiPlan = true;
    _aiPlanError = null;
    notifyListeners();

    try {
      if (_plantProfile == null) {
        throw Exception("Cannot generate AI plan without a plant profile.");
      }

      // 1. Fetch historical data from the local database.
      print("Guardian Angel: Fetching historical data for AI plan...");
      final historicalData = await _dbService.getRecentReadings();
      if (historicalData.isEmpty) {
        throw Exception("Not enough historical data to generate a plan yet.");
      }

      // 2. Generate the new threshold plan from the AI, providing plant context.
      print("Guardian Angel: Asking AI for a new plan for a ${_plantProfile!.plantStage} ${_plantProfile!.plantType}...");
      final newPlan = await _geminiService.generateAiPlan(
        historicalData,
        _plantProfile!.plantType,
        _plantProfile!.plantStage,
      );

      _lastAiPlan = newPlan;

      // 3. Send the new plan to the Pod.
      print("Guardian Angel: Sending new plan to Pod...");
      await _apiService.sendPlanToPod(baseUrl: _lastUsedUrl, plan: newPlan);

      print("Guardian Angel: AI Plan update sequence completed successfully!");
    } catch (e) {
      print("Guardian Angel: Error during AI plan update sequence: $e");
      _aiPlanError = e.toString();
    } finally {
      _isUpdatingAiPlan = false;
      notifyListeners();
    }
  }

  /// Sends a manually configured plan to the pod.
  Future<void> sendManualPlan(Map<String, dynamic> manualPlan) async {
    // This is clean and keeps the API logic in one place.
    await _apiService.sendPlanToPod(baseUrl: _lastUsedUrl, plan: manualPlan);
  }

  Future<void> generateAiReport() async {
    _isGeneratingReport = true;
    _reportError = null;
    _aiReport = null; // Clear old report
    notifyListeners();

    try {
      if (_plantProfile == null) {
        throw Exception("Cannot generate report without a plant profile.");
      }

      final historicalData = await _dbService.getRecentReadings();
      if (historicalData.isEmpty) {
        throw Exception("Not enough historical data to generate a report yet.");
      }

      // Call the Gemini service to get the report
      final report = await _geminiService.getAiReport(
        historicalData,
        _plantProfile!.plantType,
        _plantProfile!.plantStage,
        _plantProfile!.name,
      );

      _aiReport = report;
    } catch (e) {
      _reportError = e.toString();
    } finally {
      _isGeneratingReport = false;
      notifyListeners();
    }
  }

  void resetState() {
    _podStatus = null;
    _isLoading = false;
    _errorMessage = null;
    _lastUsedUrl = '';

    _plantProfile = null;
    _isGeneratingProfile = false;
    _profileError = null;

    _isUpdatingAiPlan = false;
    _aiPlanError = null;
    _lastAiPlan = null;

    notifyListeners();
    print("Provider state has been reset to initial values.");
  }

  /// Fetches the latest sensor status and saves it to the local database using throttling.
  Future<void> updatePodData({String? newUrl, bool useMockData = false}) async {
    // Only show the main spinner on the connect screen, not for background updates.
    if (newUrl != null) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    if (newUrl != null && newUrl.isNotEmpty) {
      _lastUsedUrl = newUrl;
    }

    if (!useMockData && _lastUsedUrl.isEmpty) {
      _errorMessage = "No ngrok URL has been set.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _podStatus = await _apiService.fetchPodStatus(
        baseUrl: _lastUsedUrl,
        useMockData: useMockData,
      );

      if (_podStatus != null) {
        await _dbService.insertSensorReadingThrottled(_podStatus!);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Generates a new plant profile using Gemini, then saves it to phone storage.
  Future<bool> generateAndSetPlantProfile(String plantType, String plantStage, String plantName) async {
    _isGeneratingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      final profileData = await _geminiService.generatePlantProfile(plantType, plantStage);

      dynamic rawInterests = profileData['interests'];
      String finalInterests;
      if (rawInterests is List) {
        finalInterests = rawInterests.join(', ');
      } else {
        finalInterests = rawInterests?.toString() ?? 'Watching the world go by';
      }

      _plantProfile = PlantProfileModel(
        name: plantName,
        personality: profileData['personality'] ?? 'A bit shy',
        interests: finalInterests,
        plantType: plantType,    // Save the plant type
        plantStage: plantStage,  // Save the plant stage
        birthday: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final profileMap = {
        'name': _plantProfile!.name,
        'personality': _plantProfile!.personality,
        'interests': _plantProfile!.interests,
        'plantType': _plantProfile!.plantType,   // Add type to map
        'plantStage': _plantProfile!.plantStage, // Add stage to map
        'birthday': _plantProfile!.birthday.toIso8601String(),
      };
      await prefs.setString('plantProfile', json.encode(profileMap));
      await prefs.setBool('setupComplete', true);

      _isGeneratingProfile = false;
      notifyListeners();
      return true;
    } catch (e) {
      _profileError = e.toString();
      _isGeneratingProfile = false;
      notifyListeners();
      return false;
    }
  }

  /// Retrieves historical sensor data from the local database for the charts screen.
  Future<List<Map<String, dynamic>>> getHistoricalData() async {
    return await _dbService.getRecentReadings();
  }
}