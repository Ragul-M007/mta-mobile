import 'package:flutter/material.dart';
import 'package:mta/utilities/drawer/drawer_menu_item.dart';
import 'package:mta/utilities/drawer/drawer_state_controller.dart';

class CustomSideDrawer extends StatelessWidget {
  const CustomSideDrawer({
    super.key,
    required this.companyName,
    required this.logoAssetPath,
    required this.menuEntries,
    required this.selectedMenuId,
    required this.onMenuTap,
  });

  final String companyName;
  final String logoAssetPath;
  final List<DrawerMenuEntry> menuEntries;
  final int selectedMenuId;
  final ValueChanged<DrawerMenuEntry> onMenuTap;

  static const Color _drawerBlue = Color(0xFF005EAE);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.78,
        child: Container(
          color: _drawerBlue,
          child: Stack(
            children: [
              const Positioned.fill(child: _DrawerBottomWaves()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DrawerHeader(
                        logoAssetPath: logoAssetPath,
                        companyName: companyName,
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: menuEntries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final menuEntry = menuEntries[index];
                            return DrawerMenuItem(
                              title: menuEntry.title,
                              isSelected: selectedMenuId == menuEntry.id,
                              onTap: () => onMenuTap(menuEntry),
                            );
                          },
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
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.logoAssetPath, required this.companyName});

  final String logoAssetPath;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 18, 0),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFFFFF),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: Image.asset(
                logoAssetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              companyName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerBottomWaves extends StatelessWidget {
  const _DrawerBottomWaves();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -180,
            right: -220,
            bottom: -230,
            child: Container(
              height: 480,
              decoration: BoxDecoration(
                color: const Color(0xFF2A74B7).withOpacity(0.92),
                borderRadius: BorderRadius.circular(340),
              ),
            ),
          ),
          Positioned(
            left: -130,
            right: -260,
            bottom: -300,
            child: Container(
              height: 470,
              decoration: BoxDecoration(
                color: const Color(0xFF3D89CA).withOpacity(0.72),
                borderRadius: BorderRadius.circular(340),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

