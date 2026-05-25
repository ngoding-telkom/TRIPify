import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';
import '../models/ticket_model.dart';

abstract class BookingRepository {
  Stream<List<TicketModel>> watchAvailableTickets();
  Stream<List<TicketModel>> watchAllTickets();
  Stream<List<BookingModel>> watchUserBookings({required String userId});
  Stream<Set<String>> watchUnavailableSeats({required String ticketId});

  Stream<List<BookingModel>> watchBookings({
    required String userId,
    required String ticketId,
  });

  Future<void> bookSeats({
    required String userId,
    required String ticketId,
    required List<String> seatNumbers,
  });

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  });

  Future<void> deleteBooking({required String bookingId});

  Future<String> createTicket({
    required String originStation,
    required String destinationStation,
    required DateTime date,
    required String train,
    required String status,
    String? seatClass,
    String? departTime,
    String? arriveTime,
    String? duration,
    int? oldPrice,
    int? price,
    int? seatsLeft,
  });

  Future<void> updateTicket({
    required String ticketId,
    required String originStation,
    required String destinationStation,
    required DateTime date,
    required String train,
    required String status,
    String? seatClass,
    String? departTime,
    String? arriveTime,
    String? duration,
    int? oldPrice,
    int? price,
    int? seatsLeft,
  });

  Future<void> deleteTicket({required String ticketId});

  Future<BookingModel> getBooking({required String bookingId});

  Future<int> getBookingSequence({required String bookingId});

  Future<void> verifyAllPending({
    required String userId,
    required String ticketId,
  });

  Future<int> updateBookingStatusByCode({
    required String code,
    required String status,
  });
}

class FirestoreBookingRepository implements BookingRepository {
  FirestoreBookingRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tickets =>
      _firestore.collection('tickets');

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');

  @override
  Stream<List<TicketModel>> watchAvailableTickets() {
    return _tickets.where('status', isEqualTo: 'available').snapshots().map((
      snapshot,
    ) {
      final tickets = snapshot.docs
          .map(TicketModel.fromFirestore)
          .toList(growable: false);
      final sortedTickets = [...tickets]
        ..sort((left, right) => left.date.compareTo(right.date));
      return sortedTickets;
    });
  }

  @override
  Stream<List<BookingModel>> watchUserBookings({required String userId}) {
    return _bookings.where('userId', isEqualTo: userId).snapshots().asyncMap((
      snapshot,
    ) async {
      final bookings = snapshot.docs
          .map(BookingModel.fromFirestore)
          .toList(growable: false);
      return _resolveExpiredBookingStatuses(bookings);
    });
  }

  @override
  Stream<List<BookingModel>> watchBookings({
    required String userId,
    required String ticketId,
  }) {
    return _bookings
        .where('userId', isEqualTo: userId)
        .where('ticketId', isEqualTo: ticketId)
        .snapshots()
        .asyncMap((snapshot) async {
          final bookings = snapshot.docs
              .map(BookingModel.fromFirestore)
              .toList(growable: false);
          return _resolveExpiredBookingStatuses(bookings);
        });
  }

  @override
  Stream<List<TicketModel>> watchAllTickets() {
    return _tickets.snapshots().map((snapshot) {
      final tickets = snapshot.docs
          .map(TicketModel.fromFirestore)
          .toList(growable: false);
      final sortedTickets = [...tickets]
        ..sort((left, right) => left.date.compareTo(right.date));
      return sortedTickets;
    });
  }

  @override
  Stream<Set<String>> watchUnavailableSeats({required String ticketId}) {
    return _bookings.where('ticketId', isEqualTo: ticketId).snapshots().map((
      snapshot,
    ) {
      final blocked = snapshot.docs
          .map(BookingModel.fromFirestore)
          .where((booking) => booking.status != 'cancelled')
          .map((booking) => booking.seatNumber)
          .toSet();
      return blocked;
    });
  }

  @override
  Future<void> bookSeats({
    required String userId,
    required String ticketId,
    required List<String> seatNumbers,
  }) async {
    final bookingGroupId = _bookings.doc().id;

    await _firestore.runTransaction((transaction) async {
      final seats = seatNumbers.toSet().toList(growable: false);
      final refs = seats
          .map((seatNumber) => _bookings.doc('${ticketId}_$seatNumber'))
          .toList(growable: false);

      final existingDocs = await Future.wait(refs.map(transaction.get));

      for (final document in existingDocs) {
        if (document.exists) {
          final seat = (document.data()?['seatNumber'] as String?) ?? '';
          throw StateError('Seat already booked: $seat');
        }
      }

      for (final seatNumber in seats) {
        final id = '${ticketId}_$seatNumber';
        final booking = BookingModel(
          id: id,
          userId: userId,
          ticketId: ticketId,
          seatNumber: seatNumber,
          status: 'pending',
          bookingGroupId: bookingGroupId,
          createdAt: DateTime.now(),
        );
        transaction.set(_bookings.doc(id), booking.toMap());
      }
    });
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _bookings.doc(bookingId).update({'status': status});
  }

  @override
  Future<void> deleteBooking({required String bookingId}) async {
    await _bookings.doc(bookingId).delete();
  }

  @override
  Future<String> createTicket({
    required String originStation,
    required String destinationStation,
    required DateTime date,
    required String train,
    required String status,
    String? seatClass,
    String? departTime,
    String? arriveTime,
    String? duration,
    int? oldPrice,
    int? price,
    int? seatsLeft,
  }) async {
    final reference = _tickets.doc();
    final ticket = TicketModel(
      id: reference.id,
      originStation: originStation,
      destinationStation: destinationStation,
      date: date,
      train: train,
      status: status,
      seatClass: seatClass,
      departTime: departTime,
      arriveTime: arriveTime,
      duration: duration,
      oldPrice: oldPrice,
      price: price,
      seatsLeft: seatsLeft,
    );
    await reference.set(ticket.toMap());
    return reference.id;
  }

  @override
  Future<void> updateTicket({
    required String ticketId,
    required String originStation,
    required String destinationStation,
    required DateTime date,
    required String train,
    required String status,
    String? seatClass,
    String? departTime,
    String? arriveTime,
    String? duration,
    int? oldPrice,
    int? price,
    int? seatsLeft,
  }) async {
    final ticket = TicketModel(
      id: ticketId,
      originStation: originStation,
      destinationStation: destinationStation,
      date: date,
      train: train,
      status: status,
      seatClass: seatClass,
      departTime: departTime,
      arriveTime: arriveTime,
      duration: duration,
      oldPrice: oldPrice,
      price: price,
      seatsLeft: seatsLeft,
    );
    await _tickets.doc(ticketId).update(ticket.toMap());
  }

  @override
  Future<void> deleteTicket({required String ticketId}) async {
    await _tickets.doc(ticketId).delete();
  }

  @override
  Future<int> getBookingSequence({required String bookingId}) async {
    final snapshot = await _bookings
        .orderBy('createdAt')
        .orderBy(FieldPath.documentId)
        .get();
    final index = snapshot.docs.indexWhere(
      (document) => document.id == bookingId,
    );
    if (index < 0) {
      throw StateError('Booking tidak ditemukan.');
    }
    return index + 1;
  }

  @override
  Future<BookingModel> getBooking({required String bookingId}) async {
    final snapshot = await _bookings.doc(bookingId).get();
    if (!snapshot.exists) {
      throw StateError('Booking tidak ditemukan.');
    }
    return BookingModel.fromFirestore(snapshot);
  }

  @override
  Future<void> verifyAllPending({
    required String userId,
    required String ticketId,
  }) async {
    final querySnapshot = await _bookings
        .where('userId', isEqualTo: userId)
        .where('ticketId', isEqualTo: ticketId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }

    await _firestore.runTransaction((transaction) async {
      for (final booking in querySnapshot.docs) {
        transaction.update(booking.reference, {'status': 'completed'});
      }
    });
  }

  @override
  Future<int> updateBookingStatusByCode({
    required String code,
    required String status,
  }) async {
    final sequence = _parseBookingSequence(code);
    if (sequence == null) {
      throw StateError('Kode tiket tidak valid.');
    }

    final bookingDoc = await _getBookingDocBySequence(sequence);
    final booking = BookingModel.fromFirestore(bookingDoc);

    List<DocumentSnapshot<Map<String, dynamic>>> docs = [];
    final groupId = booking.bookingGroupId;
    if (groupId != null && groupId.isNotEmpty) {
      final groupSnapshot = await _bookings
          .where('bookingGroupId', isEqualTo: groupId)
          .get();
      docs = [...groupSnapshot.docs];
    } else {
      docs = [bookingDoc];
    }

    final batch = _firestore.batch();
    var updatedCount = 0;
    for (final booking in docs) {
      final data = booking.data();
      final currentStatus = (data?['status'] as String?) ?? '';
      if (!_shouldUpdateStatus(currentStatus, status)) {
        continue;
      }
      batch.update(booking.reference, {'status': status});
      updatedCount += 1;
    }

    if (updatedCount == 0) {
      throw StateError('Tidak ada booking yang bisa diupdate.');
    }

    await batch.commit();
    return updatedCount;
  }

  bool _shouldUpdateStatus(String current, String next) {
    final normalizedCurrent = current.toLowerCase();
    final normalizedNext = next.toLowerCase();
    if (normalizedNext == 'confirmed') {
      return normalizedCurrent == 'pending';
    }
    if (normalizedNext == 'cancelled') {
      return normalizedCurrent == 'pending' || normalizedCurrent == 'confirmed';
    }
    return normalizedCurrent != normalizedNext;
  }

  int? _parseBookingSequence(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final prefix = RegExp(r'^trp-', caseSensitive: false);
    final stripped = prefix.hasMatch(trimmed)
        ? trimmed.substring(4).trim()
        : trimmed;
    final sequence = int.tryParse(stripped);
    if (sequence == null || sequence < 1) {
      return null;
    }
    return sequence;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getBookingDocBySequence(
    int sequence,
  ) async {
    final snapshot = await _bookings
        .orderBy('createdAt')
        .orderBy(FieldPath.documentId)
        .get();
    if (sequence < 1 || sequence > snapshot.docs.length) {
      throw StateError('Kode tiket tidak ditemukan.');
    }
    return snapshot.docs[sequence - 1];
  }

  Future<List<BookingModel>> _resolveExpiredBookingStatuses(
    List<BookingModel> bookings,
  ) async {
    if (bookings.isEmpty) {
      return const <BookingModel>[];
    }

    final tracked = bookings
        .where((booking) {
          final normalizedStatus = booking.status.toLowerCase();
          return normalizedStatus == 'pending' ||
              normalizedStatus == 'confirmed';
        })
        .toList(growable: false);
    if (tracked.isEmpty) {
      return _sortBookingsByCreatedAtDesc(bookings);
    }

    final ticketIds = tracked
        .map((booking) => booking.ticketId)
        .where((ticketId) => ticketId.isNotEmpty)
        .toSet();
    final ticketSnapshots = await Future.wait(
      ticketIds.map((ticketId) => _tickets.doc(ticketId).get()),
    );
    final ticketMap = {
      for (final ticketSnapshot in ticketSnapshots)
        ticketSnapshot.id: TicketModel.fromFirestore(ticketSnapshot),
    };

    final now = DateTime.now();
    final statusUpdates = <String, String>{};

    for (final booking in tracked) {
      final ticket = ticketMap[booking.ticketId];
      if (ticket == null || !_isTicketDateEnded(ticket.date, now)) {
        continue;
      }

      final normalizedStatus = booking.status.toLowerCase();
      final String? nextStatus = switch (normalizedStatus) {
        'pending' => 'cancelled',
        'confirmed' => 'completed',
        _ => null,
      };
      if (nextStatus != null) {
        statusUpdates[booking.id] = nextStatus;
      }
    }

    if (statusUpdates.isNotEmpty) {
      final batch = _firestore.batch();
      for (final entry in statusUpdates.entries) {
        batch.update(_bookings.doc(entry.key), {'status': entry.value});
      }
      await batch.commit();
    }

    final resolved = bookings
        .map((booking) {
          final resolvedStatus = statusUpdates[booking.id];
          if (resolvedStatus == null) {
            return booking;
          }
          return BookingModel(
            id: booking.id,
            userId: booking.userId,
            ticketId: booking.ticketId,
            seatNumber: booking.seatNumber,
            status: resolvedStatus,
            bookingGroupId: booking.bookingGroupId,
            createdAt: booking.createdAt,
          );
        })
        .toList(growable: false);

    return _sortBookingsByCreatedAtDesc(resolved);
  }

  bool _isTicketDateEnded(DateTime ticketDate, DateTime now) {
    final ticketDateLocal = ticketDate.toLocal();
    final nowLocal = now.toLocal();
    final dayEnd = DateTime(
      ticketDateLocal.year,
      ticketDateLocal.month,
      ticketDateLocal.day,
      23,
      59,
      59,
      999,
      999,
    );
    return nowLocal.isAfter(dayEnd);
  }

  List<BookingModel> _sortBookingsByCreatedAtDesc(List<BookingModel> bookings) {
    final sortedBookings = [...bookings]
      ..sort((left, right) {
        final leftDate =
            left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate =
            right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightDate.compareTo(leftDate);
      });
    return sortedBookings;
  }
}
