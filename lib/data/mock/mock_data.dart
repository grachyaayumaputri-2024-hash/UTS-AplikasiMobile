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

  static UserModel helpdeskUser = UserModel(
    id: 'user-002',
    name: 'Budi Helpdesk',
    email: 'helpdesk@unair.ac.id',
    username: 'helpdesk',
    role: 'helpdesk',
    createdAt: DateTime(2024, 1, 5),
  );

  static UserModel regularUser = UserModel(
    id: 'user-003',
    name: 'Siti Mahasiswa',
    email: 'siti@student.unair.ac.id',
    username: 'user',
    role: 'user',
    createdAt: DateTime(2024, 2, 10),
  );

  static set currentRegularUser(UserModel user) {
    regularUser = user;
  }

  static List<UserModel> helpdeskList = [
    helpdeskUser,
    UserModel(
      id: 'user-004',
      name: 'Andi Support',
      email: 'andi@unair.ac.id',
      username: 'andi',
      role: 'helpdesk',
      createdAt: DateTime(2024, 1, 10),
    ),
    UserModel(
      id: 'user-005',
      name: 'Dewi IT',
      email: 'dewi@unair.ac.id',
      username: 'dewi',
      role: 'helpdesk',
      createdAt: DateTime(2024, 1, 15),
    ),
  ];

  // ─── Tickets ─────────────────────────────────────────────────────────────────

  static List<TicketModel> get tickets => [
    TicketModel(
      id: 'tkt-0001abcd',
      title: 'Laptop tidak bisa menyala',
      description:
      'Laptop saya mendadak mati dan tidak bisa dihidupkan kembali sejak kemarin sore. Sudah dicoba charge semalaman tetapi tetap tidak menyala. Lampu indikator juga tidak menyala sama sekali.',
      status: TicketStatus.inProgress,
      priority: TicketPriority.high,
      category: 'Hardware',
      reporter: regularUser,
      assignedTo: helpdeskUser,
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
          author: helpdeskUser,
          content:
          'Terima kasih laporannya. Silakan bawa laptop ke ruang IT lantai 2 besok pagi untuk dicek lebih lanjut.',
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
      'Sejak pagi ini saya tidak bisa terhubung ke jaringan WiFi kampus di Gedung C. Perangkat lain di sekitar saya juga mengalami hal yang sama.',
      status: TicketStatus.open,
      priority: TicketPriority.medium,
      category: 'Jaringan / Internet',
      reporter: regularUser,
      assignedTo: null,
      attachments: [],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TicketModel(
      id: 'tkt-0003ijkl',
      title: 'Akun SISTER tidak bisa login',
      description:
      'Akun SISTER saya terblokir setelah beberapa kali salah memasukkan password. Sudah coba reset password tapi email konfirmasi tidak masuk.',
      status: TicketStatus.resolved,
      priority: TicketPriority.critical,
      category: 'Akun & Akses',
      reporter: regularUser,
      assignedTo: helpdeskUser,
      attachments: [],
      comments: [
        CommentModel(
          id: 'cmt-003',
          ticketId: 'tkt-0003ijkl',
          author: helpdeskUser,
          content: 'Akun sudah direset. Silakan cek email dan login kembali.',
          createdAt:
          DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt:
      DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      resolvedAt:
      DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    ),
    TicketModel(
      id: 'tkt-0004mnop',
      title: 'Printer di ruang lab error',
      description:
      'Printer di lab komputer lantai 3 menampilkan pesan error "Paper Jam" meskipun tidak ada kertas yang tersangkut. Sudah dicoba restart tetapi masih error.',
      status: TicketStatus.open,
      priority: TicketPriority.low,
      category: 'Printer',
      reporter: regularUser,
      assignedTo: null,
      attachments: [],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    TicketModel(
      id: 'tkt-0005qrst',
      title: 'Software SPSS tidak bisa diinstall',
      description:
      'Mencoba menginstall SPSS versi terbaru di laptop pribadi tetapi selalu gagal di tahap akhir instalasi dengan pesan "Installation Failed".',
      status: TicketStatus.closed,
      priority: TicketPriority.medium,
      category: 'Software',
      reporter: regularUser,
      assignedTo: helpdeskUser,
      attachments: [],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ─── Dashboard Stats ──────────────────────────────────────────────────────

  static DashboardStatsModel get stats => DashboardStatsModel(
    totalTickets: tickets.length,
    openTickets:
    tickets.where((t) => t.status == TicketStatus.open).length,
    inProgressTickets: tickets
        .where((t) => t.status == TicketStatus.inProgress)
        .length,
    resolvedTickets:
    tickets.where((t) => t.status == TicketStatus.resolved).length,
    closedTickets:
    tickets.where((t) => t.status == TicketStatus.closed).length,
  );

  // ─── Notifications ────────────────────────────────────────────────────────

  static List<NotificationModel> get notifications => [
    NotificationModel(
      id: 'notif-001',
      userId: regularUser.id,
      title: 'Tiket sedang diproses',
      body: 'Tiket "Laptop tidak bisa menyala" sedang ditangani oleh Budi Helpdesk.',
      type: NotificationType.ticketAssigned,
      ticketId: 'tkt-0001abcd',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'notif-002',
      userId: regularUser.id,
      title: 'Komentar baru',
      body: 'Budi Helpdesk membalas tiket "Laptop tidak bisa menyala".',
      type: NotificationType.newComment,
      ticketId: 'tkt-0001abcd',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif-003',
      userId: regularUser.id,
      title: 'Tiket berhasil diselesaikan',
      body: 'Tiket "Akun SISTER tidak bisa login" telah diselesaikan.',
      type: NotificationType.ticketResolved,
      ticketId: 'tkt-0003ijkl',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    ),
    NotificationModel(
      id: 'notif-004',
      userId: regularUser.id,
      title: 'Tiket baru dibuat',
      body: 'Tiket "Tidak bisa akses WiFi kampus" berhasil dibuat.',
      type: NotificationType.ticketCreated,
      ticketId: 'tkt-0002efgh',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'notif-005',
      userId: regularUser.id,
      title: 'Tiket ditutup',
      body: 'Tiket "Software SPSS tidak bisa diinstall" telah ditutup.',
      type: NotificationType.ticketClosed,
      ticketId: 'tkt-0005qrst',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // ─── Ticket History ───────────────────────────────────────────────────────

  static List<Map<String, dynamic>> ticketHistory(String ticketId) => [
    {
      'action': 'Tiket dibuat',
      'actor': 'Grachya Mahasiswa',
      'time': '1 hari lalu',
    },
    {
      'action': 'Status diubah ke In Progress',
      'actor': 'Budi Helpdesk',
      'time': '20 jam lalu',
    },
    {
      'action': 'Tiket di-assign ke Budi Helpdesk',
      'actor': 'Admin Sistem',
      'time': '18 jam lalu',
    },
    {
      'action': 'Komentar ditambahkan',
      'actor': 'Budi Helpdesk',
      'time': '1 jam lalu',
    },
  ];
}