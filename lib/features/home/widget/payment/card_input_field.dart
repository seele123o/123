// lib/features/home/widget/payment/card_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CardInputField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final int? maxLength;

  const CardInputField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.formatters,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.maxLength,
  }) : super(key: key);

  @override
  _CardInputFieldState createState() => _CardInputFieldState();
}

class _CardInputFieldState extends ConsumerState<CardInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isFocused ? theme.colorScheme.primary : theme.dividerColor,
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        initialValue: widget.initialValue,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: widget.validator,
        onChanged: widget.onChanged,
        inputFormatters: widget.formatters,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}

// lib/features/home/widget/payment/card_expiry_input.dart
class CardExpiryInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final Function(String)? onChanged;

  const CardExpiryInput({
    Key? key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardInputField(
      controller: controller,
      label: 'Expiry Date',
      hint: 'MM/YY',
      keyboardType: TextInputType.number,
      formatters: [
        ExpiryDateFormatter(),
        LengthLimitingTextInputFormatter(5),
      ],
      validator: _validateExpiry,
      enabled: enabled,
      onChanged: onChanged,
      prefixIcon: Icons.calendar_today,
    );
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (!value.contains('/')) {
      return 'Invalid format';
    }

    final parts = value.split('/');
    if (parts.length != 2) return 'Invalid format';

    try {
      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');

      if (month < 1 || month > 12) {
        return 'Invalid month';
      }

      final now = DateTime.now();
      final expiry = DateTime(year, month);
      if (expiry.isBefore(now)) {
        return 'Card expired';
      }
    } catch (e) {
      return 'Invalid date';
    }
    return null;
  }
}

// lib/features/home/widget/payment/card_cvv_input.dart
class CardCVVInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final Function(String)? onChanged;

  const CardCVVInput({
    Key? key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardInputField(
      controller: controller,
      label: 'CVV',
      hint: '123',
      keyboardType: TextInputType.number,
      formatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: _validateCVV,
      enabled: enabled,
      onChanged: onChanged,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
    );
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'Invalid CVV';
    }
    return null;
  }
}

// lib/features/home/widget/payment/payment_summary.dart
class PaymentSummary extends StatelessWidget {
  final double amount;
  final String currency;
  final double? fee;
  final String? description;
  final VoidCallback? onEditPressed;

  const PaymentSummary({
    Key? key,
    required this.amount,
    this.currency = '¥',
    this.fee,
    this.description,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAmount = amount + (fee ?? 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Summary',
                  style: theme.textTheme.titleMedium,
                ),
                if (onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditPressed,
                    tooltip: 'Edit payment',
                  ),
              ],
            ),
            const Divider(height: 24),
            if (description != null) ...[
              Text(
                description!,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            _buildAmountRow('Subtotal', amount),
            if (fee != null && fee! > 0) _buildAmountRow('Processing Fee', fee!),
            const Divider(height: 24),
            _buildAmountRow(
              'Total',
              totalAmount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '$currency${amount.toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }
}
