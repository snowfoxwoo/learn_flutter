import 'package:flutter/material.dart';

class FoodDiaryScreen extends StatelessWidget {
  const FoodDiaryScreen({super.key});

  static const List<String> dates = ['Today', 'Yesterday', 'Wed', 'Tue', 'Mon'];
  static const Map<String, List<FoodItem>> meals = {
    'Breakfast': [
      FoodItem('Oatmeal', '150 kcal'),
      FoodItem('Banana', '90 kcal'),
    ],
    'Lunch': [
      FoodItem('Grilled Chicken', '300 kcal'),
      FoodItem('Salad', '120 kcal'),
      FoodItem('Almonds', '100 kcal'),
      FoodItem('Almonds', '100 kcal'),
      FoodItem('Almonds', '100 kcal'),
    ],
    'Dinner': [FoodItem('Rice + Veggies', '400 kcal')],
    'Snacks': [FoodItem('Almonds', '100 kcal')],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.deepPurple),
            onPressed: () => _navigateToAddFood(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildDateSelector(),
          const SizedBox(height: 16),

          Flexible(child: _buildMealList()),
          _buildCalorieSummary(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _buildDateChip(index),
      ),
    );
  }

  Widget _buildDateChip(int index) {
    final isSelected = index == 0;
    return Chip(
      label: Text(dates[index]),
      backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[300],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMealList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: meals.entries.map(_buildMealSection).toList(),
      ),
    );
  }

  Widget _buildMealSection(MapEntry<String, List<FoodItem>> meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          meal.key,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...meal.value.map((item) => _buildFoodItem(item)),
      ],
    );
  }

  Widget _buildFoodItem(FoodItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu, color: Colors.deepPurple),
        title: Text(item.food),
        trailing: Text(item.calories),
      ),
    );
  }

  Widget _buildCalorieSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Calories:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '1160 kcal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _navigateToAddFood(BuildContext context) {
    // Implement navigation to add food page
  }
}

class FoodItem {
  final String food;
  final String calories;

  const FoodItem(this.food, this.calories);
}
