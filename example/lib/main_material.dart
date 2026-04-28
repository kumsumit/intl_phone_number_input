import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'country_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await PhoneMetadataBootstrap.ensureInitialized();
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
      title: 'Intl Phone Number Input - Material',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
  static const String _countryCodeWarningMessage =
      'Enter the local number only. The country code comes from the selector.';
  static const String _helperText =
      'Enter the national number only. The selected country supplies the dial code.';

  late final List<Country> _countries;
  late Country _defaultCountry;

  PhoneInputSelectorType _selectorType = PhoneInputSelectorType.BOTTOM_SHEET;
  bool _formatInput = true;
  bool _prefixSelector = true;
  bool _ignoreBlank = false;
  bool _disableLengthCheck = false;
  bool _autoDetectCountry = true;
  bool? _isValid;
  CountryResult? _detectedCountryResult;
  PhoneNumber _number = const PhoneNumber(isoCode: 'IN', nsn: '');
  CountryDetectionMode _countryDetectionMode =
      CountryDetectionMode.networkSignals;
  DetectedCountryOrderStrategy _detectedCountryOrderStrategy =
      DetectedCountryOrderStrategy.signalVotesThenNeighborsThenDistance;

  @override
  void initState() {
    super.initState();
    _countries = Countries.countryList
        .map((country) => Country.fromJson(country))
        .toList();
    _defaultCountry = _countries.firstWhere(
      (country) => country.alpha2Code == 'IN',
    );
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

  void _setAutoDetectCountry(bool value) {
    setState(() {
      _autoDetectCountry = value;
      if (!value) {
        _detectedCountryResult = null;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Input Playground - Material'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final content = <Widget>[
              Text(
                'Phone Input Playground',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Try selector layouts, formatting, and country detection settings in one place. The preview stays wired to the live widget so it is easy to understand how each option changes behavior.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildControlsColumn(context)),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: _buildStatusCard(context)),
                  ],
                )
              else ...[
                ..._buildControlsChildren(context),
                const SizedBox(height: 24),
                _buildStatusCard(context),
              ],
            ];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: content,
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlsColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildControlsChildren(context),
    );
  }

  List<Widget> _buildControlsChildren(BuildContext context) {
    final theme = Theme.of(context);

    return [
      _SectionHeader(
        title: 'Selector',
        caption: 'Choose how the country picker is presented.',
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
        onSelectionChanged: (value) =>
            setState(() => _selectorType = value.first),
        multiSelectionEnabled: false,
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: _formatInput,
                onChanged: (value) => setState(() => _formatInput = value),
              ),
              const SizedBox(width: 8),
              const Text('Format input'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: _prefixSelector,
                onChanged: (value) => setState(() => _prefixSelector = value),
              ),
              const SizedBox(width: 8),
              const Text('Prefix selector'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: _ignoreBlank,
                onChanged: (value) => setState(() => _ignoreBlank = value),
              ),
              const SizedBox(width: 8),
              const Text('Ignore blank'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: _disableLengthCheck,
                onChanged: (value) => setState(() => _disableLengthCheck = value),
              ),
              const SizedBox(width: 8),
              const Text('Disable length check'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: _autoDetectCountry,
                onChanged: (value) => _setAutoDetectCountry(value),
              ),
              const SizedBox(width: 8),
              const Text('Auto detect country'),
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),
      _SectionHeader(
        title: 'Detection Signals',
        caption: 'Control which signals the built-in detector can use.',
      ),
      const SizedBox(height: 12),
     SegmentedButton<CountryDetectionMode>(
        segments: const [
          ButtonSegment(
            value: CountryDetectionMode.localSignals,
            label: Text('Local only'),
          ),
          ButtonSegment(
            value: CountryDetectionMode.networkSignals,
            label: Text('Local + IP'),
          ),
        ],
        selected: {_countryDetectionMode},
        onSelectionChanged: (value) => setState(() {
          _countryDetectionMode = value.first;
          _detectedCountryResult = null;
        }),
        multiSelectionEnabled: false,
      ),
      const SizedBox(height: 20),
      _SectionHeader(
        title: 'Detection Ordering',
        caption:
            'Choose how detected countries are prioritized in the selector.',
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
            label: Text('Signals first'),
          ),
          ButtonSegment(
            value: DetectedCountryOrderStrategy
                .signalVotesThenNeighborsThenDistance,
            label: Text('Signals + neighbors'),
          ),
        ],
        selected: {_detectedCountryOrderStrategy},
        onSelectionChanged: (value) =>
            setState(() => _detectedCountryOrderStrategy = value.first),
        multiSelectionEnabled: false,
      ),
      const SizedBox(height: 24),
      _SectionHeader(title: 'Live Preview', caption: _helperText),
      const SizedBox(height: 12),
      Form(
        key: _formKey,
        child: MaterialInternationalPhoneNumber(
          key: ValueKey(
            'phone-input-$_autoDetectCountry-$_countryDetectionMode-$_detectedCountryOrderStrategy',
          ),
          countries: _countries,
          defaultCountry: _defaultCountry,
          filterFunction: _filterCountries,
          textFieldController: _controller,
          autoDetectCountry: _autoDetectCountry,
          countryDetectionMode: _countryDetectionMode,
          detectedCountryOrderStrategy: _detectedCountryOrderStrategy,
          formatInput: _formatInput,
          ignoreBlank: _ignoreBlank,
          disableLengthCheck: _disableLengthCheck,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          countryCodeWarningMessage: _countryCodeWarningMessage,
          selectorConfig: SelectorConfig(
            selectorType: _selectorType,
            setSelectorButtonAsPrefixIcon: _prefixSelector,
            useBottomSheetSafeArea: true,
            titleStyle: theme.textTheme.bodyMedium,
            subtitleStyle: theme.textTheme.bodySmall,
          ),
          selectorTextStyle: theme.textTheme.bodyMedium,
          flagStyle: theme.textTheme.bodyMedium,
          hintText: 'Phone number',
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
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Saved'),
                content: Text('Saved ${number.international}'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: () {
              final isValid = _formKey.currentState?.validate() ?? false;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Validation'),
                  content: Text(
                    isValid
                        ? 'The current number is valid.'
                        : 'The current number is invalid.',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Validate'),
          ),
          OutlinedButton(
            onPressed: _setDemoNumber,
            child: const Text('Load sample'),
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
    ];
  }

  Widget _buildStatusCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live State', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatusRow(label: 'Validation', value: _statusLabel(_isValid)),
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
              value: _number.nsn.isNotEmpty ? _number.international : 'Empty',
            ),
            _StatusRow(
              label: 'Detected country',
              value: _detectedCountryResult?.countryCode ?? 'None',
            ),
            _StatusRow(
              label: 'Detection mode',
              value: _detectionModeLabel(_countryDetectionMode),
            ),
            _StatusRow(
              label: 'Ordering',
              value: _orderingLabel(_detectedCountryOrderStrategy),
            ),
            _StatusRow(
              label: 'Detection confidence',
              value: _detectedCountryResult != null
                  ? '${_detectedCountryResult!.confidence}%'
                  : 'None',
            ),
            if (_detectedCountryResult != null &&
                _detectedCountryResult!.allVotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Top Ranked Votes', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ..._detectedCountryResult!.allVotes.entries
                  .take(6)
                  .map(
                    (entry) => _StatusRow(
                      label: entry.key,
                      value: '${entry.value} pts',
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(bool? value) {
    if (value == null) {
      return 'Not checked yet';
    }
    return value ? 'Valid' : 'Invalid';
  }

  String _detectionModeLabel(CountryDetectionMode mode) {
    switch (mode) {
      case CountryDetectionMode.localSignals:
        return 'Local only';
      case CountryDetectionMode.networkSignals:
        return 'Local + IP';
    }
  }

  String _orderingLabel(DetectedCountryOrderStrategy strategy) {
    switch (strategy) {
      case DetectedCountryOrderStrategy.none:
        return 'Original list order';
      case DetectedCountryOrderStrategy.detectedCountryFirst:
        return 'Detected country first';
      case DetectedCountryOrderStrategy.signalVotesThenDistance:
        return 'Detected, then signals, then distance';
      case DetectedCountryOrderStrategy.signalVotesThenNeighborsThenDistance:
        return 'Detected, then signals, then neighbors';
    }
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
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(caption, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}