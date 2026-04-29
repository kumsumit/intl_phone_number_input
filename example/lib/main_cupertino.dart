import 'package:flutter/cupertino.dart';
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
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Intl Phone Number Input - Cupertino',
      theme: const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue),
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
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Phone Input Playground - Cupertino'),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final content = <Widget>[
              Text(
                'Phone Input Playground',
                style: theme.textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Try selector layouts, formatting, and country detection settings in one place. The preview stays wired to the live widget so it is easy to understand how each option changes behavior.',
                style: theme.textTheme.textStyle,
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
    final theme = CupertinoTheme.of(context);

    return [
      _SectionHeader(
        title: 'Selector',
        caption: 'Choose how the country picker is presented.',
      ),
      const SizedBox(height: 12),
      CupertinoSegmentedControl<PhoneInputSelectorType>(
        groupValue: _selectorType,
        children: const {
          PhoneInputSelectorType.DROPDOWN: Text('Dropdown'),
          PhoneInputSelectorType.BOTTOM_SHEET: Text('Bottom sheet'),
          PhoneInputSelectorType.DIALOG: Text('Dialog'),
        },
        onValueChanged: (value) {
          setState(() {
            _selectorType = value;
          });
        },
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _formatInput = !_formatInput;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _formatInput
                    ? theme.primaryColor.withValues(alpha: 0.2)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Format input',
                style: TextStyle(
                  color: _formatInput
                      ? theme.primaryColor
                      : CupertinoColors.label,
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _prefixSelector = !_prefixSelector;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _prefixSelector
                    ? theme.primaryColor.withValues(alpha: 0.2)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Prefix selector',
                style: TextStyle(
                  color: _prefixSelector
                      ? theme.primaryColor
                      : CupertinoColors.label,
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _ignoreBlank = !_ignoreBlank;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _ignoreBlank
                    ? theme.primaryColor.withValues(alpha: 0.2)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ignore blank',
                style: TextStyle(
                  color: _ignoreBlank
                      ? theme.primaryColor
                      : CupertinoColors.label,
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _disableLengthCheck = !_disableLengthCheck;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _disableLengthCheck
                    ? theme.primaryColor.withValues(alpha: 0.2)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Disable length check',
                style: TextStyle(
                  color: _disableLengthCheck
                      ? theme.primaryColor
                      : CupertinoColors.label,
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _setAutoDetectCountry(!_autoDetectCountry);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _autoDetectCountry
                    ? theme.primaryColor.withValues(alpha: 0.2)
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Auto detect country',
                style: TextStyle(
                  color: _autoDetectCountry
                      ? theme.primaryColor
                      : CupertinoColors.label,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      _SectionHeader(
        title: 'Detection Signals',
        caption: 'Control which signals the built-in detector can use.',
      ),
      const SizedBox(height: 12),
      CupertinoSegmentedControl<CountryDetectionMode>(
        groupValue: _countryDetectionMode,
        children: const {
          CountryDetectionMode.localSignals: Text('Local only'),
          CountryDetectionMode.networkSignals: Text('Local + IP'),
        },
        onValueChanged: (value) {
          setState(() {
            _countryDetectionMode = value;
            _detectedCountryResult = null;
          });
        },
      ),
      const SizedBox(height: 20),
      _SectionHeader(
        title: 'Detection Ordering',
        caption:
            'Choose how detected countries are prioritized in the selector.',
      ),
      const SizedBox(height: 12),
      CupertinoSegmentedControl<DetectedCountryOrderStrategy>(
        groupValue: _detectedCountryOrderStrategy,
        children: const {
          DetectedCountryOrderStrategy.none: Text('Off'),
          DetectedCountryOrderStrategy.detectedCountryFirst: Text('Detected'),
          DetectedCountryOrderStrategy.signalVotesThenDistance: Text(
            'Signals first',
          ),
          DetectedCountryOrderStrategy.signalVotesThenNeighborsThenDistance:
              Text('Signals + neighbors'),
        },
        onValueChanged: (value) {
          setState(() {
            _detectedCountryOrderStrategy = value;
          });
        },
      ),
      const SizedBox(height: 24),
      _SectionHeader(title: 'Live Preview', caption: _helperText),
      const SizedBox(height: 12),
      Form(
        key: _formKey,
        child: CupertinoInternationalPhoneNumber(
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
            titleStyle: theme.textTheme.textStyle,
            subtitleStyle: theme.textTheme.textStyle.copyWith(fontSize: 14),
          ),
          selectorTextStyle: theme.textTheme.textStyle,
          flagStyle: theme.textTheme.textStyle.copyWith(fontSize: 20),
          label: const Text('Phone number'),
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
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Saved'),
                content: Text('Saved ${number.international}'),
                actions: [
                  CupertinoDialogAction(
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
          CupertinoButton.filled(
            onPressed: () {
              final isValid = _formKey.currentState?.validate() ?? false;
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Validation'),
                  content: Text(
                    isValid
                        ? 'The current number is valid.'
                        : 'The current number is invalid.',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Validate'),
          ),
          CupertinoButton(
            onPressed: _setDemoNumber,
            child: const Text('Load sample'),
          ),
          CupertinoButton(onPressed: _clearField, child: const Text('Clear')),
          CupertinoButton(
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
    final theme = CupertinoTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live State', style: theme.textTheme.navTitleTextStyle),
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
              Text(
                'Top Ranked Votes',
                style: theme.textTheme.navTitleTextStyle.copyWith(fontSize: 16),
              ),
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
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: CupertinoTheme.of(context).textTheme.textStyle,
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
    final theme = CupertinoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.navTitleTextStyle),
        const SizedBox(height: 4),
        Text(caption, style: theme.textTheme.textStyle),
      ],
    );
  }
}
