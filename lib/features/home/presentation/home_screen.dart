import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'AI Model Performance Dashboard',
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
              'Machine Learning Model Comparison',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cybersecurity Attack Detection Models',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Performance Overview Cards
            _buildPerformanceOverview(),
            const SizedBox(height: 24),

            // RNN Model Section (Best Performer)
            _buildModelSection(
              title: 'Recurrent Neural Network (RNN)',
              subtitle: '🏆 Champion - Deep Learning Excellence',
              color: Colors.amber.shade400,
              confusionMatrixPath: "assets/models/matriceconfusionrnn.png",
              curvePath: "assets/models/courbernn.png",
              icon: Icons.memory,
              metrics: {
                'Accuracy': '96.32%',
                'Precision': '96%',
                'Recall': '96%',
                'F1-Score': '96%',
              },
              isTopPerformer: true,
              isChampion: true,
            ),

            // SVM Model Section (Second Best)
            _buildModelSection(
              title: 'Support Vector Machine (SVM)',
              subtitle: '🥈 Strong Traditional ML Performance',
              color: Colors.green.shade400,
              confusionMatrixPath: "assets/models/matriceconfusionSVM.png",
              curvePath: "assets/models/courbesvm.png",
              icon: Icons.linear_scale,
              metrics: {
                'Accuracy': '91.16%',
                'Precision': '90%',
                'Recall': '88%',
                'F1-Score': '89%',
              },
              isTopPerformer: false,
            ),

            // KNN Model Section
            _buildModelSection(
              title: 'K-Nearest Neighbors (KNN)',
              subtitle: 'Distance-based Classification',
              color: Colors.blue.shade400,
              confusionMatrixPath:
                  "assets/models/matriceconfusionknnoptimise.png",
              curvePath: "assets/models/courbeknn.png",
              icon: Icons.scatter_plot,
              metrics: {
                'Accuracy': '88.44%',
                'Precision': '90%',
                'Recall': '83%',
                'F1-Score': '86%',
              },
              additionalInfo: 'Best params: manhattan distance, k=3',
            ),

            // Random Forest Model Section
            _buildModelSection(
              title: 'Random Forest',
              subtitle: 'Ensemble Learning Method',
              color: Colors.orange.shade400,
              confusionMatrixPath: "assets/models/matriceconfusionRF.png",
              curvePath: "assets/models/courbeRF.png",
              icon: Icons.account_tree,
              metrics: {
                'Accuracy': '88.4%',
                'Precision': '89%',
                'Recall': '88%',
                'F1-Score': '88%',
              },
              additionalInfo: 'Best params: 200 estimators, max_depth=20',
            ),

            // Logistic Regression Model Section
            _buildModelSection(
              title: 'Logistic Regression',
              subtitle: 'Linear Classification Model',
              color: Colors.purple.shade400,
              confusionMatrixPath: "assets/models/matriceconfusionLR.png",
              curvePath: null,
              icon: Icons.show_chart,
              metrics: {
                'Accuracy': '76.64%',
                'Precision': '74%',
                'Recall': '75%',
                'F1-Score': '74%',
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                    'Best Model', 'RNN', '96.32%', Icons.star),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                    'Models Tested', '5', 'Complete', Icons.assessment),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelSection({
    required String title,
    required String subtitle,
    required Color color,
    required String confusionMatrixPath,
    String? curvePath,
    required IconData icon,
    required Map<String, String> metrics,
    bool isTopPerformer = false,
    bool isChampion = false,
    String? additionalInfo,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: isChampion ? 12 : (isTopPerformer ? 8 : 4),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isChampion
            ? BorderSide(color: Colors.amber.shade400, width: 3)
            : (isTopPerformer
                ? BorderSide(color: Colors.green.shade400, width: 2)
                : BorderSide.none),
      ),
      child: Container(
        decoration: isChampion
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champion Badge (only for RNN)
              if (isChampion) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.amber.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'CHAMPION MODEL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Model Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Performance Metrics
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isChampion
                      ? Colors.grey[800]?.withOpacity(0.8)
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: isChampion
                      ? Border.all(
                          color: Colors.amber.shade400.withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Performance Metrics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                          ),
                        ),
                        if (isChampion) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.trending_up,
                            color: Colors.amber.shade400,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                              'Accuracy', metrics['Accuracy']!, Colors.green),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                              'Precision', metrics['Precision']!, Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                              'Recall', metrics['Recall']!, Colors.orange),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                              'F1-Score', metrics['F1-Score']!, Colors.purple),
                        ),
                      ],
                    ),
                    if (additionalInfo != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          additionalInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Images Section
              if (curvePath != null) ...[
                // Two images side by side for models with curves
                Row(
                  children: [
                    Expanded(
                      child: _buildImageCard(
                        title: 'Confusion Matrix',
                        imagePath: confusionMatrixPath,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageCard(
                        title: 'Learning Curve',
                        imagePath: curvePath,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Single image for models without curves
                _buildImageCard(
                  title: 'Confusion Matrix',
                  imagePath: confusionMatrixPath,
                  color: color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required String title,
    required String imagePath,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[800],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
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
