import 'package:flutter/material.dart';

import '../data/models/booking_model.dart';
import '../data/models/ticket_model.dart';
import '../data/repositories/firestore_booking_repository.dart';
import '../widgets/e_ticket_overlay.dart';
import 'booking_history_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({
    super.key,
    required this.bookingRepository,
    required this.userId,
    required this.onBackToHome,
  });

  final BookingRepository bookingRepository;
  final String userId;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F1F1),
      child: Column(
        children: [
          _OrdersHeader(
            onBackTap: onBackToHome,
            onHistoryTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingHistoryPage(
                    bookingRepository: bookingRepository,
                    userId: userId,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: _OrdersList(
              bookingRepository: bookingRepository,
              userId: userId,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.onBackTap, required this.onHistoryTap});

  final VoidCallback onBackTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 54, 24, 16),
      child: Row(
        children: [
          InkWell(
            onTap: onBackTap,
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
                'Pesanan Anda',
                style: TextStyle(
                  fontSize: 32 * 0.57,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onHistoryTap,
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 46,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, color: Color(0xFF9A9A9A), size: 24),
                  SizedBox(height: 1),
                  Text(
                    'Riwayat',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9A9A9A)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.bookingRepository, required this.userId});

  final BookingRepository bookingRepository;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: bookingRepository.watchUserBookings(userId: userId),
      builder: (context, bookingsSnapshot) {
        if (bookingsSnapshot.hasError) {
          return _CenteredInfo(
            message: 'Gagal memuat pesanan: ${bookingsSnapshot.error}',
          );
        }
        if (bookingsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeBookings = (bookingsSnapshot.data ?? const <BookingModel>[])
            .where((booking) => _isOrderStatus(booking.status))
            .toList(growable: false);
        if (activeBookings.isEmpty) {
          return const _CenteredInfo(
            message: 'Belum ada pesanan pending atau dikonfirmasi.',
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
            final cards = activeBookings
                .map((booking) {
                  final ticket = ticketMap[booking.ticketId];
                  if (ticket == null) {
                    return null;
                  }
                  return _OrderBookingCard(
                    booking: booking,
                    ticket: ticket,
                    bookingRepository: bookingRepository,
                  );
                })
                .whereType<_OrderBookingCard>()
                .toList(growable: false);

            if (cards.isEmpty) {
              return const _CenteredInfo(
                message: 'Tiket untuk pesanan tidak ditemukan.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
              itemCount: cards.length,
              separatorBuilder: (_, index) => const SizedBox(height: 22),
              itemBuilder: (context, index) => cards[index],
            );
          },
        );
      },
    );
  }
}

class _OrderBookingCard extends StatelessWidget {
  const _OrderBookingCard({
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
                          const SizedBox(height: 6),
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
                    _OrderStatusBadge(status: booking.status),
                  ],
                ),
                const SizedBox(height: 12),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3F3F3F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                SizedBox(
                  height: 115,
                  child: Row(
                    children: [
                      _TimeStationBlock(
                        time: ticket.departTime ?? '-',
                        station: ticket.originStation,
                        alignRight: false,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              const Expanded(child: Divider(height: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.train_outlined,
                                      color: Color(0xFF0451C4),
                                      size: 20,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      ticket.duration ?? '-',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(child: Divider(height: 1)),
                            ],
                          ),
                        ),
                      ),
                      _TimeStationBlock(
                        time: ticket.arriveTime ?? '-',
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
                      _MetaBlock(
                        label: 'TANGGAL BOOKING',
                        value: _formatDateLong(
                          booking.createdAt ?? ticket.date,
                        ),
                      ),
                      _MetaBlock(
                        label: 'TOTAL BAYAR',
                        value: _formatIdr(ticket.price),
                        alignRight: true,
                        valueColor: const Color(0xFF0451C4),
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
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final bool isConfirmed = normalized == 'confirmed';
    final Color background = isConfirmed
        ? const Color.fromRGBO(0, 255, 9, 0.3)
        : const Color.fromRGBO(251, 209, 70, 0.5);
    final String label = isConfirmed ? 'Dikonfirmasi' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

class _TimeStationBlock extends StatelessWidget {
  const _TimeStationBlock({
    required this.time,
    required this.station,
    required this.alignRight,
  });

  final String time;
  final String station;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final crossAxis = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 32 * 0.57,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          station.toUpperCase(),
          style: const TextStyle(fontSize: 8, color: Colors.black),
        ),
      ],
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

bool _isOrderStatus(String status) {
  final normalized = status.toLowerCase();
  return normalized == 'pending' || normalized == 'confirmed';
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
