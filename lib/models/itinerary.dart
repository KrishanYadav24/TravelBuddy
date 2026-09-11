import 'dart:convert';

class ItineraryStop {
  final String destinationId;
  final int order;
  final DateTime? plannedDate;

  const ItineraryStop({
    required this.destinationId,
    required this.order,
    this.plannedDate,
  });

  ItineraryStop copyWith({
    String? destinationId,
    int? order,
    DateTime? plannedDate,
  }) {
    return ItineraryStop(
      destinationId: destinationId ?? this.destinationId,
      order: order ?? this.order,
      plannedDate: plannedDate ?? this.plannedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'order': order,
      'plannedDate': plannedDate?.toIso8601String(),
    };
  }

  factory ItineraryStop.fromMap(Map<String, dynamic> map) {
    return ItineraryStop(
      destinationId: map['destinationId'] ?? '',
      order: map['order'] ?? 0,
      plannedDate: map['plannedDate'] != null ? DateTime.parse(map['plannedDate']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItineraryStop.fromJson(String source) => ItineraryStop.fromMap(json.decode(source));
}

class Itinerary {
  final String id;
  final String name;
  final List<ItineraryStop> stops;
  final DateTime createdAt;

  const Itinerary({
    required this.id,
    required this.name,
    required this.stops,
    required this.createdAt,
  });

  Itinerary copyWith({
    String? id,
    String? name,
    List<ItineraryStop>? stops,
    DateTime? createdAt,
  }) {
    return Itinerary(
      id: id ?? this.id,
      name: name ?? this.name,
      stops: stops ?? this.stops,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stops': stops.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Itinerary.fromMap(Map<String, dynamic> map) {
    return Itinerary(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Untitled Trip',
      stops: (map['stops'] as List<dynamic>?)
              ?.map((s) => ItineraryStop.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Itinerary.fromJson(String source) => Itinerary.fromMap(json.decode(source));
}
