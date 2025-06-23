import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nutrabit_admin/core/models/event_type.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:nutrabit_admin/presentation/providers/events_provider.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';
import 'package:nutrabit_admin/widgets/drawer.dart';

class Appointments extends ConsumerStatefulWidget {
  final String id;
  const Appointments({super.key, required this.id});

  @override
  ConsumerState<Appointments> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<Appointments> {
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(eventsStreamProvider(widget.id));
    final userAsync = ref.watch(userStreamProvider(widget.id));

    if (userAsync is AsyncLoading || allEvents is AsyncLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return allEvents.when(
      data: (events) {
        final appointmentEvents =
            events.where((e) => e.type == EventType.APPOINTMENT.name).toList();
        final nextAppointment =
            appointmentEvents
                .where((e) => e.date.isAfter(DateTime.now().toLocal()))
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date));
        final previousAppointments =
            appointmentEvents
                .where((e) => e.date.isBefore(DateTime.now().toLocal()))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          backgroundColor: Color.fromRGBO(253, 238, 219, 1),
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                context.pop();
              },
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
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
          endDrawer: AppDrawer(),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
              ),
              child:
                  appointmentEvents.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Este usuario no tiene turnos registrados en la App',
                              textAlign: TextAlign.center,
                              style: textStyle,
                            ),
                          ],
                        ),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          // if()
                          Center(
                            child: Text('Próximo turno', style: titleStyle),
                          ),
                          const SizedBox(height: 16),
                          if (nextAppointment.isNotEmpty)
                            ...nextAppointment.map((appt) {
                              return _AppointmentItem(date: appt.date);
                            }).toList(),
                          if (nextAppointment.isEmpty)
                            Text('No hay turnos registrados', style: textStyle),
                          const Divider(height: 40),
                          Center(
                            child: Text('Últimos turnos', style: titleStyle),
                          ),
                          const SizedBox(height: 16),
                          if (previousAppointments.isNotEmpty)
                            ...previousAppointments.map((appt) {
                              return _AppointmentItem(date: appt.date);
                            }).toList(),
                          if (previousAppointments.isEmpty)
                            Text('No hay turnos registrados', style: textStyle),
                        ],
                      ),
            ),
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) => Scaffold(
            body: Center(child: Text('Error al cargar turnos: $err')),
          ),
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final DateTime date;

  const _AppointmentItem({required this.date});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final formattedTime = DateFormat('HH:mm').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Fecha: $formattedDate', style: textStyle),
          Text('Hora: $formattedTime', style: textStyle),
        ],
      ),
    );
  }
}
