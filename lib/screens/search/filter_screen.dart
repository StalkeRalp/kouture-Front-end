import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';
import 'package:hugeicons/hugeicons.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FilterScreen({super.key, this.initialFilters});

  static const String routeName = '/filter';

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const Color _salmon = Color(0xFFFF8C8C);
  
  late RangeValues _currentRangeValues;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late List<String> _selectedCategories;
  late List<String> _selectedSizes;
  late String? _selectedColor;

  List<String> _categories = [];
  List<String> _sizes = [];
  List<String> _colorsList = []; // Hex strings
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final init = widget.initialFilters;
    _currentRangeValues = init?['priceRange'] ?? const RangeValues(0, 150000);
    
    _minPriceController = TextEditingController(text: _currentRangeValues.start.round().toString());
    _maxPriceController = TextEditingController(text: _currentRangeValues.end.round().toString());
    
    _selectedCategories = List<String>.from(init?['categories'] ?? []);
    _selectedSizes = List<String>.from(init?['sizes'] ?? []);
    _selectedColor = init?['color'];
    
    _loadMetadata();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    final cats = await MockFirebase().getCategoriesList();
    final sizes = await MockFirebase().getUniqueSizes();
    final colors = await MockFirebase().getUniqueColors();
    if (mounted) {
      setState(() {
        _categories = cats;
        _sizes = sizes;
        _colorsList = colors;
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _currentRangeValues = const RangeValues(0, 150000);
      _minPriceController.text = '0';
      _maxPriceController.text = '150000';
      _selectedCategories = [];
      _selectedSizes = [];
      _selectedColor = null;
    });
  }

  void _syncSliderFromText() {
    double min = double.tryParse(_minPriceController.text) ?? 0;
    double max = double.tryParse(_maxPriceController.text) ?? 200000;
    
    if (min < 0) min = 0;
    if (max > 200000) max = 200000;
    if (min > max) min = max;

    setState(() {
      _currentRangeValues = RangeValues(min, max);
    });
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'priceRange': _currentRangeValues,
      'categories': _selectedCategories,
      'sizes': _selectedSizes,
      'color': _selectedColor,
    });
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(Translator.t('filters'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.black, size: 24.0),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!_isLoading)
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(Translator.t('reset'), style: const TextStyle(color: _salmon, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          body: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: _salmon))
            : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Translator.t('price_range')),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceInput(
                        controller: _minPriceController,
                        label: 'Min (XAF)',
                        onChanged: (val) => _syncSliderFromText(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      height: 1,
                      width: 10,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildPriceInput(
                        controller: _maxPriceController,
                        label: 'Max (XAF)',
                        onChanged: (val) => _syncSliderFromText(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 200000,
                  divisions: 40,
                  activeColor: _salmon,
                  inactiveColor: Colors.grey.shade200,
                  labels: RangeLabels(
                    '${_currentRangeValues.start.round()} XAF',
                    '${_currentRangeValues.end.round()} XAF',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _currentRangeValues = values;
                      _minPriceController.text = values.start.round().toString();
                      _maxPriceController.text = values.end.round().toString();
                    });
                  },
                ),
                
                if (_categories.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  _buildSectionTitle(Translator.t('categories')),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(cat);
                            } else {
                              _selectedCategories.remove(cat);
                            }
                          });
                        },
                        selectedColor: _salmon.withValues(alpha: 0.2),
                        checkmarkColor: _salmon,
                        backgroundColor: Colors.grey.shade50,
                        labelStyle: TextStyle(
                          color: isSelected ? _salmon : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                if (_sizes.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  _buildSectionTitle(Translator.t('sizes')),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _sizes.map((size) {
                      final isSelected = _selectedSizes.contains(size);
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSizes.add(size);
                            } else {
                              _selectedSizes.remove(size);
                            }
                          });
                        },
                        selectedColor: _salmon.withValues(alpha: 0.2),
                        backgroundColor: Colors.grey.shade50,
                        labelStyle: TextStyle(
                          color: isSelected ? _salmon : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (_colorsList.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  _buildSectionTitle(Translator.t('colors')),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colorsList.length,
                      itemBuilder: (context, index) {
                        final hex = _colorsList[index];
                        final color = _hexToColor(hex);
                        final isSelected = _selectedColor == hex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = isSelected ? null : hex;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? _salmon : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: isSelected 
                              ? HugeIcon(icon: HugeIcons.strokeRoundedTick01, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white, 
                                  size: 20)
                              : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 50),
              ],
            ),
          ),
          bottomNavigationBar: _isLoading ? null : Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: _salmon,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: Text(Translator.t('apply_filters'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceInput({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.bold),
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }
}


