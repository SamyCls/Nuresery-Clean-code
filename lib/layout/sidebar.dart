import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/screens/dashboard.dart';
import '/screens/enfant_screen.dart';
import '/screens/presence_screen.dart';
import '/screens/employe_page.dart';
import '/screens/planing_act.dart';
import '/screens/depenses.dart';
import '/screens/stats.dart';
import '/screens/suivipaie.dart';
import '/screens/settings.dart';
import '/app_state.dart';

class SidebarNavigationItem {
  final String label;
  final IconData icon;
  final String route;
  final bool isPaiement;

  const SidebarNavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.isPaiement = false,
  });
}

Widget _getPageFromRoute(String route) {
  switch (route) {
    case '/':
      return DashboardPage();
    case '/enfants':
      return ListeEnfantsPage();
    case '/presence':
      return PresenceScreen();
    case '/employes':
      return ListeEmployesPage();
    case '/activites':
      return WeeklyPlannerPage();
    case '/depenses':
      return const DepensesScreen();
    case '/paiements-enfant':
      return const SuiviPaiementsScreen();
    case '/statistiques':
      return const StatisticsScreen();
    case '/parametres':
      return ParametersScreen();
    default:
      return DashboardPage();
  }
}

class Sidebar extends StatefulWidget {
  final String activeRoute;
  const Sidebar({super.key, this.activeRoute = '/'});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _showPaiementSubmenu = false;

  List<SidebarNavigationItem> get _menuItems {
    if (currentUser == null) {
      return const [];
    }

    if (currentUser!.isAdmin) {
      return const [
        SidebarNavigationItem(
          label: 'Dashboard',
          icon: CupertinoIcons.home,
          route: '/',
        ),
        SidebarNavigationItem(
          label: 'Enfants',
          icon: CupertinoIcons.person_2,
          route: '/enfants',
        ),
        SidebarNavigationItem(
          label: 'Présence',
          icon: CupertinoIcons.checkmark_seal,
          route: '/presence',
        ),
        SidebarNavigationItem(
          label: 'Employés',
          icon: CupertinoIcons.person_crop_rectangle,
          route: '/employes',
        ),
        SidebarNavigationItem(
          label: 'Activités',
          icon: CupertinoIcons.calendar_today,
          route: '/activites',
        ),
        SidebarNavigationItem(
          label: 'Paiements',
          icon: CupertinoIcons.money_dollar,
          route: '/paiements',
          isPaiement: true,
        ),
        SidebarNavigationItem(
          label: 'Statistiques',
          icon: CupertinoIcons.chart_bar,
          route: '/statistiques',
        ),
        SidebarNavigationItem(
          label: 'Paramètres',
          icon: CupertinoIcons.settings,
          route: '/parametres',
        ),
      ];
    } else {
      return const [
        SidebarNavigationItem(
          label: 'Dashboard',
          icon: CupertinoIcons.home,
          route: '/',
        ),
        SidebarNavigationItem(
          label: 'Enfants',
          icon: CupertinoIcons.person_2,
          route: '/enfants',
        ),
        SidebarNavigationItem(
          label: 'Présence',
          icon: CupertinoIcons.checkmark_seal,
          route: '/presence',
        ),
        SidebarNavigationItem(
          label: 'Activités',
          icon: CupertinoIcons.calendar_today,
          route: '/activites',
        ),
      ];
    }
  }

  void _navigateToRoute(String route) {
    setState(() => currentSidebarRoute = route);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _getPageFromRoute(route),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToSubmenu(String route) {
    setState(() => currentSidebarRoute = route);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _getPageFromRoute(route)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFFEAF6FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildUserProfileHeader(),
          const SizedBox(height: 16),
          const Divider(
            color: Colors.black12,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          const SizedBox(height: 4),
          Expanded(child: _buildMenuItemsList()),
          const Divider(
            color: Colors.black26,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    final username = currentUser?.username ?? 'Inconnu';
    final avatarLetter = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final roleText = (currentUser?.isAdmin ?? false)
        ? 'Admin Panel'
        : 'Utilisateur';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF3B82F6),
            child: Text(
              avatarLetter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  roleText,
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsList() {
    return SingleChildScrollView(
      child: Column(
        children: _menuItems.map((item) {
          final isPaiementItem =
              item.isPaiement && (currentUser?.isAdmin ?? false);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: _SidebarItem(
                  icon: item.icon,
                  label: item.label,
                  isActive: currentSidebarRoute == item.route,
                  onTap: () {
                    if (isPaiementItem) {
                      setState(() {
                        _showPaiementSubmenu = !_showPaiementSubmenu;
                      });
                    } else {
                      _navigateToRoute(item.route);
                    }
                  },
                ),
              ),
              if (isPaiementItem)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showPaiementSubmenu
                      ? _buildPaiementSubmenu()
                      : const SizedBox.shrink(),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaiementSubmenu() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 32.0,
            right: 8,
            top: 2,
            bottom: 2,
          ),
          child: _SidebarItem(
            icon: CupertinoIcons.arrow_right,
            label: "Dépenses",
            isActive: currentSidebarRoute == '/depenses',
            onTap: () => _navigateToSubmenu('/depenses'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 32.0,
            right: 8,
            top: 2,
            bottom: 2,
          ),
          child: _SidebarItem(
            icon: CupertinoIcons.arrow_right,
            label: "Paiements Enfant",
            isActive: currentSidebarRoute == '/paiements-enfant',
            onTap: () => _navigateToSubmenu('/paiements-enfant'),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          currentUser = null;
          Navigator.of(context).pushReplacementNamed('/login');
        },
        icon: const Icon(CupertinoIcons.power),
        label: const Text(
          "Se déconnecter",
          style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 232, 232),
          foregroundColor: const Color.fromARGB(255, 231, 7, 7),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF3B82F6)
                : _isHovering
                ? Colors.blue[100]
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isActive ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isActive ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
