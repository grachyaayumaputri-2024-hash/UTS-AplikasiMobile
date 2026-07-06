import '../models/models.dart';

class MockData {
  // ─── Users ──────────────────────────────────────────────────────────────────

  static UserModel adminUser = UserModel(
    id: 'user-001',
    name: 'Admin Sistem',
    email: 'admin@unair.ac.id',
    username: 'admin',
    role: 'admin',
    createdAt: DateTime(2024, 1, 1),
  );

  // Helpdesk A — Hardware & Printer
  static UserModel helpdeskA = UserModel(
    id: 'user-002',
    name: 'Helpdesk A',
    email: 'helpdeska@unair.ac.id',
    username: 'helpdeska',
    role: 'helpdesk',
    createdAt: DateTime(2024, 1, 5),
  );

  // Helpdesk B — Software & Akun & Akses
  static UserModel helpdeskB = UserModel(
    id: 'user-003',
    name: 'Helpdesk B',
    email: 'helpdeskb@unair.ac.id',
    username: 'helpdeskb',
    role: 'helpdesk',
    createdAt: DateTime(2024, 1, 6),
  );

  // Helpdesk C — Jaringan/Internet & Email
  static UserModel helpdeskC = UserModel(
    id: 'user-004',
    name: 'Helpdesk C',
    email: 'helpdeskc@unair.ac.id',
    username: 'helpdeskc',
    role: 'helpdesk',
    createdAt: DateTime(2024, 1, 7),
  );

  static UserModel regularUser = UserModel(
    id: 'user-005',
    name: 'Siti Mahasiswa',
    email: 'siti@student.unair.ac.id',
    username: 'user',
    role: 'user',
    createdAt: DateTime(2024, 2, 10),
  );

  static List<UserModel> get helpdeskList => [helpdeskA, helpdeskB, helpdeskC];

  // ─── Kategori → Helpdesk mapping ────────────────────────────────────────────

  /// Mapping kategori tiket ke helpdesk yang bertanggung jawab
  static const Map<String, String> categoryHelpdeskMap = {
    'Hardware':          'user-002', // Helpdesk A
    'Printer':           'user-002', // Helpdesk A
    'Software':          'user-003', // Helpdesk B
    'Akun & Akses':      'user-003', // Helpdesk B
    'Jaringan / Internet': 'user-004', // Helpdesk C
    'Email':             'user-004', // Helpdesk C
    'Lainnya':           '',         // Assign manual oleh Admin
  };

  /// Ambil UserModel helpdesk berdasarkan kategori
  static UserModel? getHelpdeskByCategory(String category) {
    final id = categoryHelpdeskMap[category];
    if (id == null || id.isEmpty) return null;
    return helpdeskList.firstWhere(
          (h) => h.id == id,
      orElse: () => helpdeskA,
    );
  }

  /// Keterangan tanggung jawab per helpdesk
  static String getHelpdeskScope(String helpdeskId) {
    switch (helpdeskId) {
      case 'user-002':
        return 'Hardware & Printer';
      case 'user-003':
        return 'Software & Akun & Akses';
      case 'user-004':
        return 'Jaringan / Internet & Email';
      default:
        return '-';
    }
  }

  // ─── Tickets ─────────────────────────────────────────────────────────────────

  static List<TicketModel> get tickets => [
    TicketModel(
      id: 'tkt-0001abcd',
      title: 'Laptop tidak bisa menyala',
      description:
      'Laptop saya mendadak mati dan tidak bisa dihidupkan kembali sejak kemarin sore. Sudah dicoba charge semalaman tetapi tetap tidak menyala.',
      status: TicketStatus.inProgress,
      priority: TicketPriority.high,
      category: 'Hardware',
      reporter: regularUser,
      assignedTo: helpdeskA, // Hardware → Helpdesk A
      attachments: [],
      comments: [
        CommentModel(
          id: 'cmt-001',
          ticketId: 'tkt-0001abcd',
          author: regularUser,
          content: 'Ini terjadi setelah saya pakai di lab kemarin.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        CommentModel(
          id: 'cmt-002',
          ticketId: 'tkt-0001abcd',
          author: helpdeskA,
          content:
          'Terima kasih laporannya. Silakan bawa laptop ke ruang IT lantai 2 besok pagi untuk dicek.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    TicketModel(
      id: 'tkt-0002efgh',
      title: 'Tidak bisa akses WiFi kampus',
      description:
      'Sejak pagi ini saya tidak bisa terhubung ke jaringan WiFi kampus di Gedung C.',
      status: TicketStatus.open,
      priority: TicketPriority.medium,
      category: 'Jaringan / Internet',
      reporter: regularUser,
      assignedTo: helpdeskC, // Jaringan → Helpdesk C
      attachments: [],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TicketModel(
      id: 'tkt-0003ijkl',
      title: 'Akun SISTER tidak bisa login',
      description:
      'Akun SISTER saya terblokir setelah beberapa kali salah memasukkan password.',
      status: TicketStatus.resolved,
      priority: TicketPriority.critical,
      category: 'Akun & Akses',
      reporter: regularUser,
      assignedTo: helpdeskB, // Akun → Helpdesk B
      attachments: [],
      comments: [
        CommentModel(
          id: 'cmt-003',
          ticketId: 'tkt-0003ijkl',
          author: helpdeskB,
          content: 'Akun sudah direset. Silakan cek email dan login kembali.',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    ),
    TicketModel(
      id: 'tkt-0004mnop',
      title: 'Printer di ruang lab error',
      description:
      'Printer di lab komputer lantai 3 menampilkan pesan error "Paper Jam" meskipun tidak ada kertas yang tersangkut.',
      status: TicketStatus.open,
      priority: TicketPriority.low,
      category: 'Printer',
      reporter: regularUser,
      assignedTo: helpdeskA, // Printer → Helpdesk A
      attachments: [],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    TicketModel(
      id: 'tkt-0005qrst',
      title: 'Software SPSS tidak bisa diinstall',
      description:
      'Mencoba menginstall SPSS versi terbaru di laptop pribadi tetapi selalu gagal di tahap akhir instalasi.',
      status: TicketStatus.closed,
      priority: TicketPriority.medium,
      category: 'Software',
      reporter: regularUser,
      assignedTo: helpdeskB, // Software → Helpdesk B
      attachments: [],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ─── Dashboard Stats ──────────────────────────────────────────────────────

  static DashboardStatsModel get stats {
    final t = tickets;
    return DashboardStatsModel(
      totalTickets: t.length,
      openTickets: t.where((x) => x.status == TicketStatus.open).length,
      inProgressTickets: t.where((x) => x.status == TicketStatus.inProgress).length,
      resolvedTickets: t.where((x) => x.status == TicketStatus.resolved).length,
      closedTickets: t.where((x) => x.status == TicketStatus.closed).length, assignedTickets: 0,
    );
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  static List<NotificationModel> get notifications => [
    NotificationModel(
      id: 'notif-001',
      userId: regularUser.id,
      title: 'Tiket sedang diproses',
      body: 'Tiket "Laptop tidak bisa menyala" ditangani oleh Helpdesk A.',
      type: NotificationType.ticketAssigned,
      ticketId: 'tkt-0001abcd',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'notif-002',
      userId: regularUser.id,
      title: 'Komentar baru',
      body: 'Helpdesk A membalas tiket "Laptop tidak bisa menyala".',
      type: NotificationType.newComment,
      ticketId: 'tkt-0001abcd',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif-003',
      userId: regularUser.id,
      title: 'Tiket berhasil diselesaikan',
      body: 'Tiket "Akun SISTER tidak bisa login" telah diselesaikan oleh Helpdesk B.',
      type: NotificationType.ticketResolved,
      ticketId: 'tkt-0003ijkl',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    ),
    NotificationModel(
      id: 'notif-004',
      userId: regularUser.id,
      title: 'Tiket baru dibuat',
      body: 'Tiket "Tidak bisa akses WiFi kampus" berhasil dibuat dan diteruskan ke Helpdesk C.',
      type: NotificationType.ticketCreated,
      ticketId: 'tkt-0002efgh',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // ─── Ticket History ───────────────────────────────────────────────────────

  static List<Map<String, dynamic>> ticketHistory(String ticketId) => [
    {'action': 'Tiket dibuat', 'actor': regularUser.name, 'time': '1 hari lalu'},
    {'action': 'Auto-assign ke Helpdesk A (Hardware)', 'actor': 'Sistem', 'time': '1 hari lalu'},
    {'action': 'Status diubah ke In Progress', 'actor': helpdeskA.name, 'time': '20 jam lalu'},
    {'action': 'Komentar ditambahkan', 'actor': helpdeskA.name, 'time': '1 jam lalu'},
  ];
}