/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/contact.dart';

class CallSimulationScreen extends StatefulWidget {
  final Contact contact;

  const CallSimulationScreen({super.key, required this.contact});

  @override
  State<CallSimulationScreen> createState() => _CallSimulationScreenState();
}

class _CallSimulationScreenState extends State<CallSimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  Timer? _callTimer;
  int _seconds = 0;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Giả lập kết nối sau 1.5 giây
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _seconds++;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Badge định danh tính năng bổ sung
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.phone_in_talk, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Câu 2.6: Giả lập Cuộc gọi thoại',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Tên và SĐT
            Text(
              widget.contact.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.contact.phone,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isConnected ? _formatDuration(_seconds) : 'Đang kết nối cuộc gọi...',
              style: TextStyle(
                color: _isConnected ? Colors.greenAccent : Colors.amberAccent,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            // Avatar với hiệu ứng sóng lan tỏa
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      widget.contact.avatarColor.withValues(alpha: 0.8),
                      widget.contact.avatarColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.contact.avatarColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.contact.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Các nút tiện ích cuộc gọi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallActionButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Đã tắt mic' : 'Tắt tiếng',
                    isActive: _isMuted,
                    onTap: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),
                  _CallActionButton(
                    icon: Icons.dialpad,
                    label: 'Bàn phím',
                    isActive: false,
                    onTap: () {},
                  ),
                  _CallActionButton(
                    icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                    label: _isSpeaker ? 'Loa ngoài: Bật' : 'Loa ngoài',
                    isActive: _isSpeaker,
                    onTap: () {
                      setState(() {
                        _isSpeaker = !_isSpeaker;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Nút kết thúc cuộc gọi
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black87 : Colors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
