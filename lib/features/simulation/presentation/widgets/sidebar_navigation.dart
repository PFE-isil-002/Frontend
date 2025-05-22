import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SidebarNavigation extends StatelessWidget {
  final String username;
  final void Function(String page) onItemSelected;
  final String selectedPage;

  const SidebarNavigation({
    super.key,
    required this.username,
    required this.onItemSelected,
    required this.selectedPage,
  });

  bool get isDesktop => [
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      ].contains(defaultTargetPlatform);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF2A2A2A),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: const Color(0xFF1A1A1A),
            width: double.infinity,
            child: SvgPicture.asset('assets/images/xctrl.svg'),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E90FF).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E90FF), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E90FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'ADMINISTRATOR',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavItem(
            icon: 'assets/icons/home_icon.svg',
            label: 'Home',
            isSelected: selectedPage == 'Home',
            onTap: () => onItemSelected('Home'),
          ),
          _buildNavItem(
            icon: 'assets/icons/map_icon.svg',
            label: 'Simulation',
            isSelected: selectedPage == 'Map',
            onTap: () => onItemSelected('Map'),
          ),
          _buildNavItem(
            icon: 'assets/icons/live_icon.svg',
            label: 'Drone',
            isSelected: selectedPage == 'Drone',
            onTap: () => onItemSelected('Drone'),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return _HoverableTile(
      icon: icon,
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      isDesktop: isDesktop,
    );
  }
}

class _HoverableTile extends StatefulWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDesktop;

  const _HoverableTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDesktop,
  });

  @override
  State<_HoverableTile> createState() => _HoverableTileState();
}

class _HoverableTileState extends State<_HoverableTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSelected
        ? Colors.black26
        : _hovering && widget.isDesktop
            ? Colors.white10
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) {
        if (widget.isDesktop) setState(() => _hovering = true);
      },
      onExit: (_) {
        if (widget.isDesktop) setState(() => _hovering = false);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: SvgPicture.asset(widget.icon),
          title: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : Colors.white70,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
