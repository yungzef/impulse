import 'package:flutter/material.dart';

class LearningModes extends StatefulWidget {
  const LearningModes({super.key});

  @override
  State<LearningModes> createState() => _LearningModesState();
}

class _LearningModesState extends State<LearningModes> {
  late List<bool> _isExpanded;
  late List<Map<String, dynamic>> _learningModes;

  @override
  void initState() {
    super.initState();
    _isExpanded = List.generate(5, (index) => false);
    _learningModes = [
      {
        'title': 'Симулятор іспиту',
        'features': [
          'Повна імітація офіційного іспиту в ТСЦ',
          '20 питань з обмеженням часу (2 хв/питання)',
          'Допустимо лише 2 помилки для успішного складання',
          'Реальні умови та атмосфера тестування',
        ],
      },
      {
        'title': 'Тематичне навчання',
        'features': [
          'Усі питання систематизовані за темами',
          'Навчання у власному темпі без обмеження часу',
          'Детальні пояснення до кожного питання',
          'Ідеально для поступового вивчення матеріалу',
        ],
      },
      {
        'title': 'Випадкові білети',
        'features': [
          '20 випадкових питань з різних тем',
          'Без тиску часу - навчайтесь комфортно',
          'Розширені пояснення до кожної відповіді',
          'Ідеально для комплексного перевірення знань',
        ],
      },
      {
        'title': 'Аналіз помилок',
        'features': [
          'Автоматичний збір усіх ваших помилок',
          'Детальний розбір проблемних питань',
          'Персональні рекомендації для покращення',
          'Ідеальний інструмент для роботи над слабкими місцями',
        ],
      },
      {
        'title': 'Топ-100 складних питань',
        'features': [
          'Відібрані найскладніші питання іспиту',
          'Статистика помилок інших користувачів',
          'Розширені пояснення та поради',
          'Найефективніший спосіб підготуватись до складних моментів',
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Режими навчання',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Обирай спосіб підготовки, який найкраще підходить саме тобі.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 40),
          ..._buildExpansionPanels(accentColor),
        ],
      ),
    );
  }

  List<Widget> _buildExpansionPanels(Color accentColor) {
    return List.generate(_learningModes.length, (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExpansionTile(
          key: ValueKey(index),
          initiallyExpanded: _isExpanded[index],
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded[index] = expanded);
          },
          title: Text(
            _learningModes[index]['title'],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          collapsedIconColor: accentColor,
          iconColor: accentColor,
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(20),
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_learningModes[index]['features'] as List<String>)
                  .map((feature) => _buildFeatureItem(feature, accentColor))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeatureItem(String text, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(color: accentColor, fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}