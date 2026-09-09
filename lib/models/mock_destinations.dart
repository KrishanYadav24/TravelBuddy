import 'destination.dart';

/// Static collection of 15 realistic Indian travel destinations.
/// Spread across 9 states and covering all 8 activity types.
class MockDestinations {
  static const List<Destination> destinations = [
    Destination(
      id: 'dest_valley_of_flowers',
      name: 'Valley of Flowers',
      activityTypes: ['trek', 'hike'],
      state: 'Uttarakhand',
      region: 'Garhwal Himalayas',
      lat: 30.7280,
      lng: 79.6053,
      difficulty: DifficultyLevel.moderate,
      durationDays: 6,
      altitudeMeters: 3600,
      terrainType: 'Alpine Meadow',
      description:
          'UNESCO World Heritage alpine valley famed for endemic flora, rare Himalayan wildlife, and lush colorful meadows.',
      photoUrls: [
        'https://picsum.photos/id/1018/600/600',
        'https://picsum.photos/id/1015/600/600',
      ],
      bestMonths: [6, 7, 8, 9], // June - Sept
      avgRating: 4.9,
      reviewCount: 428,
    ),
    Destination(
      id: 'dest_kedarkantha',
      name: 'Kedarkantha Peak',
      activityTypes: ['trek', 'camping'],
      state: 'Uttarakhand',
      region: 'Govind Wildlife Sanctuary',
      lat: 31.0225,
      lng: 78.1729,
      difficulty: DifficultyLevel.moderate,
      durationDays: 5,
      altitudeMeters: 3800,
      terrainType: 'Snow & Pine Forest',
      description:
          'One of India\'s most popular winter summit treks with 360-degree views of Himalayan peaks.',
      photoUrls: [
        'https://picsum.photos/id/1036/600/600',
        'https://picsum.photos/id/1016/600/600',
      ],
      bestMonths: [12, 1, 2, 3, 4], // Dec - Apr
      avgRating: 4.8,
      reviewCount: 612,
    ),
    Destination(
      id: 'dest_chopta',
      name: 'Chopta & Tungnath',
      activityTypes: ['hike', 'pilgrimage'],
      state: 'Uttarakhand',
      region: 'Garhwal Region',
      lat: 30.4878,
      lng: 79.1843,
      difficulty: DifficultyLevel.easy,
      durationDays: 3,
      altitudeMeters: 3680,
      terrainType: 'Mountain Meadow',
      description:
          'Known as the "Mini Switzerland of India", featuring the world\'s highest Shiva temple at Tungnath.',
      photoUrls: [
        'https://picsum.photos/id/1043/600/600',
      ],
      bestMonths: [4, 5, 6, 9, 10, 11], // Apr-Jun, Sep-Nov
      avgRating: 4.7,
      reviewCount: 389,
    ),
    Destination(
      id: 'dest_hampi',
      name: 'Hampi Ruins',
      activityTypes: ['heritage', 'road_trip'],
      state: 'Karnataka',
      region: 'Vijayanagara District',
      lat: 15.3350,
      lng: 76.4600,
      difficulty: DifficultyLevel.easy,
      durationDays: 3,
      altitudeMeters: 467,
      terrainType: 'Boulder Landscape',
      description:
          'Ancient UNESCO city filled with surreal boulder hills, intricate stone temples, and royal monuments.',
      photoUrls: [
        'https://picsum.photos/id/1040/600/600',
      ],
      bestMonths: [10, 11, 12, 1, 2, 3], // Oct - Mar
      avgRating: 4.9,
      reviewCount: 890,
    ),
    Destination(
      id: 'dest_jog_falls',
      name: 'Jog Falls',
      activityTypes: ['hike', 'heritage'],
      state: 'Karnataka',
      region: 'Shivamogga District',
      lat: 14.2285,
      lng: 74.8118,
      difficulty: DifficultyLevel.easy,
      durationDays: 2,
      altitudeMeters: 485,
      terrainType: 'Dense Forest',
      description:
          'India\'s second-highest plunge waterfall created by the Sharavathi River amidst Western Ghats greenery.',
      photoUrls: [
        'https://picsum.photos/id/1048/600/600',
      ],
      bestMonths: [7, 8, 9, 10], // Jul - Oct
      avgRating: 4.6,
      reviewCount: 310,
    ),
    Destination(
      id: 'dest_spiti',
      name: 'Spiti Valley Circuit',
      activityTypes: ['road_trip', 'camping', 'trek'],
      state: 'Himachal Pradesh',
      region: 'Lahaul & Spiti',
      lat: 32.2461,
      lng: 78.0349,
      difficulty: DifficultyLevel.difficult,
      durationDays: 8,
      altitudeMeters: 3800,
      terrainType: 'High Desert',
      description:
          'Cold desert valley filled with ancient monasteries, high passes, and stark moonscape terrain.',
      photoUrls: [
        'https://picsum.photos/id/1079/600/600',
      ],
      bestMonths: [5, 6, 7, 8, 9], // May - Sept
      avgRating: 4.9,
      reviewCount: 745,
    ),
    Destination(
      id: 'dest_triund',
      name: 'Triund Trail',
      activityTypes: ['hike', 'camping'],
      state: 'Himachal Pradesh',
      region: 'Dharamshala / McLeod Ganj',
      lat: 32.2490,
      lng: 76.3530,
      difficulty: DifficultyLevel.easy,
      durationDays: 2,
      altitudeMeters: 2850,
      terrainType: 'Forest Ridge',
      description:
          'Accessible mountain ridge walk offering dramatic views of the snow-capped Dhauladhar range.',
      photoUrls: [
        'https://picsum.photos/id/1015/600/600',
      ],
      bestMonths: [3, 4, 5, 6, 9, 10, 11, 12], // Mar-Jun, Sep-Dec
      avgRating: 4.6,
      reviewCount: 520,
    ),
    Destination(
      id: 'dest_corbett',
      name: 'Jim Corbett National Park',
      activityTypes: ['safari', 'camping'],
      state: 'Uttarakhand',
      region: 'Nainital District',
      lat: 29.5300,
      lng: 78.7747,
      difficulty: DifficultyLevel.easy,
      durationDays: 3,
      altitudeMeters: 400,
      terrainType: 'Sal Forest & Riverbed',
      description:
          'India\'s oldest national park, home to the Royal Bengal Tiger, wild Asian elephants, and rich birdlife.',
      photoUrls: [
        'https://picsum.photos/id/1024/600/600',
      ],
      bestMonths: [11, 12, 1, 2, 3, 4, 5, 6], // Nov - Jun
      avgRating: 4.7,
      reviewCount: 680,
    ),
    Destination(
      id: 'dest_palolem',
      name: 'Palolem Beach',
      activityTypes: ['beach', 'road_trip'],
      state: 'Goa',
      region: 'South Goa',
      lat: 15.0100,
      lng: 74.0230,
      difficulty: DifficultyLevel.easy,
      durationDays: 4,
      altitudeMeters: 0,
      terrainType: 'Coastal Beach',
      description:
          'Picturesque crescent-shaped beach enclosed by thick coconut palms and calm turquoise waters.',
      photoUrls: [
        'https://picsum.photos/id/1057/600/600',
      ],
      bestMonths: [11, 12, 1, 2, 3], // Nov - Mar
      avgRating: 4.8,
      reviewCount: 950,
    ),
    Destination(
      id: 'dest_ranthambore',
      name: 'Ranthambore National Park',
      activityTypes: ['safari', 'heritage'],
      state: 'Rajasthan',
      region: 'Sawai Madhopur',
      lat: 26.0173,
      lng: 76.5026,
      difficulty: DifficultyLevel.easy,
      durationDays: 3,
      altitudeMeters: 250,
      terrainType: 'Dry Deciduous Forest',
      description:
          'Famous wildlife reserve combining historic 10th-century fort ruins with active tiger tracking safaris.',
      photoUrls: [
        'https://picsum.photos/id/1024/600/600',
      ],
      bestMonths: [10, 11, 12, 1, 2, 3, 4, 5], // Oct - May
      avgRating: 4.8,
      reviewCount: 810,
    ),
    Destination(
      id: 'dest_jaisalmer',
      name: 'Jaisalmer Sand Dunes',
      activityTypes: ['camping', 'heritage', 'road_trip'],
      state: 'Rajasthan',
      region: 'Thar Desert',
      lat: 26.9157,
      lng: 70.9083,
      difficulty: DifficultyLevel.easy,
      durationDays: 3,
      altitudeMeters: 225,
      terrainType: 'Desert Sand Dunes',
      description:
          'Golden City of Rajasthan featuring desert glamping, camel safaris, and majestic sandstone fortresses.',
      photoUrls: [
        'https://picsum.photos/id/1003/600/600',
      ],
      bestMonths: [10, 11, 12, 1, 2, 3], // Oct - Mar
      avgRating: 4.7,
      reviewCount: 640,
    ),
    Destination(
      id: 'dest_cherrapunji',
      name: 'Cherrapunji Living Root Bridges',
      activityTypes: ['hike', 'trek'],
      state: 'Meghalaya',
      region: 'East Khasi Hills',
      lat: 25.2986,
      lng: 91.7317,
      difficulty: DifficultyLevel.moderate,
      durationDays: 4,
      altitudeMeters: 1480,
      terrainType: 'Rainforest Steps',
      description:
          'Bio-engineered living root bridges handcrafted by the Khasi tribe amidst dramatic tropical waterfalls.',
      photoUrls: [
        'https://picsum.photos/id/1043/600/600',
      ],
      bestMonths: [9, 10, 11, 12, 1, 2, 3, 4, 5], // Sep - May
      avgRating: 4.9,
      reviewCount: 390,
    ),
    Destination(
      id: 'dest_varkala',
      name: 'Varkala Cliff & Beach',
      activityTypes: ['beach', 'pilgrimage'],
      state: 'Kerala',
      region: 'Thiruvananthapuram',
      lat: 8.7379,
      lng: 76.7163,
      difficulty: DifficultyLevel.easy,
      durationDays: 4,
      altitudeMeters: 30,
      terrainType: 'Coastal Cliff',
      description:
          'Stunning red laterite cliffs bordering the Arabian Sea, famous for natural springs and Janardanaswamy temple.',
      photoUrls: [
        'https://picsum.photos/id/1057/600/600',
      ],
      bestMonths: [10, 11, 12, 1, 2, 3], // Oct - Mar
      avgRating: 4.8,
      reviewCount: 710,
    ),
    Destination(
      id: 'dest_hemis',
      name: 'Hemis Monastery & High Passes',
      activityTypes: ['pilgrimage', 'road_trip', 'trek'],
      state: 'Ladakh',
      region: 'Leh District',
      lat: 33.9125,
      lng: 77.7067,
      difficulty: DifficultyLevel.expert,
      durationDays: 7,
      altitudeMeters: 3560,
      terrainType: 'High Altitude Plateau',
      description:
          'Largest Buddhist monastery in Ladakh nestled inside Hemis National Park, gateway to snow leopard treks.',
      photoUrls: [
        'https://picsum.photos/id/1040/600/600',
      ],
      bestMonths: [5, 6, 7, 8, 9], // May - Sept
      avgRating: 4.9,
      reviewCount: 460,
    ),
    Destination(
      id: 'dest_sundarbans',
      name: 'Sundarbans Tiger Reserve',
      activityTypes: ['safari', 'beach'],
      state: 'West Bengal',
      region: 'Ganges Delta',
      lat: 21.9497,
      lng: 88.8924,
      difficulty: DifficultyLevel.moderate,
      durationDays: 3,
      altitudeMeters: 5,
      terrainType: 'Mangrove Waterways',
      description:
          'World\'s largest mangrove forest ecosystem, home to swimming Bengal tigers and saltwater crocodiles.',
      photoUrls: [
        'https://picsum.photos/id/1024/600/600',
      ],
      bestMonths: [9, 10, 11, 12, 1, 2, 3], // Sep - Mar
      avgRating: 4.6,
      reviewCount: 320,
    ),
  ];
}
