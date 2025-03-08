import 'package:flutter/material.dart';

class FeelingTodayScreen extends StatefulWidget {
  const FeelingTodayScreen({super.key});

  @override
  State<FeelingTodayScreen> createState() => _FeelingTodayScreenState();
}

class _FeelingTodayScreenState extends State<FeelingTodayScreen> {
  // Track selected items
  final Map<String, bool> _selectedMoods = {};
  final Map<String, bool> _selectedSymptoms = {};
  final Map<String, bool> _selectedDischarge = {};
  final Map<String, bool> _selectedOther = {};
  final Map<String, bool> _selectedPhysicalActivity = {};

  // Pill tracking
  bool _pillTakenOnTime = false;
  bool _yesterdaysPill = false;
  int _waterAmount = 0;
  final int _waterGoal = 72;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 253, 210, 234),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 216, 238),
        title: const Text(
          'Today',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25, // Optional: you can also increase the font size
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildMoodSection(),
            _buildSymptomsSection(),
            _buildDischargeSection(),
            _buildOtherSection(),
            _buildPhysicalActivitySection(),
            _buildContraceptivesSection(),
            _buildWaterTracking(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          style: const TextStyle(fontSize: 16),
          textAlignVertical: TextAlignVertical.center,
          onChanged: (value) {
            // This will auto-scroll to the first matching section
            if (value.isNotEmpty) {
              _autoScrollToFirstMatch(value.toLowerCase());
            }
          },
        ),
      ),
    );
  }

  // Function to auto-scroll to first matching section
  void _autoScrollToFirstMatch(String query) {
    // Implement scrolling logic based on query
    if (query.isEmpty) return;

    // Define sections and their content to check for matches
    final sections = [
      {'title': 'mood', 'items': _getMoods()},
      {'title': 'symptoms', 'items': _getSymptoms()},
      {'title': 'discharge', 'items': _getDischargeTypes()},
      {'title': 'other', 'items': _getOtherItems()},
      {'title': 'activity', 'items': _getPhysicalActivities()},
    ];

    // Find first section with matching items
    for (var section in sections) {
      List<Map<String, String>> items =
          section['items'] as List<Map<String, String>>;
      bool hasMatch = items.any(
        (item) => item['text']!.toLowerCase().contains(query),
      );

      if (hasMatch) {
        // Scroll to this section - in a real app, you'd use a ScrollController
        // Since we don't have specific positions, we'll leave implementing
        // the exact scrolling mechanism for your ScrollController setup
        break;
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper methods to get all option lists
  List<Map<String, String>> _getMoods() {
    return [
      {'emoji': '😌', 'text': 'Calm'},
      {'emoji': '😊', 'text': 'Happy'},
      {'emoji': '⚡', 'text': 'Energetic'},
      {'emoji': '😜', 'text': 'Frisky'},
      {'emoji': '😕', 'text': 'Mood swings'},
      {'emoji': '😠', 'text': 'Irritated'},
      {'emoji': '😢', 'text': 'Sad'},
      {'emoji': '😰', 'text': 'Anxious'},
      {'emoji': '😔', 'text': 'Depressed'},
      {'emoji': '😞', 'text': 'Feeling guilty'},
      {'emoji': '🤔', 'text': 'Obsessive thoughts'},
      {'emoji': '😴', 'text': 'Low energy'},
      {'emoji': '😐', 'text': 'Apathetic'},
      {'emoji': '😵', 'text': 'Confused'},
      {'emoji': '😖', 'text': 'Very self-critical'},
    ];
  }

  Widget _buildMoodSection() {
    final allMoods = _getMoods();

    // Filter moods based on search
    final moods =
        _searchQuery.isEmpty
            ? allMoods
            : allMoods
                .where(
                  (mood) => mood['text']!.toLowerCase().contains(_searchQuery),
                )
                .toList();

    return _buildSelectionSection(
      title: 'Mood',
      items: moods,
      backgroundColor: const Color(0xFFFFF3E0),
      selectedItems: _selectedMoods,
      iconColor: Colors.orange,
    );
  }

  List<Map<String, String>> _getSymptoms() {
    return [
      {'emoji': '👍', 'text': 'Everything is fine'},
      {'emoji': '🔴', 'text': 'Cramps'},
      {'emoji': '🤕', 'text': 'Tender breasts'},
      {'emoji': '🤯', 'text': 'Headache'},
      {'emoji': '🥴', 'text': 'Acne'},
      {'emoji': '🔄', 'text': 'Backache'},
      {'emoji': '🔋', 'text': 'Fatigue'},
      {'emoji': '🍫', 'text': 'Cravings'},
      {'emoji': '💤', 'text': 'Insomnia'},
      {'emoji': '🩸', 'text': 'Abdominal pain'},
      {'emoji': '🔍', 'text': 'Vaginal itching'},
      {'emoji': '💧', 'text': 'Vaginal dryness'},
    ];
  }

  Widget _buildSymptomsSection() {
    final allSymptoms = _getSymptoms();

    // Filter symptoms based on search
    final symptoms =
        _searchQuery.isEmpty
            ? allSymptoms
            : allSymptoms
                .where(
                  (symptom) =>
                      symptom['text']!.toLowerCase().contains(_searchQuery),
                )
                .toList();

    return _buildSelectionSection(
      title: 'Symptoms',
      items: symptoms,
      backgroundColor: const Color(0xFFF8BBD0).withOpacity(0.3),
      selectedItems: _selectedSymptoms,
      iconColor: Colors.pink,
    );
  }

  List<Map<String, String>> _getDischargeTypes() {
    return [
      {'emoji': '❌', 'text': 'No discharge'},
      {'emoji': '🥛', 'text': 'Creamy'},
      {'emoji': '💧', 'text': 'Watery'},
      {'emoji': '🍯', 'text': 'Sticky'},
      {'emoji': '🥚', 'text': 'Egg white'},
      {'emoji': '🩸', 'text': 'Spotting'},
    ];
  }

  Widget _buildDischargeSection() {
    final allDischargeTypes = _getDischargeTypes();

    // Filter discharge types based on search
    final dischargeTypes =
        _searchQuery.isEmpty
            ? allDischargeTypes
            : allDischargeTypes
                .where(
                  (type) => type['text']!.toLowerCase().contains(_searchQuery),
                )
                .toList();

    return _buildSelectionSection(
      title: 'Vaginal discharge',
      items: dischargeTypes,
      backgroundColor: const Color(0xFFE1BEE7).withOpacity(0.3),
      selectedItems: _selectedDischarge,
      iconColor: Colors.purple,
    );
  }

  List<Map<String, String>> _getOtherItems() {
    return [
      {'emoji': '📍', 'text': 'Travel'},
      {'emoji': '⚡', 'text': 'Stress'},
      {'emoji': '🧘', 'text': 'Meditation'},
      {'emoji': '📖', 'text': 'Journaling'},
      {'emoji': '💪', 'text': 'Kegel exercises'},
      {'emoji': '🧘', 'text': 'Breathing exercises'},
      {'emoji': '🩹', 'text': 'Disease or injury'},
      {'emoji': '🍷', 'text': 'Alcohol'},
    ];
  }

  Widget _buildOtherSection() {
    final allOtherItems = _getOtherItems();

    // Filter other items based on search
    final otherItems =
        _searchQuery.isEmpty
            ? allOtherItems
            : allOtherItems
                .where(
                  (item) => item['text']!.toLowerCase().contains(_searchQuery),
                )
                .toList();

    return _buildSelectionSection(
      title: 'Other',
      items: otherItems,
      backgroundColor: const Color(0xFFFFE0B2),
      selectedItems: _selectedOther,
      iconColor: Colors.orange,
    );
  }

  List<Map<String, String>> _getPhysicalActivities() {
    return [
      {'emoji': '🚫', 'text': 'Didn\'t exercise'},
      {'emoji': '🧘', 'text': 'Yoga'},
      {'emoji': '🏋️', 'text': 'Gym'},
      {'emoji': '🎵', 'text': 'Aerobics & dancing'},
      {'emoji': '🏊', 'text': 'Swimming'},
      {'emoji': '🏀', 'text': 'Team sports'},
      {'emoji': '🏃', 'text': 'Running'},
      {'emoji': '🚴', 'text': 'Cycling'},
      {'emoji': '🚶', 'text': 'Walking'},
    ];
  }

  Widget _buildPhysicalActivitySection() {
    final allActivities = _getPhysicalActivities();

    // Filter activities based on search
    final activities =
        _searchQuery.isEmpty
            ? allActivities
            : allActivities
                .where(
                  (activity) =>
                      activity['text']!.toLowerCase().contains(_searchQuery),
                )
                .toList();

    return _buildSelectionSection(
      title: 'Physical activity',
      items: activities,
      backgroundColor: const Color(0xFFE8F5E9),
      selectedItems: _selectedPhysicalActivity,
      iconColor: Colors.green,
    );
  }

  Widget _buildSelectionSection({
    required String title,
    required List<Map<String, String>> items,
    required Color backgroundColor,
    required Map<String, bool> selectedItems,
    required Color iconColor,
  }) {
    // If there are no items to show after filtering, and we're searching, hide section
    if (items.isEmpty && _searchQuery.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child:
              items.isEmpty
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No matching items found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                  : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        items.map((item) {
                          final isSelected =
                              selectedItems[item['text']] ?? false;

                          // Highlight searched text
                          Widget textWidget;
                          if (_searchQuery.isNotEmpty &&
                              item['text']!.toLowerCase().contains(
                                _searchQuery,
                              )) {
                            final text = item['text']!;
                            final matchIndex = text.toLowerCase().indexOf(
                              _searchQuery,
                            );
                            final beforeMatch = text.substring(0, matchIndex);
                            final match = text.substring(
                              matchIndex,
                              matchIndex + _searchQuery.length,
                            );
                            final afterMatch = text.substring(
                              matchIndex + _searchQuery.length,
                            );

                            textWidget = RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(text: beforeMatch),
                                  TextSpan(
                                    text: match,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      backgroundColor: Colors.yellow
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  TextSpan(text: afterMatch),
                                ],
                              ),
                            );
                          } else {
                            textWidget = Text(
                              item['text']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedItems[item['text']!] = !isSelected;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    isSelected
                                        ? Border.all(color: iconColor, width: 2)
                                        : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item['emoji']!,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  textWidget,
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

  Widget _buildContraceptivesSection() {
    // If we're searching and "contraceptives", "pill", etc. doesn't match, hide section
    if (_searchQuery.isNotEmpty &&
        !('contraceptives oral oc pill'.contains(_searchQuery)) &&
        !('taken on time yesterday'.contains(_searchQuery))) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Oral contraceptives (OC)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPillOption('Taken on time', _pillTakenOnTime, (value) {
                    setState(() {
                      _pillTakenOnTime = value;
                    });
                  }),
                  const SizedBox(width: 12),
                  _buildPillOption('Yesterday\'s pill', _yesterdaysPill, (
                    value,
                  ) {
                    setState(() {
                      _yesterdaysPill = value;
                    });
                  }),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set up reminders',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Other pills (non-OC)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log other pills you take a day',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(children: [_buildAddPillButton()]),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set up reminders',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillOption(
    String text,
    bool isSelected,
    Function(bool) onChanged,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onChanged(!isSelected);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5FE),
            borderRadius: BorderRadius.circular(20),
            border:
                isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade300,
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.remove,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPillButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade300,
            ),
            child: const Icon(Icons.remove, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'Add pill',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade300,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracking() {
    // If we're searching and "water" doesn't match, hide section
    if (_searchQuery.isNotEmpty &&
        !('water hydration drink fluid'.contains(_searchQuery))) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: Colors.blue.shade300, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Water',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildWaterButton(Icons.remove, () {
                if (_waterAmount > 0) {
                  setState(() {
                    _waterAmount--;
                  });
                }
              }),
              const SizedBox(width: 16),
              _buildWaterButton(Icons.add, () {
                setState(() {
                  _waterAmount++;
                });
              }),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_waterAmount / $_waterGoal fl oz',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reminders and Settings',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Icon(icon, color: Colors.grey.shade700),
      ),
    );
  }
}
