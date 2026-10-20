import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/kids_screen_background.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/common/widgets/responsive/max_width_wrapper.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/features/app_support/models/support_transaction_model.dart';
import 'package:ecommerce_app/features/app_support/services/app_support_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class SupportHistoryScreen extends StatefulWidget {
  const SupportHistoryScreen({super.key});

  @override
  State<SupportHistoryScreen> createState() => _SupportHistoryScreenState();
}

class _SupportHistoryScreenState extends State<SupportHistoryScreen> {
  final AppSupportService _service = AppSupportService();
  final transactions = <SupportTransactionModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    if (_userId.isEmpty) {
      transactions.clear();
      errorMessage.value = 'Please sign in to view your support history.';
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _service.getMyTransactions(userId: _userId);
      transactions.value = list;
    } catch (error) {
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load support history. Please try again.',
      );
      if (!mounted) return;
      PLoaders.errorSnackBar(
        title: 'History Unavailable',
        message: errorMessage.value,
        context: context,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'My Support History',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      backgroundColor: const Color(0xFFE9F3EF),
      body: KidsScreenBackground(
        child: RefreshIndicator(
          onRefresh: fetchTransactions,
          child: Obx(() {
            if (isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (errorMessage.value.isNotEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage.value,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: const Color(0xFF52656D),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: fetchTransactions,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (transactions.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.82),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF526F83)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite_outline_rounded,
                                size: 48,
                                color: PColors.primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'No support transactions yet',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF52656D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return MaxWidthWrapper(
                  child: _TransactionCard(transaction: tx),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final SupportTransactionModel transaction;

  const _TransactionCard({required this.transaction});

  Color _statusColor() {
    switch (transaction.status) {
      case 'completed':
        return PColors.success;
      case 'pending_verification':
        return PColors.warning;
      case 'failed':
        return PColors.error;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel() {
    switch (transaction.status) {
      case 'completed':
        return 'Completed';
      case 'pending_verification':
        return 'Pending Verification';
      case 'failed':
        return 'Failed';
      default:
        return transaction.status;
    }
  }

  String _paymentMethodLabel() {
    switch (transaction.paymentMethod) {
      case 'stripe':
        return 'Card';
      case 'jazzcash':
        return 'JazzCash';
      case 'easypaisa':
        return 'EasyPaisa';
      case 'sadapay':
        return 'SadaPay';
      case 'nayapay':
        return 'NayaPay';
      case 'meezan_bank':
        return 'Meezan Bank';
      default:
        return transaction.paymentMethod;
    }
  }

  String _formattedDate() {
    if (transaction.createdAt == null) return '';
    try {
      final dt = DateTime.parse(transaction.createdAt!);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return transaction.createdAt!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'PKR ${transaction.amount.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (transaction.currency != 'PKR') ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        transaction.currency,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: PColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _paymentMethodLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: PColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    _formattedDate(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              if (transaction.paymentMethod != 'stripe' &&
                  transaction.screenshotUrl != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Screenshot submitted',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          );

          final statusBadge = Container(
            constraints: const BoxConstraints(maxWidth: 170),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _statusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusLabel(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _statusColor(),
              ),
            ),
          );

          if (constraints.maxWidth < 340) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 8),
                statusBadge,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 10),
              statusBadge,
            ],
          );
        },
      ),
    );
  }
}
