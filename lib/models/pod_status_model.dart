import 'dart:convert';

// This function remains the same
PodStatusModel podStatusModelFromJson(String str) => PodStatusModel.fromJson(json.decode(str));

class PodStatusModel {
  final double temperature;
  final double humidity;
  final int moisture;
  final String ledStatus;
  final int ldrValue1;
  final int ldrValue2;
  final int ldrValue3;
  final int coverAngle1;
  final int coverAngle2;
  final int coverAngle3;
  final String waterLevel;
  final String nutrientLevel;

  PodStatusModel({
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.ledStatus,
    required this.ldrValue1,
    required this.ldrValue2,
    required this.ldrValue3,
    required this.coverAngle1,
    required this.coverAngle2,
    required this.coverAngle3,
    required this.waterLevel,
    required this.nutrientLevel,
  });

  factory PodStatusModel.fromJson(Map<String, dynamic> json) => PodStatusModel(
    temperature: (json["temperature"] ?? 0).toDouble(),
    humidity: (json["humidity"] ?? 0).toDouble(),
    moisture: json["moisture"] ?? 0,
    ledStatus: json["led_status"] ?? "OFF",
    ldrValue1: json["ldr_value1"] ?? 0,
    ldrValue2: json["ldr_value2"] ?? 0,
    ldrValue3: json["ldr_value3"] ?? 0,
    coverAngle1: json["cover_angle1"] ?? 0,
    coverAngle2: json["cover_angle2"] ?? 0,
    coverAngle3: json["cover_angle3"] ?? 0,
    waterLevel: json["water_level"] ?? "N/A",
    nutrientLevel: json["nutrient_level"] ?? "N/A",
  );
}