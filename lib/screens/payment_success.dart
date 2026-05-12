import 'package:flutter/material.dart';

import '../data/models/ticket_model.dart';
import '../widgets/e_ticket_overlay.dart';

class PaymentSuccessPage extends StatelessWidget {
  final TicketModel ticket;
  final List<String> seats;
  final int totalPrice;
  final int bookingSequence;

  PaymentSuccessPage({
    super.key,
    TicketModel? ticket,
    this.seats = const <String>[],
    this.totalPrice = 0,
    this.bookingSequence = 1,
  }) : ticket =
           ticket ??
           TicketModel(
             id: '',
             originStation: '-',
             destinationStation: '-',
             date: DateTime.now(),
             train: '-',
             status: 'available',
           );

  @override
  Widget build(BuildContext context) {
    final seatDisplay = seats.join(', ');
    return Scaffold(
      backgroundColor: const Color(0xFF0A49F7),
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0451C4), Color(0xFF0B2ACC), Color(0xFF0A49F7)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildCheckCircle(),
                  const SizedBox(height: 18),
                  const Text(
                    'Pembayaran Berhasil!',
                    style: TextStyle(
                      color: Color(0xFF20FF21),
                      fontSize: 50 * 0.57,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildTicketCard(context, seatDisplay),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: SizedBox(
                              height: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0x00FFFFFF),
                                      Color(0xA6FFFFFF),
                                      Color(0x00FFFFFF),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SizedBox(
                              height: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0x00FFFFFF),
                                      Color(0x73FFFFFF),
                                      Color(0x00FFFFFF),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0x2BFFFFFF),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(58),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Kembali ke beranda',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckCircle() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8E8E8),
        border: Border.all(color: const Color(0xFF22D100), width: 8),
      ),
      child: const Icon(Icons.check, color: Color(0xFF22D100), size: 76),
    );
  }

  Widget _buildTicketCard(BuildContext context, String seatDisplay) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.train,
                  style: const TextStyle(
                    color: Color(0xFF0451C4),
                    fontSize: 20 * 0.57,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ticket.seatClass ?? 'Eksekutif',
                  style: const TextStyle(
                    fontSize: 16 * 0.57,
                    color: Color(0xB2464646),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.event_seat,
                      size: 14,
                      color: Color(0xB2464646),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      seatDisplay,
                      style: const TextStyle(
                        color: Color(0x60E63131),
                        fontSize: 16 * 0.57,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _timeBlock(ticket.departTime ?? '-', ticket.originStation),
                    Text(
                      ticket.duration ?? '-',
                      style: const TextStyle(
                        fontSize: 16 * 0.57,
                        color: Color(0xB2464646),
                      ),
                    ),
                    _timeBlock(
                      ticket.arriveTime ?? '-',
                      ticket.destinationStation,
                      alignRight: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metaBlock('TANGGAL BOOKING', _formatDate(ticket.date)),
                    _metaBlock(
                      'TOTAL BAYAR',
                      _formatIdr(totalPrice),
                      isBlue: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showEticket(context, seatDisplay),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF2CF43),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.confirmation_num, size: 18, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      'E-Ticket Anda',
                      style: TextStyle(
                        fontSize: 27 * 0.57,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBlock(String time, String station, {bool alignRight = false}) {
    final align = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 35 * 0.57,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          station,
          style: const TextStyle(fontSize: 10, color: Color(0xFF464646)),
        ),
      ],
    );
  }

  Widget _metaBlock(String label, String value, {bool isBlue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16 * 0.57, color: Color(0xB2464646)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 33 * 0.57,
            fontWeight: FontWeight.w600,
            color: isBlue ? const Color(0xFF0451C4) : Colors.black,
            fontStyle: isBlue ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _showEticket(BuildContext context, String seatDisplay) {
    final data = ETicketOverlayData(
      bookingSequence: bookingSequence,
      origin: ticket.originStation,
      destination: ticket.destinationStation,
      bookingDate: _formatDateLong(ticket.date),
      departureTime: ticket.departTime ?? '-',
      passengerName: 'Kamil',
      seatClass: (ticket.seatClass ?? 'Eksekutif').toUpperCase(),
      trainName: ticket.train,
      seatLabel: 'KURSI $seatDisplay',
    );
    return showETicketOverlay(context: context, data: data);
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
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

  String _formatIdr(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'IDR $formatted';
  }
}
