import 'dart:convert';
import 'package:http/http.dart' as http;

/// EmailJS service — sends emails directly from Flutter without a backend.
/// Setup: https://emailjs.com (free: 200 emails/month)
///
/// HOW TO SET UP:
/// 1. Go to emailjs.com → Create account
/// 2. Add Email Service → Connect Gmail (maskiryz23@gmail.com)
/// 3. Create Email Templates (one per notification type)
/// 4. Replace the placeholders below with your actual IDs
class EmailService {
  // ⚠️ REPLACE THESE with your EmailJS credentials after setup:
  static const String _serviceId = 'YOUR_SERVICE_ID';   // e.g. 'service_abc123'
  static const String _publicKey = 'YOUR_PUBLIC_KEY';    // e.g. 'user_xxxx'

  // Template IDs — create these in EmailJS dashboard
  static const String _welcomeTemplateId = 'template_welcome';
  static const String _orderTemplateId = 'template_order';
  static const String _donationTemplateId = 'template_donation';
  static const String _refundTemplateId = 'template_refund';
  static const String _statusTemplateId = 'template_status';

  static const String _apiUrl =
      'https://api.emailjs.com/api/v1.0/email/send';

  static Future<void> _send(
      String templateId, Map<String, String> params) async {
    try {
      await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': templateId,
          'user_id': _publicKey,
          'template_params': params,
        }),
      );
    } catch (e) {
      // Non-blocking — email failure should not break the app
      print('EmailJS error: $e');
    }
  }

  /// Send welcome email on register
  static Future<void> sendWelcome({
    required String toName,
    required String toEmail,
  }) async {
    await _send(_welcomeTemplateId, {
      'to_name': toName,
      'to_email': toEmail,
      'app_name': 'RecycleMate',
    });
  }

  /// Send order confirmation to buyer
  static Future<void> sendOrderConfirmation({
    required String buyerName,
    required String buyerEmail,
    required String productName,
    required int quantity,
    required int totalPrice,
    required String crafterName,
  }) async {
    await _send(_orderTemplateId, {
      'to_name': buyerName,
      'to_email': buyerEmail,
      'product_name': productName,
      'quantity': quantity.toString(),
      'total_price': 'Rp ${_fmt(totalPrice)}',
      'crafter_name': crafterName,
    });
  }

  /// Send donation confirmation
  static Future<void> sendDonationConfirmation({
    required String donorName,
    required String donorEmail,
    required String itemName,
    required String material,
    required int quantity,
  }) async {
    await _send(_donationTemplateId, {
      'to_name': donorName,
      'to_email': donorEmail,
      'item_name': itemName,
      'material': material,
      'quantity': quantity.toString(),
    });
  }

  /// Send refund notification
  static Future<void> sendRefundNotification({
    required String buyerName,
    required String buyerEmail,
    required String productName,
    required int totalPrice,
    required String reason,
  }) async {
    await _send(_refundTemplateId, {
      'to_name': buyerName,
      'to_email': buyerEmail,
      'product_name': productName,
      'total_price': 'Rp ${_fmt(totalPrice)}',
      'reason': reason.isNotEmpty ? reason : 'Tidak disebutkan',
    });
  }

  /// Send status update
  static Future<void> sendStatusUpdate({
    required String buyerName,
    required String buyerEmail,
    required String productName,
    required String status,
  }) async {
    final statusLabels = {
      'paid': 'Pembayaran Diterima ✅',
      'shipped': 'Sedang Dikirim 🚚',
      'completed': 'Pesanan Selesai 🎉',
      'cancelled': 'Pesanan Dibatalkan ❌',
      'refunded': 'Refund Berhasil 💰',
    };
    await _send(_statusTemplateId, {
      'to_name': buyerName,
      'to_email': buyerEmail,
      'product_name': productName,
      'status': statusLabels[status] ?? status,
    });
  }

  static String _fmt(int price) => price
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
