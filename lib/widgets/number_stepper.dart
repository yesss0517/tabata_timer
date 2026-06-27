import 'package:flutter/material.dart';
 
/// 라벨 + 숫자 +/- 버튼 위젯 (StatelessWidget)
class NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;
 
  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          _StepBtn(
            icon: Icons.remove_rounded,
            enabled: value > min,
            onTap: () => onChanged(value - step),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 72,
            child: Text(
              '$value$unit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _StepBtn(
            icon: Icons.add_rounded,
            enabled: value < max,
            onTap: () => onChanged(value + step),
          ),
        ],
      ),
    );
  }
}
 
class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
 
  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? Colors.white24 : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.white : Colors.white24,
        ),
      ),
    );
  }
}