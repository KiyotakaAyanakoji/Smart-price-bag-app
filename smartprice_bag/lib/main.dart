import 'package:flutter/material.dart';

void main() {
  runApp(const SmartPriceBagApp());
}

class SmartPriceBagApp extends StatelessWidget {
  const SmartPriceBagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPrice Bag',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD1DC),
          primary: const Color(0xFFF48FB1),
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Base State
  double baseWeight = 1000;
  double basePrice = 140;
  bool isBaseKg = false; // false = g, true = kg

  // Calculator State
  final TextEditingController _calcWeightController = TextEditingController();
  final TextEditingController _calcPriceController = TextEditingController();
  bool isCalcReverse = false; // false: weight to price, true: price to weight
  bool isCalcKg = false;

  // Bag State
  final TextEditingController _bagWeightController = TextEditingController();
  List<double> bagItemsGrams = [];
  bool isBagKg = false;

  @override
  void initState() {
    super.initState();
    _calcWeightController.addListener(_onCalcChanged);
    _calcPriceController.addListener(_onCalcChanged);
  }

  void _onCalcChanged() {
    setState(() {});
  }

  double _getEffectiveBaseWeight() {
    return isBaseKg ? baseWeight * 1000 : baseWeight;
  }

  double _calculatePrice(double targetGrams) {
    if (baseWeight == 0) return 0;
    return (basePrice / _getEffectiveBaseWeight()) * targetGrams;
  }

  double _calculateWeight(double price) {
    if (basePrice == 0) return 0;
    return (price / basePrice) * _getEffectiveBaseWeight();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      appBar: AppBar(
        title: const Text('SmartPrice Bag', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.pinkAccent),
            onPressed: () => _showHelpDialog(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBasePriceSetup(),
            const SizedBox(height: 20),
            _buildQuickCalculator(),
            const SizedBox(height: 20),
            _buildBagCombiner(),
            const SizedBox(height: 20),
            _buildQuickPresets(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBasePriceSetup() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.pinkAccent),
                const SizedBox(width: 8),
                Text('Base Reference', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Base Weight'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => baseWeight = double.tryParse(v) ?? 0),
                    controller: TextEditingController(text: baseWeight.toString().replaceAll(RegExp(r'\.0$'), '')),
                  ),
                ),
                const SizedBox(width: 8),
                _buildUnitToggle(isBaseKg, (v) => setState(() => isBaseKg = v)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Base Price (₹)', prefixText: '₹ '),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => basePrice = double.tryParse(v) ?? 0),
              controller: TextEditingController(text: basePrice.toString().replaceAll(RegExp(r'\.0$'), '')),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [100, 250, 500, 1000].map((w) {
                String label = w >= 1000 ? '${w / 1000}kg' : '${w}g';
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    setState(() {
                      if (w >= 1000) {
                        baseWeight = w / 1000;
                        isBaseKg = true;
                      } else {
                        baseWeight = w.toDouble();
                        isBaseKg = false;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCalculator() {
    double result = 0;
    if (isCalcReverse) {
      double p = double.tryParse(_calcPriceController.text) ?? 0;
      result = _calculateWeight(p);
    } else {
      double w = double.tryParse(_calcWeightController.text) ?? 0;
      double grams = isCalcKg ? w * 1000 : w;
      result = _calculatePrice(grams);
    }

    return Card(
      color: Colors.pink.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isCalcReverse ? 'Price to Weight' : 'Weight to Price', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.pink),
                  onPressed: () => setState(() => isCalcReverse = !isCalcReverse),
                )
              ],
            ),
            if (!isCalcReverse) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _calcWeightController,
                      decoration: const InputDecoration(labelText: 'Target Weight'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildUnitToggle(isCalcKg, (v) => setState(() => isCalcKg = v)),
                ],
              ),
              const SizedBox(height: 16),
              Text('₹ ${result.toStringAsFixed(2)}', 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
            ] else ...[
              TextField(
                controller: _calcPriceController,
                decoration: const InputDecoration(labelText: 'Budget (₹)', prefixText: '₹ '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text('${result >= 1000 ? (result / 1000).toStringAsFixed(2) : result.toStringAsFixed(0)} ${result >= 1000 ? 'kg' : 'g'}', 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBagCombiner() {
    double totalGrams = bagItemsGrams.fold(0, (sum, item) => sum + item);
    double totalPrice = _calculatePrice(totalGrams);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.pinkAccent),
                const SizedBox(width: 8),
                Text('Add To Bag', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bagWeightController,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                _buildUnitToggle(isBagKg, (v) => setState(() => isBagKg = v)),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    double w = double.tryParse(_bagWeightController.text) ?? 0;
                    if (w > 0) {
                      setState(() {
                        bagItemsGrams.add(isBagKg ? w * 1000 : w);
                        _bagWeightController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: Colors.pinkAccent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [100, 250, 500, 750].map((w) {
                return ActionChip(
                  label: Text('+$w g'),
                  onPressed: () => setState(() => bagItemsGrams.add(w.toDouble())),
                );
              }).toList(),
            ),
            if (bagItemsGrams.isNotEmpty) ...[
              const Divider(height: 32),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bagItemsGrams.length,
                itemBuilder: (context, index) {
                  double g = bagItemsGrams[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${g >= 1000 ? (g/1000).toStringAsFixed(1) : g.toStringAsFixed(0)}${g >= 1000 ? 'kg' : 'g'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${_calculatePrice(g).toStringAsFixed(1)}'),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => setState(() => bagItemsGrams.removeAt(index)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Weight', style: TextStyle(color: Colors.grey)),
                      Text('${totalGrams >= 1000 ? (totalGrams/1000).toStringAsFixed(2) : totalGrams.toStringAsFixed(0)} ${totalGrams >= 1000 ? 'kg' : 'g'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Price', style: TextStyle(color: Colors.grey)),
                      Text('₹ ${totalPrice.toStringAsFixed(2)}', 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPresets() {
    final presets = [100.0, 250.0, 500.0, 750.0, 1000.0, 2000.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Quick Prices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: presets.length,
          itemBuilder: (context, index) {
            double g = presets[index];
            return Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(g >= 1000 ? '${(g/1000).toStringAsFixed(0)}kg' : '${g.toStringAsFixed(0)}g',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('₹${_calculatePrice(g).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pinkAccent)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUnitToggle(bool isKg, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitButton('g', !isKg, () => onChanged(false)),
          _unitButton('kg', isKg, () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _unitButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.pinkAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use SmartPrice Bag'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Set Reference: Enter the price for a known weight (e.g., 1000g for ₹140).\n\n'
            '2. Quick Calc: Type a weight to see its price instantly, or swap to see how much weight you get for your budget.\n\n'
            '3. Add To Bag: Combine multiple items to see the total weight and total price.\n\n'
            '4. Quick Prices: Check common quantities at a glance at the bottom.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it!'))
        ],
      ),
    );
  }
}
