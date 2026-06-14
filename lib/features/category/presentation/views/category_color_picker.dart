import 'package:flutter/material.dart';

class CategoryColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const CategoryColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<CategoryColorPicker> createState() => _CategoryColorPickerState();
}

class _CategoryColorPickerState extends State<CategoryColorPicker> {
  late Color _currentColor;
  late int _r;
  late int _g;
  late int _b;
  late TextEditingController _hexController;
  bool _showRGB = false;

  final List<Color> _colorPresets = [
    Colors.indigo,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.brown,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lime,
    Colors.blueGrey,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _r = (_currentColor.r * 255.0).round().clamp(0, 255);
    _g = (_currentColor.g * 255.0).round().clamp(0, 255);
    _b = (_currentColor.b * 255.0).round().clamp(0, 255);

    final hexStr = _currentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    _hexController = TextEditingController(text: '#$hexStr');
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateColor(Color color, {bool updateHexField = true, bool updateRGB = true}) {
    setState(() {
      _currentColor = color;
      if (updateRGB) {
        _r = (color.r * 255.0).round().clamp(0, 255);
        _g = (color.g * 255.0).round().clamp(0, 255);
        _b = (color.b * 255.0).round().clamp(0, 255);
      }
      if (updateHexField) {
        final hexStr = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
        _hexController.text = '#$hexStr';
      }
    });
    widget.onColorChanged(color);
  }

  void _onRGBChanged() {
    final newColor = Color.fromARGB(255, _r, _g, _b);
    _updateColor(newColor, updateRGB: false);
  }

  void _onHexChanged(String val) {
    var hex = val.replaceFirst('#', '').trim();
    if (hex.length == 6) {
      try {
        final parsedColor = Color(int.parse('FF$hex', radix: 16));
        _updateColor(parsedColor, updateHexField: false);
      } catch (_) {
        // Ignore invalid input
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Color Preview and Hex Field
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.outline.withAlpha(100), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withAlpha(80),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _hexController,
                decoration: const InputDecoration(
                  labelText: 'Color Hex Code',
                  hintText: '#HEXCODE',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: _onHexChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Presets Label
        Text(
          'Preset Colors',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        // Wrap for Presets
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colorPresets.map((preset) {
            final isSelected = preset.toARGB32() == _currentColor.toARGB32();
            return GestureDetector(
              onTap: () => _updateColor(preset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: preset,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.onSurface,
                          width: 3,
                        )
                      : Border.all(
                          color: theme.colorScheme.outline.withAlpha(40),
                          width: 1,
                        ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Toggle Custom RGB Mix
        TextButton.icon(
          onPressed: () {
            setState(() {
              _showRGB = !_showRGB;
            });
          },
          icon: Icon(_showRGB ? Icons.expand_less : Icons.tune),
          label: Text(_showRGB ? 'Hide Custom Sliders' : 'Mix Custom RGB'),
        ),
        if (_showRGB) ...[
          const SizedBox(height: 8),
          _buildSliderRow(
            label: 'R',
            value: _r,
            activeColor: Colors.red,
            onChanged: (val) {
              setState(() {
                _r = val.toInt();
                _onRGBChanged();
              });
            },
          ),
          _buildSliderRow(
            label: 'G',
            value: _g,
            activeColor: Colors.green,
            onChanged: (val) {
              setState(() {
                _g = val.toInt();
                _onRGBChanged();
              });
            },
          ),
          _buildSliderRow(
            label: 'B',
            value: _b,
            activeColor: Colors.blue,
            onChanged: (val) {
              setState(() {
                _b = val.toInt();
                _onRGBChanged();
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required int value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            activeColor: activeColor,
            inactiveColor: activeColor.withAlpha(50),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 32,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value.toString(),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }
}
