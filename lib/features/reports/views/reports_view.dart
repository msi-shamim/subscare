import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/reports_controller.dart';

/// Reports view with charts and analytics
class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  NumberFormat get currencyFormat {
    final settings = Get.find<SettingsController>();
    return NumberFormat.currency(
      symbol: settings.currencySymbol,
      decimalDigits: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodFilter(),
                const SizedBox(height: 16),
                _buildComparisonToggle(),
                const SizedBox(height: 16),
                _buildSummaryCards(),
                const SizedBox(height: 24),
                _buildLineChart(),
                const SizedBox(height: 24),
                _buildPieChartSection(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'week'.tr,
                isSelected: controller.selectedPeriod.value == ReportPeriod.week,
                onTap: () => controller.changePeriod(ReportPeriod.week),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'month'.tr,
                isSelected: controller.selectedPeriod.value == ReportPeriod.month,
                onTap: () => controller.changePeriod(ReportPeriod.month),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'year'.tr,
                isSelected: controller.selectedPeriod.value == ReportPeriod.year,
                onTap: () => controller.changePeriod(ReportPeriod.year),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'custom'.tr,
                isSelected: controller.selectedPeriod.value == ReportPeriod.custom,
                onTap: () => _showCustomDatePicker(isComparison: false),
                icon: Icons.date_range,
              ),
            ],
          ),
        ));
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonToggle() {
    return Obx(() => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.compare_arrows, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'compare_periods'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Switch(
                      value: controller.isComparisonMode.value,
                      onChanged: controller.toggleComparisonMode,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                if (controller.isComparisonMode.value) ...[
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateRangeDisplay(
                          label: 'current'.tr,
                          dateRange: controller.formattedDateRange,
                          onTap: () => _showCustomDatePicker(isComparison: false),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateRangeDisplay(
                          label: 'compare'.tr,
                          dateRange: controller.formattedCompareDateRange,
                          onTap: () => _showCustomDatePicker(isComparison: true),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget _buildDateRangeDisplay({
    required String label,
    required String dateRange,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateRange,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final showComparison = controller.isComparisonMode.value;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'income'.tr,
                  amount: controller.totalIncome.value,
                  compareAmount: showComparison ? controller.compareTotalIncome.value : null,
                  color: AppColors.credit,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'expense'.tr,
                  amount: controller.totalExpense.value,
                  compareAmount: showComparison ? controller.compareTotalExpense.value : null,
                  color: AppColors.debit,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            title: 'balance'.tr,
            amount: controller.totalIncome.value - controller.totalExpense.value,
            compareAmount: showComparison
                ? controller.compareTotalIncome.value - controller.compareTotalExpense.value
                : null,
            color: AppColors.primary,
            icon: Icons.account_balance_wallet,
            isFullWidth: true,
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    double? compareAmount,
    required Color color,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    final percentageChange = compareAmount != null
        ? controller.getPercentageChange(amount, compareAmount)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontSize: isFullWidth ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (percentageChange != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  percentageChange >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: percentageChange >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: percentageChange >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'vs_previous'.tr,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Obx(() {
      final data = controller.chartData;
      final compareData = controller.compareChartData;

      if (data.isEmpty) {
        return _buildEmptyState('no_chart_data'.tr);
      }

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'trend_chart'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildLegendItem('income'.tr, AppColors.credit),
                  const SizedBox(width: 12),
                  _buildLegendItem('expense'.tr, AppColors.debit),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _calculateInterval(data),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) => Text(
                            _formatAxisValue(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: _calculateLabelInterval(data.length),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  data[index].label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Income line
                      _buildLineChartBarData(
                        data.map((e) => e.income).toList(),
                        AppColors.credit,
                        false,
                      ),
                      // Expense line
                      _buildLineChartBarData(
                        data.map((e) => e.expense).toList(),
                        AppColors.debit,
                        false,
                      ),
                      // Comparison income line (dashed)
                      if (compareData.isNotEmpty)
                        _buildLineChartBarData(
                          compareData.map((e) => e.income).toList(),
                          AppColors.credit.withValues(alpha: 0.5),
                          true,
                        ),
                      // Comparison expense line (dashed)
                      if (compareData.isNotEmpty)
                        _buildLineChartBarData(
                          compareData.map((e) => e.expense).toList(),
                          AppColors.debit.withValues(alpha: 0.5),
                          true,
                        ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              currencyFormat.format(spot.y),
                              TextStyle(
                                color: spot.bar.color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  LineChartBarData _buildLineChartBarData(
    List<double> values,
    Color color,
    bool isDashed,
  ) {
    return LineChartBarData(
      spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: FlDotData(
        show: !isDashed,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 0,
        ),
      ),
      dashArray: isDashed ? [5, 5] : null,
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildPieChartSection() {
    return Obx(() {
      final expenseData = controller.expenseCategoryData;
      final incomeData = controller.incomeCategoryData;
      final showExpense = controller.showExpensePie.value;
      final data = showExpense ? expenseData : incomeData;

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'category_breakdown'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildPieToggle(),
                ],
              ),
              const SizedBox(height: 20),
              if (data.isEmpty)
                _buildEmptyState('no_category_data'.tr)
              else
                Column(
                  children: [
                    // Pie Chart - centered in its own row
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: data.map((category) {
                            return PieChartSectionData(
                              value: category.amount,
                              color: category.color,
                              title: '${category.percentage.toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              radius: 70,
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Category details - in next row
                    ...data.take(6).map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: category.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${category.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              currencyFormat.format(category.amount),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPieToggle() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => controller.showExpensePie.value = true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.showExpensePie.value ? AppColors.debit : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'expense'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.showExpensePie.value ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.showExpensePie.value = false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: !controller.showExpensePie.value ? AppColors.credit : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'income'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: !controller.showExpensePie.value ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  double _calculateInterval(List<ChartDataPoint> data) {
    if (data.isEmpty) return 1000;
    final maxValue = data.fold<double>(0, (max, point) {
      final pointMax = point.income > point.expense ? point.income : point.expense;
      return pointMax > max ? pointMax : max;
    });
    if (maxValue <= 0) return 1000;
    return (maxValue / 4).ceilToDouble();
  }

  double _calculateLabelInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 31) return 5;
    return 1;
  }

  String _formatAxisValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  void _showCustomDatePicker({required bool isComparison}) async {
    final initialStart = isComparison
        ? controller.compareStartDate.value
        : controller.startDate.value;
    final initialEnd = isComparison
        ? controller.compareEndDate.value
        : controller.endDate.value;

    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isComparison) {
        controller.setComparisonDateRange(picked.start, picked.end);
      } else {
        controller.setCustomDateRange(picked.start, picked.end);
      }
    }
  }
}
