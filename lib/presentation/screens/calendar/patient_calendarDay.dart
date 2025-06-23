import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutrabit_admin/presentation/providers/events_provider.dart';
import 'package:nutrabit_admin/core/models/event_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nutrabit_admin/widgets/drawer.dart';

class CalendarDayPatient extends ConsumerWidget {
  final DateTime date;
  final String patientId;

  const CalendarDayPatient({
    required this.patientId,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = MediaQuery.of(context).size.width >= 700;

    return isWideScreen
        ? _WebCalendarDayView(ref: ref, date: date, patientId: patientId)
        : _MobileCalendarDayView(ref: ref, date: date, patientId: patientId);
  }
}

// ====================== MOBILE VIEW ======================
class _MobileCalendarDayView extends StatelessWidget {
  final WidgetRef ref;
  final DateTime date;
  final String patientId;

  const _MobileCalendarDayView({
    required this.ref,
    required this.date,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF4E9F7),
        backgroundColor: const Color(0xFFFEECDA),
      endDrawer: AppDrawer(),
      appBar: AppBar(
        leading: BackButton(),
        // backgroundColor: const Color(0xFFF4E9F7),
        backgroundColor: const Color(0xFFFEECDA),
        title: const Text("Día de calendario", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      body: _EventListContent(ref: ref, date: date, patientId: patientId, isWeb: false),
    );
  }
}

// ====================== WEB VIEW ======================
class _WebCalendarDayView extends StatelessWidget {
  final WidgetRef ref;
  final DateTime date;
  final String patientId;

  const _WebCalendarDayView({
    required this.ref,
    required this.date,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4E9F7),
        title: const Text("Eventos del Paciente"),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _EventListContent(ref: ref, date: date, patientId: patientId, isWeb: true),
        ),
      ),
    );
  }
}

// ====================== EVENT LIST SHARED CONTENT ======================
class _EventListContent extends StatelessWidget {
  final WidgetRef ref;
  final DateTime date;
  final String patientId;
  final bool isWeb;

  const _EventListContent({
    required this.ref,
    required this.date,
    required this.patientId,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final asyncEventsByDate = ref.watch(eventsByDateProvider(patientId));
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final selectedDate = DateTime(date.year, date.month, date.day);
    final horizontalPadding = isWeb ? 48.0 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isWeb ? 40 : 30),
          child: Align(
            alignment: isWeb ? Alignment.center : Alignment.centerLeft,
            child: Text(
              formattedDate,
              textAlign: isWeb ? TextAlign.center : TextAlign.start,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFDC607A),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(50),
                topRight: isWeb ? const Radius.circular(50) : Radius.zero,
              ),
            ),
            child: asyncEventsByDate.when(
              data: (eventsMap) {
                final events = eventsMap.entries
                    .where((entry) =>
                        entry.key.year == selectedDate.year &&
                        entry.key.month == selectedDate.month &&
                        entry.key.day == selectedDate.day)
                    .expand((entry) => entry.value)
                    .toList();

                if (events.isEmpty) {
                  return const Center(child: Text("No hay eventos para este día."));
                }

                return ListView.separated(
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (event.file.isNotEmpty && event.type != 'UPLOAD_FILE') ...[
                              _getEventTypeIcon(event.type, size: 28),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            if (event.file.isNotEmpty && event.type == 'UPLOAD_FILE')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    event.file,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image, size: 80),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              event.description,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getEventTypeIcon(String typeName, {double size = 28}) {
    try {
      final type = EventType.values.firstWhere((t) => t.name == typeName);
      return FaIcon(type.iconData, size: size, color: type.iconColor);
    } catch (_) {
      return FaIcon(FontAwesomeIcons.circleQuestion, size: size, color: const Color(0xFFDC607A));
    }
  }
}
