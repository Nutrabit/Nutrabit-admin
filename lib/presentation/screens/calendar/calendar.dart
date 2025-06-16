import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nutrabit_admin/core/models/event_type.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';
import 'package:nutrabit_admin/widgets/drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/models/calendar_event.dart';
import 'package:nutrabit_admin/presentation/providers/events_provider.dart';
import 'package:intl/intl.dart';

class Calendar extends ConsumerStatefulWidget {
  final String patientId;
  const Calendar({super.key, required this.patientId});

  @override
  ConsumerState<Calendar> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Widget _getEventTypeIcon(
    String typeName, {
    double size = 10.0,
    Color color = const Color(0xFFDC607A),
  }) {
    try {
      final type = EventType.values.firstWhere((t) => t.name == typeName);
      return FaIcon(type.iconData, size: size, color: type.iconColor);
    } catch (e) {
      return FaIcon(FontAwesomeIcons.circleQuestion, size: size, color: color);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    // Carga los eventos del paciente pasado por parámetro
    final eventsByDateAsync = ref.watch(eventsByDateProvider(widget.patientId));
    // Carga los datos del paciente
    final userAsync = ref.watch(userStreamProvider(widget.patientId));
    var screenHeight = MediaQuery.of(context).size.height;

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Scaffold(
            body: Center(child: Text('Error al cargar paciente: $e')),
          ),
      data: (snap) {
        final data = snap.data() as Map<String, dynamic>;
        final name = data['name'] as String? ?? '';
        final lastname = data['lastname'] as String? ?? '';
        final profilePic = data['profilePic'] as String?;

        // Se cargan los eventos del paciente
        return eventsByDateAsync.when(
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, _) =>
                  Scaffold(body: Center(child: Text('Error eventos: $e'))),
          data: (eventsByDate) {
            final selectedKey = DateTime(
              _selectedDay!.year,
              _selectedDay!.month,
              _selectedDay!.day,
            );
            final dayEvents = eventsByDate[selectedKey] ?? [];

            return Scaffold(
              appBar: AppBar(
                leading: BackButton(),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                actions: [
                  Builder(
                    builder:
                        (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFFEECDA),
              drawer: AppDrawer(),
              body: Column(
                children: [
                  //  Pasa name, lastname y profilePic al card
                  cardPatient(
                    name: name,
                    lastname: lastname,
                    profilePic: profilePic,
                  ),
                  const SizedBox(height: 8),
                  // VISTA DEL CALENDARIO
                  TableCalendar<Event>(
                    locale: 'es_ES',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) {
                      final normalized = DateTime(day.year, day.month, day.day);
                      return eventsByDate[normalized] ?? [];
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextFormatter: (date, locale) {
                        final raw = DateFormat(
                          'MMMM yyyy',
                          locale,
                        ).format(date);
                        return toBeginningOfSentenceCase(raw)!;
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFDC607A),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color.fromARGB(150, 220, 96, 123),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                        color: const Color(0xFFDC607A),
                      ),
                      weekendTextStyle: TextStyle(color: Colors.grey.shade600),
                      outsideTextStyle: TextStyle(color: Colors.grey.shade400),
                    ),

                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, isToday: true);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildDayCell(day, isSelected: true);
                      },
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return SizedBox.shrink();

                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                events.take(3).map((e) {
                                  final event = e;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 1.0,
                                    ),
                                    child: _getEventTypeIcon(
                                      event.type,
                                      size: screenHeight * 0.015,
                                    ),
                                  );
                                }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  // VISTA EVENTOS DEL DÍA
                  Expanded(
                    child:
                        dayEvents.isEmpty
                            ? const Center(
                              child: Text('No hay eventos este día'),
                            )
                            : ListView.builder(
                              itemCount: dayEvents.length,
                              itemBuilder: (context, i) {
                                final e = dayEvents[i];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFDC607A),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      context.pushNamed(
                                        'calendarDetail',
                                        pathParameters: {
                                          'id': widget.patientId,
                                        },
                                        extra: {
                                          'date': _selectedDay,
                                          'patientId': widget.patientId,
                                        },
                                      );
                                    },
                                    leading: _getEventTypeIcon(
                                      e.type,
                                      size: screenHeight * 0.02,
                                    ),
                                    title: Text(e.title),
                                    subtitle: Text(e.description),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                    ),
                                    textColor: const Color(0xFF000000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    Color bgColor = Colors.transparent;
    Color textColor = const Color(0xFFDC607A);

    if (isSelected) {
      bgColor = const Color(0xFFDC607A);
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = const Color.fromARGB(80, 220, 96, 123);
    }
    return GestureDetector(
      onDoubleTap: () {
        // Dirige a la pantalla de detalle
        // Pasa la fecha y el id del paciente
        context.pushNamed(
          'calendarDetail',
          pathParameters: {'id': widget.patientId},
          extra: {'date': day, 'patientId': widget.patientId},
        );
      },
      child: Container(
        width: 32,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class cardPatient extends StatelessWidget {
  final String name;
  final String lastname;
  final String? profilePic;

  const cardPatient({
    super.key,
    required this.name,
    required this.lastname,
    this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    final completeName =
        name.toString().capitalize() + ' ' + lastname.toString().capitalize();
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.2),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(251, 252, 250, 238),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 15),
                    CircleAvatar(
                      radius: 20,
                      //  Si el usuario tiene imagen, la carga
                      backgroundImage:
                          (profilePic != null && profilePic!.isNotEmpty)
                              ? NetworkImage(profilePic!)
                              : null,
                      // Si el usuario no tiene imagen, muestra un icono
                      backgroundColor: Colors.grey[400],
                      child:
                          (profilePic == null || profilePic!.isEmpty)
                              ? const Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Text(
                            completeName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
