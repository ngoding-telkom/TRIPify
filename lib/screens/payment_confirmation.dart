import 'package:flutter/material.dart';

import '../data/models/ticket_model.dart';
import '../data/repositories/firestore_booking_repository.dart';
import 'payment_success.dart';

class PaymentConfirmationPage extends StatefulWidget {
  const PaymentConfirmationPage({
    super.key,
    required this.ticket,
    required this.selectedSeats,
    required this.passengers,
    required this.userId,
    required this.bookingRepository,
  });

  final TicketModel ticket;
  final List<String> selectedSeats;
  final int passengers;
  final String userId;
  final BookingRepository bookingRepository;

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    final pricePerSeat = widget.ticket.price ?? 0;
    final totalPrice = pricePerSeat * widget.selectedSeats.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F1),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _buildSummaryCard(pricePerSeat, totalPrice),
                  const SizedBox(height: 16),
                  _buildPaymentInfoCard(totalPrice),
                  const SizedBox(height: 16),
                  _buildNotice(),
                ],
              ),
            ),
          ),
          _buildBottomBar(totalPrice),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 54, 24, 18),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(false),
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 25,
              height: 25,
              child: Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Pembayaran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 25),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int pricePerSeat, int totalPrice) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.ticket.train,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.ticket.originStation} → ${widget.ticket.destinationStation}',
            style: const TextStyle(color: Color(0xFF666666)),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          _row('Tanggal', _formatDate(widget.ticket.date)),
          _row(
            'Jam',
            '${widget.ticket.departTime ?? '-'} - ${widget.ticket.arriveTime ?? '-'}',
          ),
          _row('Kelas', widget.ticket.seatClass ?? 'Ekonomi'),
          _row('Kursi', widget.selectedSeats.join(', ')),
          _row('Penumpang', '${widget.passengers}'),
          _row('Harga/kursi', _formatIdr(pricePerSeat)),
          const Divider(),
          _row(
            'Total',
            _formatIdr(totalPrice),
            valueStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFE20000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(int totalPrice) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE1E1E1)),
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFF8F8F8),
            ),
            child: const Text('Simulasi - Virtual Account'),
          ),
          const SizedBox(height: 10),
          Text(
            'Tagihan: ${_formatIdr(totalPrice)}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Pembayaran mode simulasi. Tekan tombol bayar untuk selesaikan booking.',
        style: TextStyle(fontSize: 12, color: Color(0xFF6A5E1D)),
      ),
    );
  }

  Widget _buildBottomBar(int totalPrice) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: ElevatedButton(
          onPressed: _paying ? null : () => _onPayPressed(totalPrice),
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
          child: _paying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Bayar ${_formatIdr(totalPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _onPayPressed(int totalPrice) async {
    setState(() => _paying = true);
    try {
      await widget.bookingRepository.bookSeats(
        userId: widget.userId,
        ticketId: widget.ticket.id,
        seatNumbers: widget.selectedSeats,
      );
      final bookingIds =
          widget.selectedSeats
              .map((seat) => '${widget.ticket.id}_$seat')
              .toList()
            ..sort();
      final bookingSequence = await widget.bookingRepository.getBookingSequence(
        bookingId: bookingIds.first,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            ticket: widget.ticket,
            seats: widget.selectedSeats,
            totalPrice: totalPrice,
            bookingSequence: bookingSequence,
          ),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pembayaran gagal: $error')));
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
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
}
