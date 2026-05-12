import 'package:flutter/material.dart';

import '../data/models/ticket_model.dart';
import '../data/repositories/firestore_booking_repository.dart';
import 'payment_confirmation.dart';

class SeatSelectionPage extends StatefulWidget {
  const SeatSelectionPage({
    super.key,
    required this.ticket,
    required this.passengers,
    required this.userId,
    required this.bookingRepository,
  });

  final TicketModel ticket;
  final int passengers;
  final String userId;
  final BookingRepository bookingRepository;

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  static const int _rowCount = 8;

  final Set<String> _selectedSeats = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Booking Anda'),
      ),
      body: StreamBuilder<Set<String>>(
        stream: widget.bookingRepository.watchUnavailableSeats(
          ticketId: widget.ticket.id,
        ),
        builder: (context, snapshot) {
          final unavailableSeats = snapshot.data ?? <String>{};
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 190),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTripInfo(),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                      _buildLegend(),
                      const SizedBox(height: 14),
                      _buildSeatGrid(unavailableSeats),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(unavailableSeats),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFB8C1FF),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: const Text(
                'Keberangkatan',
                style: TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(widget.ticket.date),
              style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(width: 6),
            const Text('•', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 6),
            Text(
              '${widget.ticket.departTime ?? '-'} - ${widget.ticket.arriveTime ?? '-'}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '${widget.ticket.train} • ${widget.ticket.seatClass ?? 'Ekonomi'}',
          style: const TextStyle(
            fontSize: 28 * 0.57,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.ticket.originStation,
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 6),
        Text(
          widget.ticket.destinationStation,
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _LegendItem(
          label: 'Tidak Tersedia',
          color: Color(0xFFB9B9B9),
          crossed: true,
        ),
        _LegendItem(label: 'Terpilih', color: Color(0xFF0368FF)),
        _LegendItem(label: 'Tersedia', color: Colors.white, border: true),
      ],
    );
  }

  Widget _buildSeatGrid(Set<String> unavailableSeats) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: const [
              Expanded(child: Center(child: Text('A'))),
              Expanded(child: Center(child: Text('B'))),
              SizedBox(width: 42),
              Expanded(child: Center(child: Text('C'))),
              Expanded(child: Center(child: Text('D'))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(_rowCount, (index) {
          final rowNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: _buildSeat('A$rowNumber', unavailableSeats)),
                const SizedBox(width: 8),
                Expanded(child: _buildSeat('B$rowNumber', unavailableSeats)),
                SizedBox(
                  width: 42,
                  child: Center(
                    child: Text(
                      '$rowNumber',
                      style: const TextStyle(fontSize: 20 * 0.57),
                    ),
                  ),
                ),
                Expanded(child: _buildSeat('C$rowNumber', unavailableSeats)),
                const SizedBox(width: 8),
                Expanded(child: _buildSeat('D$rowNumber', unavailableSeats)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSeat(String seatId, Set<String> unavailableSeats) {
    final isUnavailable = unavailableSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);
    final seatColor = isUnavailable
        ? const Color(0xFFB9B9B9)
        : isSelected
        ? const Color(0xFF0368FF)
        : Colors.white;

    return InkWell(
      onTap: () => _onSeatTap(seatId: seatId, isUnavailable: isUnavailable),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.3)),
        ),
        child: isUnavailable
            ? const Icon(Icons.close, color: Color(0xFF6B6B6B), size: 24)
            : null,
      ),
    );
  }

  Widget _buildBottomBar(Set<String> unavailableSeats) {
    final needCount = widget.passengers;
    final selectedCount = _selectedSeats.length;
    final missing = needCount - selectedCount;
    final canSubmit = missing <= 0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Color.fromRGBO(0, 0, 0, 0.15),
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.event_seat, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Silahkan Pilih Kursi',
                    style: TextStyle(fontSize: 28 * 0.57),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                missing > 0
                    ? 'Pilih $missing kursi lagi (${_selectedSeats.join(', ')})'
                    : 'Terpilih: ${_selectedSeats.join(', ')}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSubmit
                      ? () => _onConfirmPressed(unavailableSeats)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFACB25),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFFF1E39E),
                    disabledForegroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Konfirmasi Pilihan',
                    style: TextStyle(
                      fontSize: 20 * 0.57,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSeatTap({required String seatId, required bool isUnavailable}) {
    if (isUnavailable) {
      return;
    }
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
        return;
      }
      if (_selectedSeats.length >= widget.passengers) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maksimal ${widget.passengers} kursi')),
        );
        return;
      }
      _selectedSeats.add(seatId);
    });
  }

  Future<void> _onConfirmPressed(Set<String> unavailableSeats) async {
    final seats = _selectedSeats.toList(growable: false);
    if (seats.any(unavailableSeats.contains)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ada kursi sudah diambil user lain')),
      );
      return;
    }

    final booked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentConfirmationPage(
          ticket: widget.ticket,
          selectedSeats: seats,
          passengers: widget.passengers,
          userId: widget.userId,
          bookingRepository: widget.bookingRepository,
        ),
      ),
    );
    if (booked == true && mounted) {
      Navigator.of(context).pop(true);
    }
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
    return '${value.day} ${months[value.month - 1]}';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
    this.crossed = false,
    this.border = false,
  });

  final String label;
  final Color color;
  final bool crossed;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: border
                ? Border.all(color: const Color.fromRGBO(0, 0, 0, 0.3))
                : null,
          ),
          child: crossed
              ? const Icon(Icons.close, size: 12, color: Color(0xFF6B6B6B))
              : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
