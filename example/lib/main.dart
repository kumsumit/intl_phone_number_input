import 'dart:io';

import 'package:example/country_list.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  try {
    await MetadataFinder.readMetadataJson(appDocDir.path);
  } catch (e) {
    // Metadata download failed, continue with app
    debugPrint('Metadata download failed: $e');
  }
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intl Phone Number Input',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  late final List<Country> _countries;
  late final Country _defaultCountry;

  PhoneInputSelectorType _selectorType = PhoneInputSelectorType.BOTTOM_SHEET;
  bool _formatInput = true;
  bool _prefixSelector = true;
  bool _ignoreBlank = false;
  bool _disableLengthCheck = false;
  bool _autoDetectCountry = false;
  bool? _isValid;
  CountryResult? _detectedCountryResult;
  PhoneNumber _number = const PhoneNumber(isoCode: 'IN', nsn: '');
  DetectedCountryOrderStrategy _detectedCountryOrderStrategy =
      DetectedCountryOrderStrategy.signalVotesThenDistance;

  @override
  void initState() {
    super.initState();
    _countries = Countries.countryList
        .map((country) => Country.fromJson(country))
        .toList();
    _defaultCountry = _countries.firstWhere(
      (country) => country.alpha2Code == 'IN',
    );
    _progressiveCountryDetection();
  }

  Future<void> _progressiveCountryDetection() async {
    // Step 1: Local signals detection (instant)
    try {
      final localResult = await CountryDetector.detectSync();
      if (localResult.countryCode != null &&
          localResult.countryCode!.isNotEmpty &&
          localResult.countryCode != _defaultCountry.alpha2Code) {
        final detectedCountry = _countries.where(
          (country) => country.alpha2Code == localResult.countryCode,
        );
        if (detectedCountry.isNotEmpty) {
          setState(() {
            _defaultCountry = detectedCountry.first;
          });
        }
      }
    } catch (e) {
      // Continue to network detection
    }

    // Step 2: Full detection including IP (async, more accurate)
    try {
      final fullResult = await CountryDetector.detect();
      if (fullResult.countryCode != null &&
          fullResult.countryCode!.isNotEmpty &&
          fullResult.countryCode != _defaultCountry.alpha2Code) {
        final detectedCountry = _countries.where(
          (country) => country.alpha2Code == fullResult.countryCode,
        );
        if (detectedCountry.isNotEmpty) {
          setState(() {
            _defaultCountry = detectedCountry.first;
          });
        }
      }
    } catch (e) {
      // Fallback to current default
    }
  }

  List<Country> _filterCountries(String value) {
    return _countries.where((country) => country.matches(value)).toList();
  }

  void _setDemoNumber() {
    setState(() {
      _number = const PhoneNumber(isoCode: 'US', nsn: '6505551234');
    });
  }

  void _clearField() {
    _controller.clear();
    setState(() {
      _number = const PhoneNumber(isoCode: 'IN', nsn: '');
      _isValid = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Intl Phone Number Input')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Example', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Switch selector modes, try auto country detection, and validate the current input.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Selector mode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<PhoneInputSelectorType>(
              segments: const [
                ButtonSegment(
                  value: PhoneInputSelectorType.DROPDOWN,
                  label: Text('Dropdown'),
                ),
                ButtonSegment(
                  value: PhoneInputSelectorType.BOTTOM_SHEET,
                  label: Text('Bottom sheet'),
                ),
                ButtonSegment(
                  value: PhoneInputSelectorType.DIALOG,
                  label: Text('Dialog'),
                ),
              ],
              selected: {_selectorType},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectorType = selection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Format input'),
                  selected: _formatInput,
                  onSelected: (value) {
                    setState(() {
                      _formatInput = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Prefix selector'),
                  selected: _prefixSelector,
                  onSelected: (value) {
                    setState(() {
                      _prefixSelector = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Ignore blank'),
                  selected: _ignoreBlank,
                  onSelected: (value) {
                    setState(() {
                      _ignoreBlank = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Disable length check'),
                  selected: _disableLengthCheck,
                  onSelected: (value) {
                    setState(() {
                      _disableLengthCheck = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Auto detect country'),
                  selected: _autoDetectCountry,
                  onSelected: (value) {
                    setState(() {
                      _autoDetectCountry = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Detected country ordering',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<DetectedCountryOrderStrategy>(
              segments: const [
                ButtonSegment(
                  value: DetectedCountryOrderStrategy.none,
                  label: Text('Off'),
                ),
                ButtonSegment(
                  value: DetectedCountryOrderStrategy.detectedCountryFirst,
                  label: Text('Detected'),
                ),
                ButtonSegment(
                  value: DetectedCountryOrderStrategy.signalVotesThenDistance,
                  label: Text('Signals'),
                ),
                ButtonSegment(
                  value: DetectedCountryOrderStrategy
                      .signalVotesThenNeighborsThenDistance,
                  label: Text('Signals + near'),
                ),
              ],
              selected: {_detectedCountryOrderStrategy},
              onSelectionChanged: (selection) {
                setState(() {
                  _detectedCountryOrderStrategy = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: InternationalPhoneNumberInput(
                countries: _countries,
                defaultCountry: _defaultCountry,
                filterFunction: _filterCountries,
                textFieldController: _controller,
                autoDetectCountry: _autoDetectCountry,
                detectedCountryOrderStrategy: _detectedCountryOrderStrategy,
                formatInput: _formatInput,
                ignoreBlank: _ignoreBlank,
                disableLengthCheck: _disableLengthCheck,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                selectorConfig: SelectorConfig(
                  selectorType: _selectorType,
                  setSelectorButtonAsPrefixIcon: _prefixSelector,
                  useBottomSheetSafeArea: true,
                  titleStyle: Theme.of(context).textTheme.bodyLarge,
                  subtitleStyle: Theme.of(context).textTheme.bodySmall,
                ),
                selectorTextStyle: Theme.of(context).textTheme.bodyMedium,
                flagStyle: Theme.of(context).textTheme.titleLarge,
                inputBorder: const OutlineInputBorder(),
                inputDecoration: const InputDecoration(
                  labelText: 'Phone number',
                  helperText: 'Try changing the selector mode above.',
                ),
                onInputChanged: (number) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _number = number;
                      });
                    }
                  });
                },
                onInputValidated: (isValid) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isValid = isValid;
                      });
                    }
                  });
                },
                onAutoCountryDetected: (result) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _detectedCountryResult = result;
                      });
                    }
                  });
                },
                onSaved: (number) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved ${number.international}')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isValid
                              ? 'Current value is valid'
                              : 'Current value is invalid',
                        ),
                      ),
                    );
                  },
                  child: const Text('Validate'),
                ),
                OutlinedButton(
                  onPressed: _setDemoNumber,
                  child: const Text('Load demo number'),
                ),
                OutlinedButton(
                  onPressed: _clearField,
                  child: const Text('Clear'),
                ),
                OutlinedButton(
                  onPressed: () {
                    _formKey.currentState?.save();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current value',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _StatusRow(
                      label: 'Validation',
                      value: _statusLabel(_isValid),
                    ),
                    _StatusRow(
                      label: 'ISO code',
                      value: _number.isoCode.isNotEmpty
                          ? _number.isoCode
                          : 'Unavailable',
                    ),
                    _StatusRow(
                      label: 'National number',
                      value: _number.nsn.isNotEmpty ? _number.nsn : 'Empty',
                    ),
                    _StatusRow(
                      label: 'International',
                      value: _number.nsn.isNotEmpty
                          ? _number.international
                          : 'Empty',
                    ),
                    _StatusRow(
                      label: 'Detected country',
                      value: _detectedCountryResult?.countryCode ?? 'None',
                    ),
                    _StatusRow(
                      label: 'Detection confidence',
                      value: _detectedCountryResult != null
                          ? '${_detectedCountryResult!.confidence}%'
                          : 'None',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(bool? value) {
    if (value == null) {
      return 'Not checked';
    }
    return value ? 'Valid' : 'Invalid';
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
