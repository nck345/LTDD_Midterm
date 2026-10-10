/* 
 * MSSV: 102230299
 * Họ và tên: Nguyễn Chánh Khiêm
 * Lớp: 23T_DT3
 */

import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../widgets/contact_card.dart';
import '../widgets/category_filter_chips.dart';
import 'add_edit_contact_screen.dart';
import 'contact_detail_screen.dart';
import 'call_simulation_screen.dart';
import 'sms_dialog.dart';

class HomeScreen extends StatefulWidget {
  final ContactService service;

  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.service.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sắp xếp danh bạ theo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Tên từ A đến Z'),
                  trailing: widget.service.currentSort == SortOption.nameAsc
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    widget.service.setSortOption(SortOption.nameAsc);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Tên từ Z đến A'),
                  trailing: widget.service.currentSort == SortOption.nameDesc
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    widget.service.setSortOption(SortOption.nameDesc);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Mới thêm gần nhất'),
                  trailing: widget.service.currentSort == SortOption.newest
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    widget.service.setSortOption(SortOption.newest);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.contact_phone, color: Colors.blue),
            SizedBox(width: 10),
            Text('Danh Bạ Điện Thoại'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ứng Dụng Quản Lý Danh Bạ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('Phiên bản: 1.0.0'),
            SizedBox(height: 10),
            Text(
              'Ứng dụng hỗ trợ tìm kiếm nhanh, lọc theo nhóm, thêm/sửa/xóa liên hệ kèm hoàn tác, giả lập cuộc gọi và tin nhắn SMS.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDeleteContact(Contact contact) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa liên hệ'),
        content: Text('Bạn có chắc chắn muốn xóa "${contact.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('HỦY BỎ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }

  void _deleteAndShowUndo(Contact contact) async {
    final removed = await widget.service.deleteContact(contact.id);
    if (removed != null && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${removed.contact.name}"'),
          action: SnackBarAction(
            label: 'HOÀN TÁC',
            textColor: Colors.amberAccent,
            onPressed: () {
              widget.service.restoreContact(removed.contact, removed.index);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: widget.service,
      builder: (context, _) {
        final contacts = widget.service.filteredContacts;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Danh Bạ Điện Thoại',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              // Nút chuyển đổi Dark/Light mode (Câu 1.3)
              IconButton(
                tooltip: widget.service.isDarkMode ? 'Chế độ Sáng' : 'Chế độ Tối',
                icon: Icon(
                  widget.service.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: widget.service.isDarkMode ? Colors.amber : null,
                ),
                onPressed: () => widget.service.toggleTheme(),
              ),

              // Nút Sắp xếp danh bạ (Câu 2.5)
              IconButton(
                tooltip: 'Sắp xếp danh bạ',
                icon: const Icon(Icons.sort),
                onPressed: _showSortDialog,
              ),

              // Menu tùy chọn bổ sung
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) async {
                  if (val == 'reset') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Khôi phục danh bạ mẫu'),
                        content: const Text(
                          'Thao tác này sẽ đặt lại danh bạ về dữ liệu ban đầu phục vụ kiểm tra và chấm bài.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('HỦY'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('ĐỒNG Ý'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _searchController.clear();
                      await widget.service.resetToSampleData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã khôi phục danh bạ mẫu thành công!')),
                        );
                      }
                    }
                  } else if (val == 'about') {
                    _showAboutDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.blue, size: 20),
                        SizedBox(width: 10),
                        Text('Khôi phục danh bạ mẫu'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.teal, size: 20),
                        SizedBox(width: 10),
                        Text('Giới thiệu ứng dụng'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: widget.service.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Ô tìm kiếm Real-time (Câu 2.4)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Tìm theo tên, số điện thoại, email...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    // Thanh lọc theo Nhóm (Câu 2.5 Bộ lọc)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CategoryFilterChips(service: widget.service),
                      ),
                    ),

                    // Thanh thống kê số lượng (Câu 1.3 Giao diện bổ sung)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hiển thị: ${contacts.length} liên hệ'
                              '${widget.service.selectedCategory != "Tất cả" ? " (${widget.service.selectedCategory})" : ""}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                                const SizedBox(width: 4),
                                Text(
                                  'Yêu thích: ${widget.service.favoriteCount}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Danh sách liên hệ hoặc Empty State
                    if (contacts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchController.text.isNotEmpty
                                      ? Icons.search_off_rounded
                                      : Icons.contact_phone_outlined,
                                  size: 72,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Không tìm thấy liên hệ phù hợp!'
                                      : 'Danh bạ hiện đang trống',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Thử tìm với từ khóa khác hoặc xóa bộ lọc.'
                                      : 'Bấm nút (+) bên dưới để thêm liên hệ mới.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_searchController.text.isNotEmpty ||
                                    widget.service.selectedCategory != 'Tất cả')
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      widget.service.setCategory('Tất cả');
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Đặt lại tìm kiếm & bộ lọc'),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () => widget.service.resetToSampleData(),
                                    icon: const Icon(Icons.restore),
                                    label: const Text('Nạp lại dữ liệu mẫu'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 80),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final contact = contacts[index];
                              return ContactCard(
                                contact: contact,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ContactDetailScreen(
                                        contact: contact,
                                        service: widget.service,
                                      ),
                                    ),
                                  );
                                },
                                onCall: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CallSimulationScreen(contact: contact),
                                    ),
                                  );
                                },
                                onMessage: () {
                                  SmsDialog.show(context, contact);
                                },
                                onToggleFavorite: () {
                                  widget.service.toggleFavorite(contact.id);
                                },
                                onConfirmDismiss: () => _confirmDeleteContact(contact),
                                onDismissed: () => _deleteAndShowUndo(contact),
                              );
                            },
                            childCount: contacts.length,
                          ),
                        ),
                      ),
                  ],
                ),
          // Nút Floating Action Button: Thêm danh bạ mới (Câu 2.1)
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditContactScreen(
                    service: widget.service,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text(
              'Thêm liên hệ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
