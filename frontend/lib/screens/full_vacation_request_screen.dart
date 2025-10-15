import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class VacationRequest {
  int id;
  DateTime startDate;
  DateTime endDate;
  String status; // Pending / Approved / Rejected
  String? reason;

  VacationRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reason,
  });
}

class VacationRequestScreen extends StatefulWidget {
  const VacationRequestScreen({Key? key}) : super(key: key);

  @override
  State<VacationRequestScreen> createState() => _VacationRequestScreenState();
}

class _VacationRequestScreenState extends State<VacationRequestScreen> {
  // Dummy data for testing
  List<VacationRequest> myRequests = [
    VacationRequest(
        id: 1,
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        status: 'Approved',
        reason: 'Family trip'),
    VacationRequest(
        id: 2,
        startDate: DateTime.now().add(const Duration(days: 6)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        status: 'Pending'),
  ];

  DateTime? selectedStart;
  DateTime? selectedEnd;
  TextEditingController reasonController = TextEditingController();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  // Get colors for calendar
  Color _getDayColor(DateTime day) {
    for (var req in myRequests) {
      if (!day.isBefore(req.startDate) && !day.isAfter(req.endDate)) {
        switch (req.status) {
          case 'Approved':
            return Colors.green.withOpacity(0.5);
          case 'Pending':
            return Colors.orange.withOpacity(0.5);
          case 'Rejected':
            return Colors.red.withOpacity(0.5);
        }
      }
    }
    return Colors.transparent;
  }

  Future<void> pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStart ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedStart = picked);
  }

  Future<void> pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEnd ?? selectedStart ?? DateTime.now(),
      firstDate: selectedStart ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedEnd = picked);
  }

  void submitRequest() {
    if (selectedStart == null || selectedEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select both dates")));
      return;
    }
    if (selectedEnd!.isBefore(selectedStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("End date cannot be before start date")));
      return;
    }
    // Check conflict with existing requests
    for (var req in myRequests) {
      if (!selectedEnd!.isBefore(req.startDate) &&
          !selectedStart!.isAfter(req.endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selected dates conflict with existing requests")));
        return;
      }
    }

    setState(() {
      myRequests.add(VacationRequest(
        id: myRequests.length + 1,
        startDate: selectedStart!,
        endDate: selectedEnd!,
        status: 'Pending',
        reason: reasonController.text,
      ));
      selectedStart = null;
      selectedEnd = null;
      reasonController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vacation request submitted")));
  }

  void deleteRequest(VacationRequest req) {
    setState(() {
      myRequests.remove(req);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vacation Requests")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ------------------- Calendar -------------------
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return Container(
                    decoration: BoxDecoration(
                      color: _getDayColor(day),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    margin: const EdgeInsets.all(4),
                    child: Center(child: Text('${day.day}')),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ------------------- Add Request -------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickStartDate,
                    child: Text(selectedStart == null
                        ? "Pick Start Date"
                        : DateFormat.yMd().format(selectedStart!)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickEndDate,
                    child: Text(selectedEnd == null
                        ? "Pick End Date"
                        : DateFormat.yMd().format(selectedEnd!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                  labelText: "Reason (optional)", border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitRequest,
              child: const Text("Submit Request"),
            ),

            const SizedBox(height: 20),

            // ------------------- My Requests -------------------
            const Text("My Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...myRequests.map((req) {
              return Card(
                child: ListTile(
                  title: Text(
                      "${DateFormat.yMd().format(req.startDate)} - ${DateFormat.yMd().format(req.endDate)}"),
                  subtitle: Text("${req.status}${req.reason != null ? ' | ${req.reason}' : ''}"),
                  trailing: req.status == 'Pending'
                      ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteRequest(req),
                  )
                      : null,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
