import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Model for person details
class PersonDetail {
  String? name;
  String? phone;
  Gender? gender;
  String? age;
  bool isElderOrDisabled;
  String? elderAge;
  bool? wheelchairRequired;

  PersonDetail({
    this.name,
    this.phone,
    this.gender,
    this.age,
    this.isElderOrDisabled = false,
    this.elderAge,
    this.wheelchairRequired,
  });

  @override
  String toString() {
    return 'PersonDetail{name: $name, phone: $phone, gender: $gender, age: $age, isElderOrDisabled: $isElderOrDisabled, elderAge: $elderAge, wheelchairRequired: $wheelchairRequired}';
  }
}

enum Gender {
  male,
  female,
  other,
}

// Model for slot availability
class SlotAvailability {
  final DateTime date;
  final bool isAvailable;
  final bool isOpened;
  final int availableSlots;
  final int totalSlots;

  SlotAvailability({
    required this.date,
    required this.isAvailable,
    required this.isOpened,
    required this.availableSlots,
    required this.totalSlots,
  });
}

class DarshanBookingPage extends StatefulWidget {
  final String title;

  const DarshanBookingPage({
    super.key,
    required this.title,
  });

  @override
  State<DarshanBookingPage> createState() => _DarshanBookingPageState();
}

class _DarshanBookingPageState extends State<DarshanBookingPage> {
  DateTime _selectedDate = DateTime.now();
  int _numberOfPersons = 1;
  final List<PersonDetail> _personDetails = [];
  
  // Mock data for slot availability (in real app, this would come from API)
  final List<SlotAvailability> _slotAvailability = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one person detail
    _personDetails.add(PersonDetail());
    // Initialize slot availability data
    _initializeSlotAvailability();
  }

  void _initializeSlotAvailability() {
    final now = DateTime.now();
    for (int i = 0; i < 60; i++) { // Next 60 days
      final date = now.add(Duration(days: i));
      
      // Mock logic for slot availability:
      // - Past dates: not opened
      // - Even days: available with some slots filled
      // - Odd days: fully booked
      // - Sundays: not opened
      
      bool isOpened = date.isAfter(now.subtract(const Duration(days: 1)));
      bool isAvailable = date.weekday != DateTime.sunday && 
                        date.day.isEven && 
                        date.isAfter(now.subtract(const Duration(days: 1)));
      int totalSlots = 100;
      int availableSlots = isAvailable ? (date.day % 4) * 25 : 0;
      
      _slotAvailability.add(SlotAvailability(
        date: date,
        isAvailable: isAvailable,
        isOpened: isOpened,
        availableSlots: availableSlots,
        totalSlots: totalSlots,
      ));
    }
  }

  SlotAvailability? _getSlotAvailability(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _slotAvailability.firstWhere(
      (slot) => DateTime(slot.date.year, slot.date.month, slot.date.day) == normalizedDate,
      orElse: () => SlotAvailability(
        date: date,
        isAvailable: false,
        isOpened: false,
        availableSlots: 0,
        totalSlots: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Header with back button and title
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selection with Calendar View
                    _buildCalendarView(),
                    const SizedBox(height: 24),
                    
                    // Number of Persons
                    _buildNumberOfPersons(),
                    const SizedBox(height: 24),
                    
                    // Person Details
                    _buildPersonDetails(),
                    const SizedBox(height: 24),
                    
                    // Book Now Button
                    _buildBookButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Date",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // Month and Year Header
        _buildMonthHeader(),
        const SizedBox(height: 16),
        
        // Calendar Grid
        _buildCalendarGrid(),
        const SizedBox(height: 16),
        
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(Icons.chevron_left, color: AppColors.primary),
        ),
        Text(
          _getMonthYearText(_selectedDate),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: Icon(Icons.chevron_right, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    
    List<Widget> dayWidgets = [];
    
    // Add empty cells for days before the first day of month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }
    
    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
      final slot = _getSlotAvailability(currentDate);
      
      dayWidgets.add(_buildDayCell(currentDate, slot!, day));
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        // Weekday headers
        _buildWeekdayHeader('S'),
        _buildWeekdayHeader('M'),
        _buildWeekdayHeader('T'),
        _buildWeekdayHeader('W'),
        _buildWeekdayHeader('T'),
        _buildWeekdayHeader('F'),
        _buildWeekdayHeader('S'),
        ...dayWidgets,
      ],
    );
  }

  Widget _buildWeekdayHeader(String day) {
    return Center(
      child: Text(
        day,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, SlotAvailability slot, int day) {
    bool isSelected = _isSameDay(date, _selectedDate);
    bool isToday = _isSameDay(date, DateTime.now());
    
    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.black;
    String statusText = '';
    
    if (!slot.isOpened) {
      // Not opened slots - Blue
      backgroundColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue;
      statusText = 'Closed';
    } else if (!slot.isAvailable) {
      // Filled slots - Gray
      backgroundColor = Colors.grey.withOpacity(0.3);
      textColor = Colors.grey;
      statusText = 'Filled';
    } else {
      // Available slots - Normal (with green indicator)
      backgroundColor = isSelected ? AppColors.primary : Colors.transparent;
      textColor = isSelected ? Colors.white : Colors.black;
      statusText = '${slot.availableSlots} left';
    }
    
    return GestureDetector(
      onTap: slot.isOpened && slot.isAvailable ? () => _selectDateFromCalendar(date) : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (slot.isOpened && slot.isAvailable) ...[
              const SizedBox(height: 2),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 8,
                  color: textColor,
                ),
              ),
            ] else if (!slot.isOpened) ...[
              const SizedBox(height: 2),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 8,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(Colors.blue, 'Not Opened'),
        _buildLegendItem(Colors.grey, 'Filled'),
        _buildLegendItem(AppColors.primary, 'Available'),
        _buildLegendItem(Colors.transparent, 'Today', hasBorder: true),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: hasBorder ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _getMonthYearText(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  void _selectDateFromCalendar(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // Rest of the methods remain the same...
  Widget _buildNumberOfPersons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Number of Persons",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _numberOfPersons > 1 ? _decrementPersons : null,
              icon: Icon(Icons.remove_circle_outline,
                  color: _numberOfPersons > 1 ? AppColors.primary : Colors.grey),
            ),
            Text(
              '$_numberOfPersons',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _incrementPersons,
              icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Person Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _numberOfPersons,
          itemBuilder: (context, index) {
            return _buildPersonDetailCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildPersonDetailCard(int index) {
    // Ensure we have enough person details
    while (_personDetails.length <= index) {
      _personDetails.add(PersonDetail());
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Person ${index + 1}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                _personDetails[index].name = value;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                _personDetails[index].phone = value;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Gender>(
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              value: _personDetails[index].gender,
              items: Gender.values.map((Gender gender) {
                return DropdownMenuItem<Gender>(
                  value: gender,
                  child: Text(_getGenderText(gender)),
                );
              }).toList(),
              onChanged: (Gender? newValue) {
                setState(() {
                  _personDetails[index].gender = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _personDetails[index].age = value;
              },
            ),
            const SizedBox(height: 16),
            
            // Elder/Disabled Section
            _buildElderDisabledSection(index),
          ],
        ),
      ),
    );
  }

  Widget _buildElderDisabledSection(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Elder/Disabled Checkbox
        Row(
          children: [
            Checkbox(
              value: _personDetails[index].isElderOrDisabled,
              onChanged: (bool? value) {
                setState(() {
                  _personDetails[index].isElderOrDisabled = value ?? false;
                  // Reset wheelchair requirement when unchecked
                  if (!value!) {
                    _personDetails[index].wheelchairRequired = null;
                  }
                });
              },
            ),
            const Text(
              "Elderly or Disabled Person",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        
        // Elder Age and Wheelchair Options (only show if checked)
        if (_personDetails[index].isElderOrDisabled) ...[
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Age (if elderly)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.elderly),
              hintText: "Enter age if applicable",
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _personDetails[index].elderAge = value;
            },
          ),
          const SizedBox(height: 12),
          
          // Wheelchair Requirement
          const Text(
            "Wheelchair Requirement",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text("Yes"),
                  value: true,
                  groupValue: _personDetails[index].wheelchairRequired,
                  onChanged: (bool? value) {
                    setState(() {
                      _personDetails[index].wheelchairRequired = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text("No"),
                  value: false,
                  groupValue: _personDetails[index].wheelchairRequired,
                  onChanged: (bool? value) {
                    setState(() {
                      _personDetails[index].wheelchairRequired = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBookButton() {
    final slot = _getSlotAvailability(_selectedDate);
    bool canBook = slot!.isOpened && slot!.isAvailable;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canBook ? _submitBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canBook ? AppColors.primary : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          canBook ? "Book Now" : "No Slots Available",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
        ),
      ),
    );
  }

  // Remove the old _selectDate method since we're using calendar view now

  void _incrementPersons() {
    setState(() {
      _numberOfPersons++;
    });
  }

  void _decrementPersons() {
    setState(() {
      if (_numberOfPersons > 1) {
        _numberOfPersons--;
      }
    });
  }

  String _getGenderText(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
      case Gender.other:
        return "Other";
      default:
        return "Select Gender";
    }
  }

  void _submitBooking() {
    // Validate and submit the booking
    bool isValid = true;
    for (int i = 0; i < _numberOfPersons; i++) {
      if (_personDetails[i].name?.isEmpty ?? true) {
        isValid = false;
        break;
      }
      
      // Additional validation for elder/disabled persons
      if (_personDetails[i].isElderOrDisabled) {
        if (_personDetails[i].wheelchairRequired == null) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please specify wheelchair requirement for elder/disabled persons"),
              backgroundColor: Colors.red,
            ),
          );
          break;
        }
      }
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required details for all persons"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would typically send the booking data to your backend
    print("Booking submitted:");
    print("Darshan Type: ${widget.title}");
    print("Date: $_selectedDate");
    print("Number of Persons: $_numberOfPersons");
    for (int i = 0; i < _numberOfPersons; i++) {
      print("Person ${i + 1}: ${_personDetails[i]}");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking submitted successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back or to confirmation page
    // Navigator.of(context).pop();
  }
}