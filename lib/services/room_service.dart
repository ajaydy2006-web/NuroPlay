import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';

enum RoomStatus {
  waiting,     // Waiting for opponent to join
  joined,      // Opponent joined! Starting match
  inProgress,  // Duel match is currently running
  closed,      // Closed by host manually
  expired,     // 60-second timeout expired with no opponent joining
}

class DuelRoom {
  final String roomId;
  final String hostName;
  final String hostAvatar;
  final Difficulty difficulty;
  final int questionCount;
  final int seed;
  final int createdAt; // epoch ms
  final int timeoutSeconds;
  String? guestName;
  String? guestAvatar;
  RoomStatus status;

  DuelRoom({
    required this.roomId,
    required this.hostName,
    required this.hostAvatar,
    required this.difficulty,
    required this.questionCount,
    required this.seed,
    required this.createdAt,
    this.timeoutSeconds = 60,
    this.guestName,
    this.guestAvatar,
    this.status = RoomStatus.waiting,
  });

  bool get isExpired {
    final elapsed = (DateTime.now().millisecondsSinceEpoch - createdAt) ~/ 1000;
    return elapsed >= timeoutSeconds;
  }

  int get secondsRemaining {
    final elapsed = (DateTime.now().millisecondsSinceEpoch - createdAt) ~/ 1000;
    final rem = timeoutSeconds - elapsed;
    return rem > 0 ? rem : 0;
  }

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'hostName': hostName,
    'hostAvatar': hostAvatar,
    'difficulty': difficulty.index,
    'questionCount': questionCount,
    'seed': seed,
    'createdAt': createdAt,
    'timeoutSeconds': timeoutSeconds,
    'guestName': guestName,
    'guestAvatar': guestAvatar,
    'status': status.index,
  };

  factory DuelRoom.fromJson(Map<String, dynamic> json) => DuelRoom(
    roomId: json['roomId'] as String,
    hostName: json['hostName'] as String,
    hostAvatar: (json['hostAvatar'] ?? '🧠') as String,
    difficulty: Difficulty.values[(json['difficulty'] as int?) ?? 1],
    questionCount: (json['questionCount'] as int?) ?? 10,
    seed: (json['seed'] as int?) ?? 12345,
    createdAt: (json['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    timeoutSeconds: (json['timeoutSeconds'] as int?) ?? 60,
    guestName: json['guestName'] as String?,
    guestAvatar: json['guestAvatar'] as String?,
    status: RoomStatus.values[(json['status'] as int?) ?? 0],
  );
}

class JoinRoomResult {
  final bool success;
  final String? errorMessage;
  final DuelRoom? room;

  JoinRoomResult({
    required this.success,
    this.errorMessage,
    this.room,
  });
}

/// Service managing real-time peer room connections via Room ID
class RoomService {
  static const String _prefPrefix = 'nuroplay_duel_room_';
  static final Map<String, DuelRoom> _memoryRooms = {};

  /// Create a new private duel room
  static Future<DuelRoom> createRoom({
    required String hostName,
    required String hostAvatar,
    Difficulty difficulty = Difficulty.medium,
    int questionCount = 10,
    int timeoutSeconds = 60,
  }) async {
    final rng = Random();
    final pin = (1000 + rng.nextInt(9000)).toString();
    final roomId = 'NURO-$pin';
    final seed = rng.nextInt(10000000);

    final room = DuelRoom(
      roomId: roomId,
      hostName: hostName,
      hostAvatar: hostAvatar,
      difficulty: difficulty,
      questionCount: questionCount,
      seed: seed,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      timeoutSeconds: timeoutSeconds,
      status: RoomStatus.waiting,
    );

    _memoryRooms[roomId] = room;
    await _saveRoom(room);

    return room;
  }

  /// Normalize room code input e.g. "4829" -> "NURO-4829", "mind-4829" -> "MIND-4829"
  static String normalizeRoomId(String input) {
    var code = input.trim().toUpperCase();
    if (code.isEmpty) return '';
    if (!code.contains('-') && int.tryParse(code) != null) {
      code = 'NURO-$code';
    }
    return code;
  }

  /// Get room state
  static Future<DuelRoom?> getRoom(String rawRoomId) async {
    final roomId = normalizeRoomId(rawRoomId);
    if (roomId.isEmpty) return null;

    DuelRoom? room = _memoryRooms[roomId];

    if (room == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final raw = prefs.getString('$_prefPrefix$roomId');
      if (raw != null) {
        try {
          room = DuelRoom.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          _memoryRooms[roomId] = room;
        } catch (_) {}
      }
    }

    if (room != null) {
      // Check for automatic expiration if waiting
      if (room.status == RoomStatus.waiting && room.isExpired) {
        room.status = RoomStatus.expired;
        await _saveRoom(room);
      }
    }

    return room;
  }

  /// Join an active room with Room ID
  static Future<JoinRoomResult> joinRoom({
    required String rawRoomId,
    required String guestName,
    required String guestAvatar,
  }) async {
    final roomId = normalizeRoomId(rawRoomId);
    if (roomId.isEmpty) {
      return JoinRoomResult(
        success: false,
        errorMessage: 'Please enter a valid 4-digit Room ID.',
      );
    }

    final room = await getRoom(roomId);
    if (room == null) {
      return JoinRoomResult(
        success: false,
        errorMessage: 'Room "$roomId" not found. Please verify the Room ID with your friend.',
      );
    }

    if (room.status == RoomStatus.closed) {
      return JoinRoomResult(
        success: false,
        errorMessage: 'Room "$roomId" was closed by the host.',
      );
    }

    if (room.status == RoomStatus.expired || room.isExpired) {
      room.status = RoomStatus.expired;
      await _saveRoom(room);
      return JoinRoomResult(
        success: false,
        errorMessage: 'Room "$roomId" has timed out because no opponent joined within 60 seconds.',
      );
    }

    if (room.status == RoomStatus.joined || room.status == RoomStatus.inProgress) {
      // Allow reconnect if same guest name
      if (room.guestName != guestName) {
        return JoinRoomResult(
          success: false,
          errorMessage: 'Room "$roomId" is already full with another opponent.',
        );
      }
    }

    // Connect guest to room
    room.guestName = guestName;
    room.guestAvatar = guestAvatar;
    room.status = RoomStatus.joined;

    _memoryRooms[roomId] = room;
    await _saveRoom(room);

    return JoinRoomResult(success: true, room: room);
  }

  /// Close / Cancel room
  static Future<void> closeRoom(String rawRoomId, {bool isTimeout = false}) async {
    final roomId = normalizeRoomId(rawRoomId);
    final room = await getRoom(roomId);
    if (room != null) {
      room.status = isTimeout ? RoomStatus.expired : RoomStatus.closed;
      _memoryRooms[roomId] = room;
      await _saveRoom(room);
    }
  }

  /// Simulate an opponent joining (handy for 1-device testing)
  static Future<DuelRoom?> simulateRivalJoin(String rawRoomId, {String rivalName = 'Player 2 (Rival)'}) async {
    final roomId = normalizeRoomId(rawRoomId);
    final room = await getRoom(roomId);
    if (room != null && room.status == RoomStatus.waiting) {
      room.guestName = rivalName;
      room.guestAvatar = '⚡';
      room.status = RoomStatus.joined;
      _memoryRooms[roomId] = room;
      await _saveRoom(room);
      return room;
    }
    return null;
  }

  static Future<void> _saveRoom(DuelRoom room) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefPrefix${room.roomId}', jsonEncode(room.toJson()));
    await prefs.reload();
  }
}

