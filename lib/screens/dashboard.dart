import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../app_state.dart';
import 'package:intl/intl.dart';
import '/models/activity.dart';
import '/db/activitydao.dart';
import '/db/enfant_dao.dart';
import '/db/presencedao.dart';
import '/models/enfant.dart';
import '/models/Presence.dart';
import '/screens/enfant_profil_screen.dart';
import '/screens/presence_screen.dart';
import '/screens/suivipaie.dart';
import '/screens/depenses.dart';
import '/screens/stats.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? selectedClass;
  List<String> classes = [];

  final ActivityDao activityDao = ActivityDao();
  final EnfantDao enfantDao = EnfantDao();
  final PresenceDao presenceDao = PresenceDao();
  List<Activity> allActivities = [];

  int totalEnfants = 0;
  int inscriptionsCeMois = 0;
  int presentsAujourdhui = 0;

  @override
  void initState() {
    super.initState();
    _loadClassesAndActivities();
    _loadStats();
  }

  Future<void> _loadClassesAndActivities() async {
    final enfants = await enfantDao.getAllEnfants();
    final distinctClasses = enfants.map((e) => e.classe).toSet().toList();
    final activities = await activityDao.getAllActivities();

    if (!mounted) return;
    setState(() {
      classes = distinctClasses;
      allActivities = activities;

      if (classes.isNotEmpty && selectedClass == null) {
        selectedClass = classes[0];
      }
    });
  }

  Future<void> _loadStats() async {
    try {
      final List<Enfant> enfants = await enfantDao.getAllEnfants();
      final int total = enfants.length;

      final now = DateTime.now();
      final int inscriptionsMois = enfants.where((enfant) {
        if (enfant.dateInscription != null) {
          return enfant.dateInscription!.year == now.year &&
              enfant.dateInscription!.month == now.month;
        }
        return false;
      }).length;

      final aujourdhui = DateTime.now();
      final List<Presence> presencesAujourdhui = await presenceDao
          .getPresencesByDate(aujourdhui);

      int presents = 0;
      for (var presence in presencesAujourdhui) {
        final statut = presence.statut.toLowerCase();
        if (statut.contains('présent') || statut.contains('present')) {
          presents++;
        }
      }

      if (!mounted) return;
      setState(() {
        totalEnfants = total;
        inscriptionsCeMois = inscriptionsMois;
        presentsAujourdhui = presents;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        totalEnfants = 0;
        inscriptionsCeMois = 0;
        presentsAujourdhui = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      activeRoute: '/',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Tableau de bord',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Bienvenue ! Voici ce qui se passe aujourd\'hui',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            StatusCards(
              totalEnfants: totalEnfants,
              inscriptionsCeMois: inscriptionsCeMois,
              presentsAujourdhui: presentsAujourdhui,
            ),
            const SizedBox(height: 24),
            const Text(
              'Activité / Planning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: WeeklyPlannerMini(
                      selectedClass: selectedClass,
                      classes: classes,
                      allActivities: allActivities,
                      onClassChanged: (newClass) {
                        setState(() {
                          selectedClass = newClass;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actions rapides',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.4,
                              children: [
                                _QuickActionCard(
                                  icon: Icons.person_add_alt_1_rounded,
                                  label: 'Ajouter un enfant',
                                  color: const Color(0xFF3B82F6),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => EnfantProfilScreen(
                                        enfant: emptyEnfant,
                                      ),
                                    ),
                                  ),
                                ),
                                _QuickActionCard(
                                  icon: Icons.how_to_reg_rounded,
                                  label: 'Marquer présence',
                                  color: const Color(0xFF10B981),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PresenceScreen(),
                                    ),
                                  ),
                                ),
                                if (currentUser?.isAdmin == true) ...[
                                  _QuickActionCard(
                                    icon: Icons.add_card_rounded,
                                    label: 'Ajouter un paiement',
                                    color: const Color(0xFF0EA5E9),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SuiviPaiementsScreen(),
                                      ),
                                    ),
                                  ),
                                  _QuickActionCard(
                                    icon: Icons.receipt_long_rounded,
                                    label: 'Ajouter une dépense',
                                    color: const Color(0xFFF59E0B),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const DepensesScreen(),
                                      ),
                                    ),
                                  ),
                                  _QuickActionCard(
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Voir les statistiques',
                                    color: const Color(0xFF8B5CF6),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const StatisticsScreen(),
                                      ),
                                    ),
                                  ),
                                ],
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.30),
              width: 1.4,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeeklyPlannerMini extends StatefulWidget {
  final String? selectedClass;
  final List<String> classes;
  final List<Activity> allActivities;
  final ValueChanged<String?> onClassChanged;

  const WeeklyPlannerMini({
    required this.selectedClass,
    required this.classes,
    required this.allActivities,
    required this.onClassChanged,
    super.key,
  });

  @override
  State<WeeklyPlannerMini> createState() => _WeeklyPlannerMiniState();
}

class _WeeklyPlannerMiniState extends State<WeeklyPlannerMini> {
  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  final Map<String, Color> activityColors = const {
    'Jeux': Color(0xFF3B82F6),
    'Lecture': Color(0xFF10B981),
    'Sport': Color(0xFFEF4444),
    'Art': Color(0xFF8B5CF6),
    'Musique': Color(0xFFF59E0B),
  };

  static const TimeOfDay startHour = TimeOfDay(hour: 8, minute: 0);
  static const int numberOfRows = 9;

  String _formatDay(DateTime date) =>
      DateFormat('EEE d MMM yyyy', 'fr_FR').format(date);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double timeColWidth = 60.0;
            final int numClasses = widget.classes.length;
            final double colWidth = numClasses > 0
                ? ((constraints.maxWidth - timeColWidth) / numClasses).clamp(
                    120.0,
                    double.infinity,
                  )
                : 120.0;

            return Column(
              children: [
                _buildDayNavigationBar(),
                _buildHeaderRow(timeColWidth, colWidth),
                Expanded(child: _buildPlannerBody(timeColWidth, colWidth)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayNavigationBar() {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4FF),
        border: Border(bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Jour précédent',
            onPressed: () => setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            }),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null && mounted) {
                  setState(
                    () => selectedDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                    ),
                  );
                }
              },
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDay(selectedDate),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Jour suivant',
            onPressed: () => setState(() {
              selectedDate = selectedDate.add(const Duration(days: 1));
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(double timeColWidth, double colWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            width: timeColWidth,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FF),
              border: Border(
                right: BorderSide(color: Color(0xFFD1D5DB), width: 1),
                bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1),
              ),
            ),
            child: const Text(
              'Time',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          ...widget.classes.map(
            (cls) => Container(
              width: colWidth,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4FF),
                border: Border(
                  right: BorderSide(color: Color(0xFFD1D5DB), width: 1),
                  bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1),
                ),
              ),
              child: Text(
                cls,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerBody(double timeColWidth, double colWidth) {
    return LayoutBuilder(
      builder: (context, bodyConstraints) {
        final double availableHeight = bodyConstraints.maxHeight;
        const double minHourHeight = 60.0;
        final double dynamicHourHeight =
            availableHeight > minHourHeight * numberOfRows
            ? availableHeight / numberOfRows
            : minHourHeight;
        final double dynamicTotalHeight = dynamicHourHeight * numberOfRows;

        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(timeColWidth, dynamicHourHeight),
                ...List.generate(widget.classes.length, (idx) {
                  final cls = widget.classes[idx];
                  return _buildClassColumn(
                    cls,
                    colWidth,
                    dynamicTotalHeight,
                    dynamicHourHeight,
                    idx.isEven,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(double timeColWidth, double dynamicHourHeight) {
    return Column(
      children: List.generate(numberOfRows, (i) {
        final hour = startHour.hour + i;
        final label = hour < 12
            ? '$hour:00 AM'
            : hour == 12
            ? '12:00 PM'
            : '${hour - 12}:00 PM';
        return Container(
          width: timeColWidth,
          height: dynamicHourHeight,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            border: Border(
              right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClassColumn(
    String cls,
    double colWidth,
    double dynamicTotalHeight,
    double dynamicHourHeight,
    bool isEven,
  ) {
    final activities =
        widget.allActivities
            .where(
              (a) =>
                  a.className == cls &&
                  a.date.year == selectedDate.year &&
                  a.date.month == selectedDate.month &&
                  a.date.day == selectedDate.day,
            )
            .toList()
          ..sort(
            (a, b) =>
                (a.start.hour * 60 + a.start.minute) -
                (b.start.hour * 60 + b.start.minute),
          );

    final colBg = isEven ? Colors.white : const Color(0xFFF9FAFB);

    return Container(
      width: colWidth,
      height: dynamicTotalHeight,
      decoration: BoxDecoration(
        color: colBg,
        border: const Border(
          right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Stack(
        children: [
          ...List.generate(
            numberOfRows,
            (i) => Positioned(
              top: i * dynamicHourHeight,
              left: 0,
              right: 0,
              child: Container(height: 1, color: const Color(0xFFE5E7EB)),
            ),
          ),
          ...activities.map((activity) {
            final totalMinutes =
                (activity.start.hour - startHour.hour) * 60 +
                activity.start.minute;
            final durationMinutes =
                (activity.end.hour - activity.start.hour) * 60 +
                (activity.end.minute - activity.start.minute);
            double top = (totalMinutes / 60.0) * dynamicHourHeight;
            double height = (durationMinutes / 60.0) * dynamicHourHeight;
            top = top.clamp(0.0, dynamicTotalHeight - 20);
            if (top + height > dynamicTotalHeight) {
              height = dynamicTotalHeight - top;
            }
            if (height < 20) {
              height = 20;
            }

            final color =
                activityColors[activity.title] ?? const Color(0xFF6366F1);

            return Positioned(
              top: top,
              left: 3,
              right: 3,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border(left: BorderSide(color: color, width: 3)),
                ),
                padding: const EdgeInsets.only(left: 5, top: 2, right: 3),
                child: Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class StatusCards extends StatelessWidget {
  final int totalEnfants;
  final int inscriptionsCeMois;
  final int presentsAujourdhui;

  const StatusCards({
    required this.totalEnfants,
    required this.inscriptionsCeMois,
    required this.presentsAujourdhui,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double attendancePct = totalEnfants > 0
        ? (presentsAujourdhui / totalEnfants * 100)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: StatusCard(
            title: 'Total Enfants',
            mainValue: '$totalEnfants',
            subtitle: '+$inscriptionsCeMois ce mois',
            icon: Icons.people_alt_outlined,
            iconColor: const Color(0xFF3B82F6),
            subtitleColor: const Color(0xFF3B82F6),
          ),
        ),
        Expanded(
          child: StatusCard(
            title: 'Présents Aujourd\'hui',
            mainValue: '$presentsAujourdhui',
            subtitle: '${attendancePct.toStringAsFixed(0)}% de présence',
            icon: Icons.how_to_reg_outlined,
            iconColor: const Color(0xFF10B981),
            subtitleColor: const Color(0xFF10B981),
          ),
        ),
        Expanded(
          child: StatusCard(
            title: 'Nouvelles Inscriptions',
            mainValue: '$inscriptionsCeMois',
            subtitle: 'Ce mois',
            icon: Icons.person_add_alt_1,
            iconColor: const Color(0xFFF59E0B),
            subtitleColor: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String subtitle;
  final Color iconColor;
  final Color subtitleColor;
  final IconData icon;

  const StatusCard({
    required this.title,
    required this.mainValue,
    required this.subtitle,
    required this.iconColor,
    required this.subtitleColor,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mainValue,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ],
      ),
    );
  }
}
