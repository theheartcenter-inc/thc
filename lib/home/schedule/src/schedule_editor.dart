import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/home/users/src/all_users.dart';
import 'package:thc/the_good_stuff.dart';

class ScheduleEditor extends StatefulWidget {
  const ScheduleEditor({super.key});

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _event = TextEditingController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();
  final TextEditingController _startTime = TextEditingController();
  final TextEditingController _endTime = TextEditingController();

  Director? director;

  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  final eventsCollection = FirebaseFirestore.instance.collection('scheduled_streams');

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      addEvent();
      navigator.snackbarMessage('${_event.text} event added!');
    }
  }

  void addEvent() {
    final newEvent = {
      'title': _event.text,
      'startDate': _startDate.text,
      'endDate': _endDate.text,
      'startTime': _startTime.text,
      'endTime': _endTime.text,
      'directorId': director?.firestoreId ?? '',
    };

    eventsCollection.add(newEvent).then((value) {
      // Handle success
      backendPrint('Event added successfully');
      fetchEvents(); // Refresh events after adding
    }).catchError((error) {
      // Handle error
      backendPrint('Failed to add event: $error');
    });
  }

  Future<void> fetchEvents() async {
    try {
      final snapshot = await eventsCollection.get();
      final events = snapshot.docs.map((doc) => doc.data()).toList();

      // Update local _events map
      setState(() {
        _events = {};
        for (var event in events) {
          final eventDate = DateFormat('yyyy-MM-dd').parse(event['startDate']);
          if (_events[eventDate] == null) {
            _events[eventDate] = [];
          }
          _events[eventDate]!.add(event);
        }
      });
    } catch (e) {
      backendPrint('Failed to fetch events: $e');
    }
  }

  void updateEvent(String eventId, Map<String, dynamic> updatedEvent) {
    eventsCollection.doc(eventId).update(updatedEvent).then((value) {
      backendPrint('Event updated successfully');
      fetchEvents();
    }).catchError((error) {
      backendPrint('Failed to update event: $error');
    });
  }

  void deleteEvent(String eventId) {
    eventsCollection.doc(eventId).delete().then((value) {
      // Handle success
      backendPrint('Event deleted successfully');
      fetchEvents(); // Refresh events after deleting
    }).catchError((error) {
      // Handle error
      backendPrint('Failed to delete event: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final formContents = <Widget>[
      DirectorDropdown(
        onSaved: (value) => setState(() => director = value),
        validator: (value) => value == null ? '[error message]' : null,
      ),
      TextFormField(
        controller: _event,
        decoration: const InputDecoration(labelText: 'Event Title'),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter the event title.';
          }
          return null;
        },
      ),
      TextFormField(
        controller: _startDate,
        decoration: const InputDecoration(
          labelText: 'Start Date',
          icon: Icon(Icons.calendar_today_rounded),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter the event start date.';
          }
          return null;
        },
        onTap: () async {
          final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2035));

          if (picked != null) {
            setState(() {
              _startDate.text = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        },
      ),
      TextFormField(
        controller: _endDate,
        decoration: const InputDecoration(
          labelText: 'End Date',
          icon: Icon(Icons.calendar_today_rounded),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter the event end date.';
          }
          return null;
        },
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime(2035),
          );

          if (picked != null) {
            setState(() {
              _endDate.text = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        },
      ),
      TextFormField(
        controller: _startTime,
        decoration: const InputDecoration(
          labelText: 'Start Time',
          icon: Icon(Icons.access_time_rounded),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter the event start time.';
          }
          return null;
        },
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (picked != null) {
            setState(() {
              _startTime.text = picked.format(context);
            });
          }
        },
      ),
      TextFormField(
        controller: _endTime,
        decoration: const InputDecoration(
          labelText: 'End Time',
          icon: Icon(Icons.access_time_sharp),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter the event end time.';
          }
          return null;
        },
        onTap: () async {
          final TimeOfDay? picked =
              await showTimePicker(context: context, initialTime: TimeOfDay.now());

          if (picked != null) {
            setState(() {
              _endTime.text = picked.format(context);
            });
          }
        },
      ),
      const SizedBox(height: 20.0),
      ElevatedButton(
        onPressed: submit,
        child: const Text('Submit'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Create Event Form')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(children: formContents),
            ),
            const SizedBox(height: 20.0),
            TableCalendar(
              firstDay: DateTime.utc(2023),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // Update focused day for controlled calendar
                });
              },
              eventLoader: (day) {
                // Return events for the selected day from _events map
                return _events[day] ?? [];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DirectorDropdown extends FormField<Director> {
  DirectorDropdown({
    super.key,
    super.autovalidateMode,
    super.initialValue,
    super.onSaved,
    super.validator,
  }) : super(
          restorationId: 'director dropdown',
          builder: (field) {
            final options = [
              for (final user in ThcUsers.of(field.context))
                if (user is Director)
                  DropdownMenuEntry(
                    value: user,
                    label: '${user.name} (${user.firestoreId})',
                    labelWidget: Text(user.name),
                    trailingIcon: Text(
                      user.firestoreId,
                      style: TextStyle(
                        size: 12,
                        color: ThcColors.of(field.context).onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
            ];

            return DropdownMenu(
              label: const Text('Director name'),
              dropdownMenuEntries: options,
              expandedInsets: EdgeInsets.zero,
              enableFilter: true,
              onSelected: onSaved,
              errorText: field.errorText,
            );
          },
        );
}
