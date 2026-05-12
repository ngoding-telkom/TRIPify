import 'package:flutter/material.dart';

import '../data/models/booking_model.dart';
import '../data/models/ticket_model.dart';
import '../data/repositories/firestore_booking_repository.dart';
import '../widgets/e_ticket_overlay.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({
    super.key,
    required this.bookingRepository,
    required this.userId,
  });

  final BookingRepository bookingRepository;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F1),
      body: Column(
        children: [
          const _HistoryHeader(),
          Expanded(
            child: _HistoryList(
              bookingRepository: bookingRepository,
              userId: userId,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 54, 24, 16),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 28,
              height: 28,
              child: Icon(Icons.arrow_back, size: 22),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Riwayat Anda',
                style: TextStyle(
                  fontSize: 32 * 0.57,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.bookingRepository, required this.userId});

  final BookingRepository bookingRepository;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: bookingRepository.watchUserBookings(userId: userId),
      builder: (context, bookingsSnapshot) {
        if (bookingsSnapshot.hasError) {
          return _CenteredInfo(
            message: 'Gagal memuat riwayat: ${bookingsSnapshot.error}',
          );
        }
        if (bookingsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final historyBookings =
            (bookingsSnapshot.data ?? const <BookingModel>[])
                .where((booking) => _isHistoryStatus(booking.status))
                .toList(growable: false);
        if (historyBookings.isEmpty) {
          return const _CenteredInfo(
            message: 'Belum ada riwayat booking selesai atau dibatalkan.',
          );
        }

        return StreamBuilder<List<TicketModel>>(
          stream: bookingRepository.watchAllTickets(),
          builder: (context, ticketsSnapshot) {
            if (ticketsSnapshot.hasError) {
              return _CenteredInfo(
                message: 'Gagal memuat tiket: ${ticketsSnapshot.error}',
              );
            }
            if (ticketsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final ticketMap = {
              for (final ticket
                  in (ticketsSnapshot.data ?? const <TicketModel>[]))
                ticket.id: ticket,
            };

            final cards = historyBookings
                .map((booking) {
                  final ticket = ticketMap[booking.ticketId];
                  if (ticket == null) {
                    return null;
                  }
                  return _HistoryBookingCard(
                    booking: booking,
                    ticket: ticket,
                    bookingRepository: bookingRepository,
                  );
                })
                .whereType<_HistoryBookingCard>()
                .toList(growable: false);

            if (cards.isEmpty) {
              return const _CenteredInfo(
                message: 'Tiket untuk riwayat tidak ditemukan.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              itemCount: cards.length,
              separatorBuilder: (_, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) => cards[index],
            );
          },
        );
      },
    );
  }
}

class _HistoryBookingCard extends StatelessWidget {
  const _HistoryBookingCard({
    required this.booking,
    required this.ticket,
    required this.bookingRepository,
  });

  final BookingModel booking;
  final TicketModel ticket;
  final BookingRepository bookingRepository;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromRGBO(113, 113, 113, 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: Color.fromRGBO(70, 70, 70, 0.5),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDateLong(
                                  booking.createdAt ?? ticket.date,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${ticket.departTime ?? '-'}→${ticket.arriveTime ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _HistoryStatusBadge(status: booking.status),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _deleteBooking(context),
                          borderRadius: BorderRadius.circular(14),
                          child: const SizedBox(
                            width: 26,
                            height: 26,
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Color(0xFFE63131),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.event_seat,
                      size: 14,
                      color: Color.fromRGBO(70, 70, 70, 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking.seatNumber,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                SizedBox(
                  height: 115,
                  child: Row(
                    children: [
                      _RouteBlock(
                        label: 'Dari',
                        station: ticket.originStation,
                        alignRight: false,
                      ),
                      const Expanded(child: Divider(height: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_right_alt,
                          color: Color(0xFF9A9A9A),
                          size: 24,
                        ),
                      ),
                      const Expanded(child: Divider(height: 1)),
                      _RouteBlock(
                        label: 'Ke',
                        station: ticket.destinationStation,
                        alignRight: true,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.train,
                              style: const TextStyle(
                                color: Color(0xFF0451C4),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              ticket.seatClass ?? 'Eksekutif',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF464646),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MetaBlock(
                        label: 'TOTAL BAYAR',
                        value: _formatIdr(ticket.price),
                        alignRight: true,
                        valueColor: const Color.fromRGBO(0, 0, 0, 0.5),
                        italicValue: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showETicket(context),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFBD146),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_num, color: Colors.black, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'E-Ticket Anda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showETicket(BuildContext context) async {
    try {
      final bookingSequence = await bookingRepository.getBookingSequence(
        bookingId: booking.id,
      );
      if (!context.mounted) {
        return;
      }
      await showETicketOverlay(
        context: context,
        data: ETicketOverlayData(
          bookingSequence: bookingSequence,
          origin: ticket.originStation,
          destination: ticket.destinationStation,
          bookingDate: _formatDateLong(booking.createdAt ?? ticket.date),
          departureTime: ticket.departTime ?? '-',
          passengerName: 'Kamil',
          seatClass: (ticket.seatClass ?? 'Eksekutif').toUpperCase(),
          trainName: ticket.train,
          seatLabel: 'KURSI ${booking.seatNumber}',
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka e-ticket: $error')));
    }
  }

  Future<void> _deleteBooking(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus riwayat booking?'),
          content: const Text('Data booking ini akan dihapus permanen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) {
      return;
    }

    try {
      await bookingRepository.deleteBooking(bookingId: booking.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal hapus booking: $error')));
    }
  }
}

class _HistoryStatusBadge extends StatelessWidget {
  const _HistoryStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final bool isCancelled = normalized == 'cancelled';
    final Color background = isCancelled
        ? const Color.fromRGBO(255, 0, 0, 0.3)
        : const Color.fromRGBO(0, 0, 0, 0.24);
    final String label = isCancelled ? 'Dibatalkan' : 'Selesai';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(0, 0, 0, 0.5),
        ),
      ),
    );
  }
}

class _RouteBlock extends StatelessWidget {
  const _RouteBlock({
    required this.label,
    required this.station,
    required this.alignRight,
  });

  final String label;
  final String station;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final crossAxis = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    return SizedBox(
      width: 102,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxis,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(0, 0, 0, 0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            station.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.label,
    required this.value,
    this.alignRight = false,
    this.valueColor = Colors.black,
    this.italicValue = false,
  });

  final String label;
  final String value;
  final bool alignRight;
  final Color valueColor;
  final bool italicValue;

  @override
  Widget build(BuildContext context) {
    final crossAxis = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;
    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: crossAxis,
        children: [
          Text(
            label,
            textAlign: textAlign,
            style: const TextStyle(fontSize: 12, color: Color(0xFF464646)),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
              fontStyle: italicValue ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredInfo extends StatelessWidget {
  const _CenteredInfo({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF5F5F5F)),
        ),
      ),
    );
  }
}

bool _isHistoryStatus(String status) {
  final normalized = status.toLowerCase();
  return normalized == 'completed' || normalized == 'cancelled';
}

String _formatDateLong(DateTime value) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String _formatIdr(int? value) {
  if (value == null) {
    return 'IDR -';
  }
  final formatted = value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return 'IDR $formatted';
}
