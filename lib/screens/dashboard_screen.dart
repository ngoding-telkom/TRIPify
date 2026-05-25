import 'package:flutter/material.dart';

import '../data/models/ticket_model.dart';
import '../data/repositories/firestore_booking_repository.dart';
import 'search_results.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.displayName,
    required this.userId,
    required this.bookingRepository,
  });

  final String displayName;
  final String userId;
  final BookingRepository bookingRepository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _originController = TextEditingController(
    text: 'Bandung (BD)',
  );
  final TextEditingController _destinationController = TextEditingController(
    text: 'Surabaya (SBY)',
  );
  DateTime _selectedDate = DateTime.now();
  int _passengers = 1;

  // Indonesian train stations
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

  static const List<String> recentSearches = [
    'Bandung → Jakarta\n25 Oktober 2024',
    'Bandung → Jakarta\n24 Oktober 2024',
    'Bandung → Jakarta\n23 Oktober 2024',
  ];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bookingFormOverlap =
        0.0; // You can change the value, but for now its unused
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff2F1398), Color(0xff0451c4)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang Kembali!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.displayName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/logo_small.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Transform.translate(
                  offset: const Offset(0, bookingFormOverlap),
                  child: _buildBookingForm(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24 + bookingFormOverlap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pencarian Terakhir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentSearches.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                        right: index != recentSearches.length - 1 ? 12 : 0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recentSearches[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Promo & Diskon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Image.network(
                      'https://s-light.tiket.photos/t/01E25EBZS3W0FY9GTG6C42E1SE/rsfit40004000gsm/homenext_dashboard/2026/02/12/63fe03f1-dd8d-4cf8-9ba6-b9cd2d0df3ec-1770877580873-a15bcd644e1362cdcf6de7cdc41b8ab1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildBestDealSection(),
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF001D88), Color(0xFF0064FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dari',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _editStation(isOrigin: true),
                        child: Text(
                          _originController.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 12),
                      const Text(
                        'Ke',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _editStation(isOrigin: false),
                        child: Text(
                          _destinationController.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    // swap origin/destination
                    final tmp = _originController.text;
                    setState(() {
                      _originController.text = _destinationController.text;
                      _destinationController.text = tmp;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickPassengers,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Penumpang',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_passengers Penumpang',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _onSearchPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cari Tiket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.search, color: Colors.black87),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const weekdays = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
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
    final wd = weekdays[d.weekday % 7];
    final m = months[d.month - 1];
    return '$wd, ${d.day} $m';
  }

  Future<void> _editStation({required bool isOrigin}) async {
    final controller = isOrigin ? _originController : _destinationController;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _StationPickerDialog(
        stations: _indonesianStations,
        title: isOrigin ? 'Pilih Stasiun Asal' : 'Pilih Stasiun Tujuan',
      ),
    );
    if (selected != null) {
      setState(() {
        controller.text = selected;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickPassengers() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        var count = _passengers;
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Jumlah Penumpang'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () =>
                        setStateSB(() => count = (count - 1).clamp(1, 99)),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$count', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () =>
                        setStateSB(() => count = (count + 1).clamp(1, 99)),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(count),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() => _passengers = result);
    }
  }

  void _onSearchPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          origin: _originController.text,
          destination: _destinationController.text,
          date: _selectedDate,
          passengers: _passengers,
          userId: widget.userId,
          bookingRepository: widget.bookingRepository,
        ),
      ),
    );
  }

  Widget _buildBestDealSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Deal For You',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<TicketModel>>(
            stream: widget.bookingRepository.watchAvailableTickets(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Gagal memuat tiket: ${snapshot.error}'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);
              final tickets = (snapshot.data ?? const <TicketModel>[])
                  .where((ticket) => ticket.oldPrice != null)
                  .where((ticket) {
                    final t = ticket.date;
                    final ticketDate = DateTime(t.year, t.month, t.day);
                    return ticketDate == todayDate &&
                        ticket.status == 'available';
                  })
                  .toList(growable: false);
              if (tickets.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Belum ada tiket diskon tersedia.'),
                );
              }

              return Column(
                children: tickets
                    .map(_buildBestDealCard)
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBestDealCard(TicketModel ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E1E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 36, height: 24, alignment: Alignment.centerLeft),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.train,
                      style: const TextStyle(
                        fontSize: 24 * 0.72,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      ticket.seatClass ?? 'Ekonomi',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F5F5F),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (ticket.oldPrice != null)
                    Text(
                      _formatIdr(ticket.oldPrice),
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    _formatIdr(ticket.price),
                    style: const TextStyle(
                      color: Color(0xFFF81818),
                      fontSize: 32 * 0.72,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (ticket.seatsLeft != null && ticket.seatsLeft! < 10)
                    Text(
                      '${ticket.seatsLeft} kursi tersisa',
                      style: const TextStyle(
                        color: Color(0xFFF81818),
                        fontSize: 18 * 0.72,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStationColumn(
                ticket.departTime ?? '-',
                ticket.originStation,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFC8C8C8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          ticket.duration ?? '-',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFA9A9A9),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFC8C8C8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildStationColumn(
                ticket.arriveTime ?? '-',
                ticket.destinationStation,
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildStationColumn(String time, String station) {
    return SizedBox(
      width: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 20 * 0.72,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            station,
            style: const TextStyle(
              fontSize: 15 * 0.72,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
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
  late List<String> filteredStations;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredStations = widget.stations;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterStations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStations = widget.stations;
      } else {
        filteredStations = widget.stations
            .where(
              (station) => station.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  controller: searchController,
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
            child: filteredStations.isEmpty
                ? const Center(
                    child: Text(
                      'Stasiun tidak ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStations.length,
                    itemBuilder: (context, index) {
                      final station = filteredStations[index];
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
    );
  }
}
