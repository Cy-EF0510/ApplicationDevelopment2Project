import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../constants/app_colors.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _titleController = TextEditingController();
  final _taskController = TextEditingController();
  final _titleFocus = FocusNode();
  final _taskFocus = FocusNode();

  String? _selectedCategory;
  String? _selectedTimeFrame;
  final List<String> _tasks = [];

  static const _timeFrames = ['2 weeks', '4 weeks', '6 weeks', '8 weeks'];

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
          _selectedCategory != null &&
          _selectedTimeFrame != null &&
          _tasks.isNotEmpty;

  @override
  void dispose() {
    _titleController.dispose();
    _taskController.dispose();
    _titleFocus.dispose();
    _taskFocus.dispose();
    super.dispose();
  }

  void _addTask() {
    final val = _taskController.text.trim();
    if (val.isEmpty) return;
    setState(() => _tasks.add(val));
    _taskController.clear();
    _taskFocus.requestFocus();
  }

  void _removeTask(int index) => setState(() => _tasks.removeAt(index));

  void _submit() {
    if (!_isValid) return;
    final goal = Goal(
      title: _titleController.text.trim(),
      category: categoryFor(_selectedCategory!),
      timeFrame: _selectedTimeFrame!,
      tasks: _tasks.map((t) => Task(title: t)).toList(),
    );
    Navigator.of(context).pop(goal);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 8),
            _buildSheetTitle(),
            const SizedBox(height: 20),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildCategoryPicker(),
            const SizedBox(height: 16),
            _buildTimeFramePicker(),
            const SizedBox(height: 16),
            _buildTasksSection(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: kPurple.withOpacity(0.27),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
  Widget _buildSheetTitle() {
    return const Text(
      'New goal',
      style: TextStyle(
        fontFamily: 'Syne',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Goal title'),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: Colors.white),
          decoration: _inputDecoration('e.g. Deadlift 120kg'),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Category'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: kCategories.map((cat) {
            final selected = _selectedCategory == cat.name;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = cat.name;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected ? kPurple.withOpacity(0.13) : kCardBg2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? kPurple : kPurple.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected
                            ? kPurpleLight
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeFramePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Time frame'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3.5,
          children: _timeFrames.map((tf) {
            final selected = _selectedTimeFrame == tf;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeFrame = tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected ? kPurple.withOpacity(0.13) : kCardBg2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? kPurple : kPurple.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    tf,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? kPurpleLight
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Tasks'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _taskController,
                focusNode: _taskFocus,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                decoration: _inputDecoration('Add a task...'),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _addTask(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addTask,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPurple.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPurple.withOpacity(0.27)),
                ),
                child: const Icon(Icons.add, color: kPurple, size: 20),
              ),
            ),
          ],
        ),
        if (_tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'No tasks yet — add at least one',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.13),
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: _tasks.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: kCardBg2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: kPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeTask(entry.key),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isValid ? 1.0 : 0.4,
        child: ElevatedButton(
          onPressed: _isValid ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPurple,
            disabledBackgroundColor: kPurple,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Add goal',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: kPurple.withOpacity(0.55),
        letterSpacing: 0.08 * 11,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.2),
      ),
      filled: true,
      fillColor: kCardBg2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kPurple.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kPurple.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kPurple.withOpacity(0.35)),
      ),
    );
  }
}