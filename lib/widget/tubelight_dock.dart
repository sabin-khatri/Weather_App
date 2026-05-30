import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mmamc/service/translation_service.dart';

class TubelightDock extends StatelessWidget {
  final VoidCallback? onMapPressed;
  final VoidCallback? onFavoritePressed;
  final VoidCallback onLocationPressed;
  final VoidCallback onHistoryPressed;
  final VoidCallback onSettingsPressed;
  final bool isFavorite;
  final bool isLocationLoading;
  final bool hasWeather;

  const TubelightDock({
    super.key,
    required this.onMapPressed,
    required this.onFavoritePressed,
    required this.onLocationPressed,
    required this.onHistoryPressed,
    required this.onSettingsPressed,
    required this.isFavorite,
    required this.isLocationLoading,
    required this.hasWeather,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 400;
    final itemSize = isCompact ? 48.0 : 54.0;
    final horizontalPad = isCompact ? 8.0 : 12.0;
    final verticalPad = isCompact ? 6.0 : 8.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isCompact ? 28 : 32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: verticalPad,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DockItem(
                icon: Icons.map,
                label: TranslationService.get('map'),
                glowColor: const Color(0xFF00FFCC),
                onTap: onMapPressed,
                isEnabled: hasWeather,
                size: itemSize,
              ),
              _DockItem(
                icon: isFavorite ? Icons.star : Icons.star_border,
                label: TranslationService.get('favorite'),
                glowColor:
                    isFavorite ? Colors.amber : const Color(0xFFFFCC00),
                onTap: onFavoritePressed,
                isEnabled: hasWeather,
                isActive: isFavorite,
                size: itemSize,
              ),
              _DockItem(
                icon: Icons.my_location,
                label: TranslationService.get('myLocation'),
                glowColor: const Color(0xFF33CCFF),
                onTap: onLocationPressed,
                isLoading: isLocationLoading,
                size: itemSize,
              ),
              _DockItem(
                icon: Icons.history,
                label: TranslationService.get('history'),
                glowColor: const Color(0xFFCC33FF),
                onTap: onHistoryPressed,
                size: itemSize,
              ),
              _DockItem(
                icon: Icons.settings,
                label: TranslationService.get('settings'),
                glowColor: const Color(0xFFFFFFFF),
                onTap: onSettingsPressed,
                size: itemSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color glowColor;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isActive;
  final bool isLoading;
  final double size;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.glowColor,
    required this.onTap,
    this.isEnabled = true,
    this.isActive = false,
    this.isLoading = false,
    this.size = 54,
  });

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  bool _isHovered = false;

  void _handleTap() {
    if (!widget.isEnabled || widget.isLoading || widget.onTap == null) return;
    HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = _isHovered || widget.isActive || widget.isLoading;
    final Color currentColor = widget.isEnabled 
        ? (isHighlighted ? widget.glowColor : Colors.white70) 
        : Colors.white24;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Tooltip(
        message: widget.label,
        preferBelow: false,
        verticalOffset: 28,
        waitDuration: Duration.zero,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.glowColor.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        child: GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top Tubelight Glow Line
                Positioned(
                  top: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: isHighlighted && widget.isEnabled ? 22.0 : 0.0,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: widget.glowColor,
                      borderRadius: BorderRadius.circular(1.5),
                      boxShadow: [
                        BoxShadow(
                          color: widget.glowColor.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Downward cascading light beam gradient
                Positioned.fill(
                  top: 3,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isHighlighted && widget.isEnabled ? 0.35 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            widget.glowColor.withOpacity(0.6),
                            widget.glowColor.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          center: Alignment.topCenter,
                          radius: 0.7,
                        ),
                      ),
                    ),
                  ),
                ),

                // Icon / Loading Widget
                Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: widget.glowColor,
                            strokeWidth: 2,
                          ),
                        )
                      : AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: _isHovered && widget.isEnabled ? 1.22 : 1.0,
                          child: Icon(
                            widget.icon,
                            color: currentColor,
                            size: widget.size * 0.46,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
