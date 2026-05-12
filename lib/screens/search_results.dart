import 'package:flutter/material.dart';

import '../data/models/ticket_model.dart';
import '../data/repositories/firestore_booking_repository.dart';
import 'seat_selection.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
    required this.passengers,
    required this.userId,
    required this.bookingRepository,
  });

  final String origin;
  final String destination;
  final DateTime date;
  final int passengers;
  final String userId;
  final BookingRepository bookingRepository;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late String _origin;
  late String _destination;

  static const List<String> _indonesianStations = [
    'Jakarta (CGK)',
    'Bandung (BD)',
    'Surabaya (SBY)',
    'Yogyakarta (YIA)',
    'Medan (KNO)',
    'Semarang (SRG)',
    'Makassar (UPG)',
    'Denpasar (DPS)',
    'Palembang (PLM)',
    'Balikpapan (BPN)',
    'Banjarmasin (BJM)',
    'Jambi (JSM)',
    'Riau (PKU)',
    'Padang (PDG)',
    'Pontianak (PNK)',
    'Samarinda (SRI)',
    'Kupang (KOE)',
    'Manado (MDC)',
    'Bandarlampung (TKG)',
    'Malang (MLG)',
    'Solo (SLO)',
    'Sleman (SLM)',
    'Kediri (KDI)',
    'Jombang (JMB)',
    'Gresik (GSK)',
    'Tuban (TBN)',
    'Cilacap (CLP)',
    'Purwokerto (PWK)',
    'Pekalongan (PKL)',
    'Tegal (TGL)',
    'Cirebon (CRB)',
    'Indramayu (IDM)',
    'Karawang (KRW)',
    'Bekasi (BKS)',
    'Depok (DPK)',
    'Tangerang (TNG)',
    'Serang (SRG)',
    'Bogor (BGR)',
  ];

  @override
  void initState() {
    super.initState();
    _origin = widget.origin;
    _destination = widget.destination;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F1),
      body: CustomScrollView(
        slivers: [
          // Blue gradient header with "Hasil Pencarian" title
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F1398), Color(0xFF0451C4)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Hasil Pencarian',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter bar with origin and destination
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _editStation(isOrigin: true),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dari',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _origin,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.edit_location_alt_outlined,
                                          size: 14,
                                          color: Color(0xFF666666),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _editStation(isOrigin: false),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Menuju',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _destination,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.edit_location_alt_outlined,
                                          size: 14,
                                          color: Color(0xFF666666),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Results list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<TicketModel>>(
                stream: widget.bookingRepository.watchAvailableTickets(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Gagal memuat: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tickets = snapshot.data ?? const <TicketModel>[];
                  final filtered = tickets
                      .where((t) {
                        final sameOrigin = t.originStation
                            .toLowerCase()
                            .contains(_normalizedStationQuery(_origin));
                        final sameDest = t.destinationStation
                            .toLowerCase()
                            .contains(_normalizedStationQuery(_destination));
                        final sameDate =
                            t.date.year == widget.date.year &&
                            t.date.month == widget.date.month &&
                            t.date.day == widget.date.day;
                        return sameOrigin && sameDest && sameDate;
                      })
                      .toList(growable: false);

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada hasil untuk pencarian ini.'),
                    );
                  }

                  return Column(
                    children: List.generate(
                      filtered.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTicketCard(
                          context,
                          filtered[index],
                          isFirstForDate: index == 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    TicketModel ticket, {
    bool isFirstForDate = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SeatSelectionPage(
              ticket: ticket,
              passengers: widget.passengers,
              userId: widget.userId,
              bookingRepository: widget.bookingRepository,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Train name, class, and price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.train,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ticket.seatClass ?? 'Ekonomi',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF464646),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatIdr(ticket.price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE20000),
                            ),
                          ),
                          if (ticket.seatsLeft != null &&
                              ticket.seatsLeft! < 10) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${ticket.seatsLeft} kursi tersisa',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE63131),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Times and station row
                  Row(
                    children: [
                      // Departure
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.departTime ?? '-',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket.originStation,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7C7C7C),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: const Color(0xFFD1D1D1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ticket.duration ?? '-',
                                style: const TextStyle(
                                  fontSize: 7,
                                  color: Color(0xFF8C8C8C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Arrival
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ticket.arriveTime ?? '-',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket.destinationStation,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7C7C7C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Optional badge for cheapest
            if (isFirstForDate)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE63131),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Center(
                  child: Text(
                    'Termurah di tanggal ini!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatIdr(int? value) {
    if (value == null) return 'IDR -';
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'IDR $formatted';
  }

  Future<void> _editStation({required bool isOrigin}) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _StationPickerDialog(
        stations: _indonesianStations,
        title: isOrigin ? 'Pilih Stasiun Asal' : 'Pilih Stasiun Tujuan',
      ),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      if (isOrigin) {
        _origin = selected;
      } else {
        _destination = selected;
      }
    });
  }

  String _normalizedStationQuery(String rawStation) {
    return rawStation.toLowerCase().split('(').first.trim();
  }
}

class _StationPickerDialog extends StatefulWidget {
  const _StationPickerDialog({required this.stations, required this.title});

  final List<String> stations;
  final String title;

  @override
  State<_StationPickerDialog> createState() => _StationPickerDialogState();
}

class _StationPickerDialogState extends State<_StationPickerDialog> {
  late List<String> _filteredStations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStations = widget.stations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStations = widget.stations;
      } else {
        _filteredStations = widget.stations
            .where(
              (station) => station.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(growable: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 420,
        height: 470,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterStations,
                    decoration: InputDecoration(
                      hintText: 'Cari stasiun...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredStations.isEmpty
                  ? const Center(
                      child: Text(
                        'Stasiun tidak ditemukan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = _filteredStations[index];
                        return ListTile(
                          title: Text(station),
                          onTap: () => Navigator.of(context).pop(station),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Batal'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
