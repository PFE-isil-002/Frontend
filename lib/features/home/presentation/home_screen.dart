import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'AI Model Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Model Performance Comparison',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),

            // KNN Model Section
            _buildModelSection(
              title: 'K-Nearest Neighbors (KNN)',
              color: Colors.teal.shade300,
              confusionMatrixPath:
                  "assets/models/matriceconfusionknnoptimise.png",
              curvePath: "assets/models/courbeknn.png",
              icon: Icons.scatter_plot,
            ),

            // SVM Model Section
            _buildModelSection(
              title: 'Support Vector Machine (SVM)',
              color: Colors.teal.shade400,
              confusionMatrixPath: "assets/models/matriceconfusionSVM.png",
              curvePath: "assets/models/courbesvm.png",
              icon: Icons.linear_scale,
            ),

            // Random Forest Model Section
            _buildModelSection(
              title: 'Random Forest',
              color: Colors.teal.shade500,
              confusionMatrixPath: "assets/models/matriceconfusionRF.png",
              curvePath: "assets/models/courbeRF.png",
              icon: Icons.account_tree,
            ),

            // Logistic Regression Model Section
            _buildModelSection(
              title: 'Logistic Regression',
              color: Colors.teal.shade600,
              confusionMatrixPath: "assets/models/matriceconfusionLR.png",
              curvePath: null, // No curve image for LR
              icon: Icons.show_chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSection({
    required String title,
    required Color color,
    required String confusionMatrixPath,
    String? curvePath,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model Title with Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Images Section
            if (curvePath != null) ...[
              // Two images side by side for models with curves
              Row(
                children: [
                  Expanded(
                    child: _buildImageCard(
                      title: 'Confusion Matrix',
                      imagePath: confusionMatrixPath,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageCard(
                      title: 'Performance Curve',
                      imagePath: curvePath,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Single image for models without curves
              _buildImageCard(
                title: 'Confusion Matrix',
                imagePath: confusionMatrixPath,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required String title,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[800],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
