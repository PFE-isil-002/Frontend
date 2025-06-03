import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(
          'ML Model Performance Dashboard',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.grey.shade900, // Darker header
        foregroundColor: Colors.teal, // Teal accent
        elevation: 8,
        shadowColor: const Color(0xFF7FDBDA).withOpacity(0.3),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Best Model Highlight
                _buildBestModelCard(),
                const SizedBox(height: 24),

                // Performance Summary
                _buildPerformanceSummary(),
                const SizedBox(height: 24),

                // Model Categories
                _buildModelCategorySection(
                  'Deep Learning Models',
                  _getDeepLearningModels(),
                  const Color(0xFF7FDBDA), // Teal
                ),
                const SizedBox(height: 20),

                _buildModelCategorySection(
                  'Machine Learning Models',
                  _getMachineLearningModels(),
                  const Color(0xFF415A77), // Blue-grey
                ),
                const SizedBox(height: 24),

                // Confusion Matrices Section
                _buildConfusionMatricesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBestModelCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal, // Teal
                  const Color(0xFF415A77), // Blue-grey
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7FDBDA).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 2000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, rotationValue, child) {
                    return Transform.rotate(
                      angle: rotationValue * 2 * 3.14159,
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 48,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'BEST PERFORMING MODEL',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'LSTM (256-128)',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnimatedMetricChip('95%', 'Accuracy', Colors.white),
                    _buildAnimatedMetricChip('95%', 'Recall', Colors.white),
                    _buildAnimatedMetricChip('21', 'Time Steps', Colors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedMetricChip(String value, String label, Color textColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Column(
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: textColor.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceSummary() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7FDBDA).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Summary',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7FDBDA),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'LSTM models demonstrate superior performance on long sequences, with the (256-128) architecture achieving the highest accuracy. Deep learning models generally outperform traditional machine learning approaches for temporal sequence analysis.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFE0E1DD),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCategorySection(
      String title, List<ModelResult> models, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        ...models.asMap().entries.map((entry) {
          int index = entry.key;
          ModelResult model = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: _buildModelCard(model, color),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildModelCard(ModelResult model, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: model.isBest
            ? Border.all(color: const Color(0xFF7FDBDA), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: model.isBest
                ? const Color(0xFF7FDBDA).withOpacity(0.2)
                : Colors.black.withOpacity(0.2),
            blurRadius: model.isBest ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Left side - Model info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          model.name,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      if (model.isBest)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7FDBDA).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF7FDBDA), width: 1),
                          ),
                          child: Text(
                            'BEST',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF7FDBDA),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultColumn(
                            '21 Time Steps', model.accuracy21, model.recall21),
                      ),
                      Expanded(
                        child: _buildResultColumn(
                            '7 Time Steps', model.accuracy7, model.recall7),
                      ),
                    ],
                  ),
                  if (model.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      model.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFE0E1DD).withOpacity(0.8),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right side - Confusion matrix image
            if (model.confusionMatrixPath.isNotEmpty)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF415A77).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    model.confusionMatrixPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        color: const Color(0xFF415A77).withOpacity(0.2),
                        child: Icon(
                          Icons.image_not_supported,
                          color: const Color(0xFF415A77),
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultColumn(String timeSteps, int accuracy, int recall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeSteps,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7FDBDA),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Accuracy: $accuracy%',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFFE0E1DD),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Recall: $recall%',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFFE0E1DD),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfusionMatricesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confusion Matrices Gallery',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7FDBDA),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildConfusionMatrixCard(
                'KNN (k=7)', 'assets/models/matriceconfusionknn7.png'),
            _buildConfusionMatrixCard(
                'KNN (k=21)', 'assets/models/matriceconfusionknn21.png'),
            _buildConfusionMatrixCard('Logistic Regression (7)',
                'assets/models/matriceconfusionlr7.png'),
            _buildConfusionMatrixCard('Logistic Regression (21)',
                'assets/models/matriceconfusionlr21.png'),
            _buildConfusionMatrixCard(
                'SVM (7)', 'assets/models/matriceconfusionsvm7.png'),
            _buildConfusionMatrixCard(
                'SVM (21)', 'assets/models/matriceconfusionsvm21.png'),
            _buildConfusionMatrixCard(
                'LSTM (14-7-7)', 'assets/models/matriceconfusionlstm14-7-7.png',
                isHighlighted: true),
            _buildConfusionMatrixCard('LSTM (14-7-21)',
                'assets/models/matriceconfusionlstm14-7-21.png',
                isHighlighted: true),
            _buildConfusionMatrixCard('LSTM (256-128-7)',
                'assets/models/matriceconfusionlstm256-128-7.png',
                isHighlighted: true),
            _buildConfusionMatrixCard('LSTM (256-128-21)',
                'assets/models/matriceconfusionlstm256-128-21.png',
                isBest: true),
            _buildConfusionMatrixCard(
                'MLP (14-7-7)', 'assets/models/matriceconfusionmlp14-7-7.png'),
            _buildConfusionMatrixCard('MLP (14-7-21)',
                'assets/models/matriceconfusionmlp14-7-21.png'),
            _buildConfusionMatrixCard('MLP (256-128-16-7)',
                'assets/models/matriceconfusionmlp256-128-16-7.png'),
            _buildConfusionMatrixCard('MLP (256-128-16-21)',
                'assets/models/matriceconfusionmlp256-128-16-21.png'),
            _buildConfusionMatrixCard(
                'RNN (7)', 'assets/models/matriceconfusionrnn7.png'),
            _buildConfusionMatrixCard(
                'RNN (21)', 'assets/models/matriceconfusionrnn21.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildConfusionMatrixCard(String title, String imagePath,
      {bool isHighlighted = false, bool isBest = false}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B),
              borderRadius: BorderRadius.circular(16),
              border: isBest
                  ? Border.all(color: const Color(0xFF7FDBDA), width: 3)
                  : isHighlighted
                      ? Border.all(
                          color: const Color(0xFF7FDBDA).withOpacity(0.5),
                          width: 2)
                      : Border.all(
                          color: const Color(0xFF415A77).withOpacity(0.3),
                          width: 1),
              boxShadow: [
                BoxShadow(
                  color: isBest
                      ? const Color(0xFF7FDBDA).withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: isBest ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBest
                        ? const Color(0xFF7FDBDA).withOpacity(0.1)
                        : isHighlighted
                            ? const Color(0xFF7FDBDA).withOpacity(0.05)
                            : const Color(0xFF415A77).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isBest
                                ? const Color(0xFF7FDBDA)
                                : const Color(0xFFE0E1DD),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (isBest)
                        Icon(Icons.star,
                            color: const Color(0xFF7FDBDA), size: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported,
                            color: const Color(0xFF415A77),
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ModelResult> _getDeepLearningModels() {
    return [
      ModelResult(
        name: 'LSTM (256-128)',
        accuracy21: 95,
        recall21: 95,
        accuracy7: 91,
        recall7: 91,
        isBest: true,
        description:
            'Best performing model with superior long sequence handling',
        confusionMatrixPath: 'assets/models/matriceconfusionlstm256-128-21.png',
      ),
      ModelResult(
        name: 'LSTM (14-7)',
        accuracy21: 92,
        recall21: 91,
        accuracy7: 89,
        recall7: 87,
        description:
            'Strong performance with good temporal dependency management',
        confusionMatrixPath: 'assets/models/matriceconfusionlstm14-7-21.png',
      ),
      ModelResult(
        name: 'MLP (256-128-16)',
        accuracy21: 87,
        recall21: 85,
        accuracy7: 86,
        recall7: 84,
        description:
            'Good performance on long sequences despite lack of recurrent structure',
        confusionMatrixPath:
            'assets/models/matriceconfusionmlp256-128-16-21.png',
      ),
      ModelResult(
        name: 'MLP (14-7)',
        accuracy21: 66,
        recall21: 43,
        accuracy7: 66,
        recall7: 43,
        description: 'Limited performance with simpler architecture',
        confusionMatrixPath: 'assets/models/matriceconfusionmlp14-7-21.png',
      ),
      ModelResult(
        name: 'RNN',
        accuracy21: 71,
        recall21: 70,
        accuracy7: 79,
        recall7: 73,
        description:
            'Better on shorter sequences, limited by simple architecture',
        confusionMatrixPath: 'assets/models/matriceconfusionrnn21.png',
      ),
    ];
  }

  List<ModelResult> _getMachineLearningModels() {
    return [
      ModelResult(
        name: 'KNN',
        accuracy21: 86,
        recall21: 79,
        accuracy7: 80,
        recall7: 77,
        description:
            'Best traditional ML model, effective use of proximity between observations',
        confusionMatrixPath: 'assets/models/matriceconfusionknn21.png',
      ),
      ModelResult(
        name: 'SVM',
        accuracy21: 88,
        recall21: 76,
        accuracy7: 84,
        recall7: 74,
        description:
            'Good robustness but performance decreases with reduced temporal information',
        confusionMatrixPath: 'assets/models/matriceconfusionsvm21.png',
      ),
      ModelResult(
        name: 'Logistic Regression',
        accuracy21: 72,
        recall21: 62,
        accuracy7: 72,
        recall7: 66,
        description:
            'Limited by inability to capture non-linear complexity of abnormal behaviors',
        confusionMatrixPath: 'assets/models/matriceconfusionlr21.png',
      ),
    ];
  }
}

class ModelResult {
  final String name;
  final int accuracy21;
  final int recall21;
  final int accuracy7;
  final int recall7;
  final bool isBest;
  final String description;
  final String confusionMatrixPath;

  ModelResult({
    required this.name,
    required this.accuracy21,
    required this.recall21,
    required this.accuracy7,
    required this.recall7,
    this.isBest = false,
    this.description = '',
    this.confusionMatrixPath = '',
  });
}
