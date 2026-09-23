import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/restaurant_model.dart';

class BookingBottomSheetWidget extends StatefulWidget {
  final RestaurantModel restaurant;
  const BookingBottomSheetWidget({super.key, required this.restaurant});

  @override
  State<BookingBottomSheetWidget> createState() =>
      _BookingBottomSheetWidgetState();
}

class _BookingBottomSheetWidgetState extends State<BookingBottomSheetWidget> {
  int _guestCount = 2;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false;

  List<String> _getAvailableTimeSlots() {
    List<String> allSlots = [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
    ];
    DateTime now = DateTime.now();
    bool isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    if (isToday) {
      return allSlots.where((time) {
        int hour = int.parse(time.split(':')[0]);
        return hour > now.hour;
      }).toList();
    }
    return allSlots;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  Future<void> _submitBooking() async {
    setState(() => _isLoading = true);
    try {
      String dbDate =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('bookings').add({
        'restaurantId': widget.restaurant.id,
        'restaurantName': widget.restaurant.name,
        'date': dbDate,
        'time': _selectedTime,
        'guestCount': _guestCount,
        'status': 'confirmed',
        'userId': currentUser?.uid ?? 'unknown',
        'createdAt': FieldValue.serverTimestamp(),
        'userName':
            currentUser?.displayName ?? currentUser?.email ?? 'ไม่ระบุชื่อ',
        'userEmail': currentUser?.email,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('จองโต๊ะสำเร็จแล้ว!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayDate =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year + 543}';
    final availableTimeSlots = _getAvailableTimeSlots();
    final String dbSearchDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'รายละเอียดการจอง',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'จำนวนคน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_guestCount > 1) setState(() => _guestCount--);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: _guestCount > 1
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_guestCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _guestCount++),
                      icon: const Icon(Icons.add_circle_outline),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            const Text(
              'วันที่ต้องการจอง',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          displayDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'เปลี่ยน',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'เลือกรอบเวลา',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            availableTimeSlots.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ไม่มีรอบเวลาว่างสำหรับวันนี้แล้ว',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('restaurantId', isEqualTo: widget.restaurant.id)
                        .where('date', isEqualTo: dbSearchDate)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      Map<String, int> bookedSeatsPerSlot = {};
                      for (var doc in snapshot.data!.docs) {
                        String time = doc['time'];
                        int guests = doc['guestCount'] ?? 0;
                        bookedSeatsPerSlot[time] =
                            (bookedSeatsPerSlot[time] ?? 0) + guests;
                      }
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: availableTimeSlots.map((time) {
                          int booked = bookedSeatsPerSlot[time] ?? 0;
                          int remainingSeats =
                              widget.restaurant.capacityPerSlot - booked;
                          bool isNotEnoughSeats = _guestCount > remainingSeats;
                          bool isSelected = _selectedTime == time;
                          return ChoiceChip(
                            label: Column(
                              children: [
                                Text(time),
                                Text(
                                  remainingSeats > 0
                                      ? '(ว่าง $remainingSeats)'
                                      : '(เต็ม)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isNotEnoughSeats
                                        ? Colors.red[300]
                                        : (isSelected
                                              ? Colors.white70
                                              : Colors.green[600]),
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: isNotEnoughSeats
                                ? null
                                : (selected) {
                                    if (selected)
                                      setState(() => _selectedTime = time);
                                  },
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isNotEnoughSeats
                                  ? Colors.grey
                                  : (isSelected
                                        ? Colors.white
                                        : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.grey[100],
                            disabledColor: Colors.grey[200],
                            side: BorderSide.none,
                          );
                        }).toList(),
                      );
                    },
                  ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTime != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  foregroundColor: _selectedTime != null
                      ? Colors.white
                      : Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: (_selectedTime == null || _isLoading)
                    ? null
                    : _submitBooking,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'ยืนยันการจอง',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
