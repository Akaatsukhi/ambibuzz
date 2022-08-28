import 'dart:async';
import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  static const String id = 'task_screen';
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Declare the list of textfield inside the the listview
  List<Widget> taskList = [];

  // controller to control the scroll position and text field
  late ScrollController _scrollController;
  late TextEditingController _editingController;

  // FocusNode help in shifting the focus from anywhere to textfield
  // Or any specific area were we want dimiss or request focus.
  late FocusNode myFocus;

  // Callback that report that underlying  value has changed and build
  // accordingly in 'ValuseListenableBuilder'.
  ValueChanged<String>? onSubmit;

  // Global key the uniquely identify the Form widget
  // and allow the validation of the form.
  final _formKey = GlobalKey<FormState>();

  // Declare a variable to keep track of the input text
  String _name = '';

  // Function to add the task to tasklist
  void addTask(String value) async {
    // Rebuild the widget when TaskList get updated.
    setState(() {
      taskList.add(TaskTile(taskItem: value));
    });

    // Add the smooth animation and auto scroll
    // the task list to the new task whenever user add any task.
    _scrollController.animateTo(_scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);

    // clear the text field after user add the task or press the sumbmit button.
    _editingController.clear();
  }

  void _submit() {
    // validate all the form fields
    final isValidForm = _formKey.currentState!.validate();
    if (isValidForm) {
      // on success, notify the parent widget
      addTask(_name);
    }
  }

  @override
  void initState() {
    super.initState();
    myFocus = FocusNode();
    _scrollController = ScrollController();
    _editingController = TextEditingController();
  }

  @override
  void dispose() {
    // clean up the focus node when form is dispose.
    myFocus.dispose();
    _scrollController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: taskList,
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _submit();
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                            autofocus: true,
                            focusNode: myFocus,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the task';
                              }
                              return null;
                            },
                            onChanged: (text) => setState(() => _name = text),
                            controller: _editingController,
                            onFieldSubmitted: (value) {
                              _submit();
                              myFocus.requestFocus();
                            }),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatefulWidget {
  const TaskTile({
    Key? key,
    required this.taskItem,
  }) : super(key: key);
  // Task item in which user type in form of string.
  final String taskItem;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  /// Timer object to track and timing functionlity in task.
  Timer? timer;

  /// State of counter.
  bool isRunning = false;

  /// Duration object help in  handling relationship between different unit of time
  /// such as minutes,hours,days and seconds etc.
  Duration duration = const Duration();

  /// Getter to obtain the string of Hour,minute and seconds.
  String get countText {
    String toDigit(int n) => n.toString().padLeft(2, '0');
    final hour = toDigit(duration.inHours);
    final minute = toDigit(duration.inMinutes.remainder(60));
    final seconds = toDigit(duration.inSeconds.remainder(60));

    // Handle the logic displaying minute,second,hour only when they are needed.
    if (duration.inMinutes > 0) {
      return '${minute}m : ${seconds}s';
    } else if (duration.inHours > 0) {
      return '${hour}h: ${minute}m : ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void startTimer() {
    isRunning = true;
    timer = Timer.periodic(
      const Duration(seconds: 1),
      ((timer) {
        setState(() {
          final seconds = duration.inSeconds + 1;
          duration = Duration(seconds: seconds);
        });
      }),
    );
  }

  void stopTimer() {
    timer!.cancel();
    isRunning = false;
  }

  /// Function to reset the timer when task is long pressed
  /// it reset the Duration to zero.
  void resetTimer() {
    timer!.cancel();
    isRunning = false;
    setState(() => duration = const Duration());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // This widget handle on tap -> start imer
        // and double tap  -> reset timer.
        // And the ripple effect to provide the sense of notion
        // when use click.
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onDoubleTap: (() => resetTimer()),
          onTap: () {
            if (isRunning) {
              stopTimer();
            } else {
              startTimer();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Widget to display text of task
                Expanded(
                  child: Text(
                    widget.taskItem,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                // Widget ensure then if timer is running then only
                // it will show the widget otherwise it will hide itels in widget tree.
                Visibility(
                  visible: isRunning,
                  child: Chip(
                    label: Text(
                      countText,
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
