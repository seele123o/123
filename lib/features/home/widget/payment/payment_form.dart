// lib/features/home/widget/payment/payment_form.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/payment_config_model.dart';
import 'package:hiddify/features/panel/xboard/models/order_model.dart';
import 'package:hiddify/features/panel/xboard/providers/payment_providers.dart';
import './card_input_field.dart';
import './card_expiry_input.dart';
import './card_cvv_input.dart';
import './payment_summary.dart';

final paymentFormProvider = StateNotifierProvider.autoDispose<PaymentFormNotifier, PaymentFormState>((ref) {
  return PaymentFormNotifier();
});

class PaymentFormState {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final bool isValid;
  final bool isSaving;
  final String? error;
  final String? detectedCardBrand;

  PaymentFormState({
    this.cardNumber = '',
    this.expiryDate = '',
    this.cvv = '',
    this.cardHolderName = '',
    this.isValid = false,
    this.isSaving = false,
    this.error,
    this.detectedCardBrand,
  });

  PaymentFormState copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? cardHolderName,
    bool? isValid,
    bool? isSaving,
    String? error,
    String? detectedCardBrand,
  }) {
    return PaymentFormState(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      isValid: isValid ?? this.isValid,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      detectedCardBrand: detectedCardBrand ?? this.detectedCardBrand,
    );
  }
}

class PaymentForm extends ConsumerStatefulWidget {
  final PaymentProvider provider;
  final double amount;
  final double? fee;
  final String? description;
  final Function(Map<String, dynamic> formData) onSubmit;
  final VoidCallback? onCancel;

  const PaymentForm({
    Key? key,
    required this.provider,
    required this.amount,
    this.fee,
    this.description,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);
    final formState = ref.watch(paymentFormProvider);
    final config = ref.watch(paymentConfigProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentSummary(
          amount: widget.amount,
          fee: widget.fee,
          description: widget.description,
          onEditPressed: widget.onCancel,
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.provider == PaymentProvider.stripe) ...[
                _buildCardNumberSection(formState, t),
                const SizedBox(height: 16),
                _buildCardDetailsSection(formState, t),
                const SizedBox(height: 16),
                _buildCardHolderSection(formState, t),
                if (config != null) _buildSupportedCardsSection(config, formState.detectedCardBrand),
              ],
              const SizedBox(height: 24),
              _buildActionButtons(formState, t),
              if (widget.provider == PaymentProvider.stripe) _buildSecurityNote(t),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardNumberSection(PaymentFormState state, Translations t) {
    return CardInputField(
      controller: _cardNumberController,
      label: t.payment['form']['card_number'] ?? 'Card Number',
      hint: '1234 5678 9012 3456',
      keyboardType: TextInputType.number,
      formatters: [CardNumberFormatter()],
      validator: _validateCardNumber,
      enabled: !state.isSaving,
      onChanged: (value) {
        ref.read(paymentFormProvider.notifier).updateCardNumber(value);
      },
      prefixIcon: Icons.credit_card,
      suffixIcon: state.detectedCardBrand != null
          ? Image.asset(
              'assets/images/payment/card_brands/${state.detectedCardBrand}.png',
              width: 24,
              height: 24,
            )
          : null,
    );
  }

  Widget _buildCardDetailsSection(PaymentFormState state, Translations t) {
    return Row(
      children: [
        Expanded(
          child: CardExpiryInput(
            controller: _expiryController,
            enabled: !state.isSaving,
            onChanged: (value) {
              ref.read(paymentFormProvider.notifier).updateExpiry(value);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CardCVVInput(
            controller: _cvvController,
            enabled: !state.isSaving,
            onChanged: (value) {
              ref.read(paymentFormProvider.notifier).updateCVV(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardHolderSection(PaymentFormState state, Translations t) {
    return CardInputField(
      controller: _nameController,
      label: t.payment['form']['cardholder_name'] ?? 'Cardholder Name',
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      validator: _validateName,
      enabled: !state.isSaving,
      onChanged: (value) {
        ref.read(paymentFormProvider.notifier).updateCardHolderName(value);
      },
      prefixIcon: Icons.person_outline,
    );
  }

  Widget _buildSupportedCardsSection(PaymentConfigModel config, String? selectedBrand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Supported Cards',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: config.supportedCardBrands.map((brand) {
            final isSelected = brand == selectedBrand;
            return Image.asset(
              'assets/images/payment/card_brands/$brand.png',
              height: 24,
              color: isSelected ? null : Colors.grey.withOpacity(0.5),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(PaymentFormState state, Translations t) {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          OutlinedButton(
            onPressed: state.isSaving ? null : widget.onCancel,
            child: Text(t.general.cancel),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: state.isSaving ? null : _handleSubmit,
            child: state.isSaving ? const CircularProgressIndicator() : Text(t.payment['actions']['pay_now'] ?? 'Pay Now'),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote(Translations t) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 16),
          const SizedBox(width: 8),
          Text(
            t.payment['form']['security_note'] ?? 'Secure payment',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    final cleanNumber = value.replaceAll(' ', '');
    if (!isValidCardNumber(cleanNumber)) {
      return 'Invalid card number';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name is too short';
    }
    return null;
  }

  bool isValidCardNumber(String number) {
    if (number.length < 13 || number.length > 19) return false;

    // Luhn算法验证
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final formData = {
        'provider': widget.provider.name,
        'card_number': _cardNumberController.text.replaceAll(' ', ''),
        'expiry': _expiryController.text,
        'cvv': _cvvController.text,
        'name': _nameController.text,
      };

      widget.onSubmit(formData);
    }
  }
}

// 支付表单状态管理
class PaymentFormNotifier extends StateNotifier<PaymentFormState> {
  PaymentFormNotifier() : super(PaymentFormState());

  void updateCardNumber(String value) {
    final cleanNumber = value.replaceAll(' ', '');
    String? brand = _detectCardBrand(cleanNumber);

    state = state.copyWith(
      cardNumber: value,
      detectedCardBrand: brand,
      isValid: _validateForm(),
    );
  }

  void updateExpiry(String value) {
    state = state.copyWith(
      expiryDate: value,
      isValid: _validateForm(),
    );
  }

  void updateCVV(String value) {
    state = state.copyWith(
      cvv: value,
      isValid: _validateForm(),
    );
  }

  void updateCardHolderName(String value) {
    state = state.copyWith(
      cardHolderName: value,
      isValid: _validateForm(),
    );
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isSaving: processing);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  String? _detectCardBrand(String number) {
    if (number.startsWith('4')) {
      return 'visa';
    } else if (number.startsWith('5')) {
      return 'mastercard';
    } else if (number.startsWith('3')) {
      return 'amex';
    } else if (number.startsWith('6')) {
      return 'discover';
    }
    return null;
  }

  bool _validateForm() {
    return state.cardNumber.length >= 13 && state.expiryDate.length == 5 && state.cvv.length >= 3 && state.cardHolderName.length >= 3;
  }
}
