import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/usecases/add_money_usecase.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletBloc(
        getWalletUseCase: context.read<GetWalletUseCase>(),
        addMoneyUseCase: context.read<AddMoneyUseCase>(),
      )..add(const LoadWalletEvent()),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> {
  final TextEditingController _amountController = TextEditingController();
  final List<double> _quickAmounts = [100, 200, 500, 1000];
  String _selectedFilter = 'All'; // 'All', 'Credit', 'Debit'

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onQuickAmountTap(double amount) {
    setState(() {
      _amountController.text = amount.toInt().toString();
    });
  }

  void _handleAddMoney(BuildContext context) {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.read<WalletBloc>().add(
      AddMoneyToWalletEvent(
        amount: amount,
        paymentMethod: 'UPI / Cards (Rapido Wallet)',
      ),
    );
    _amountController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: () {
              context.read<WalletBloc>().add(const RefreshWalletEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listenWhen: (previous, current) {
          if (current is WalletLoaded && current.successMessage != null) {
            return previous is! WalletLoaded ||
                previous.successMessage != current.successMessage;
          }
          if (current is WalletError) {
            return previous is! WalletError ||
                previous.message != current.message;
          }
          return false;
        },
        listener: (context, state) {
          if (state is WalletLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red.shade600,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading && state.currentWallet == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final wallet = state is WalletLoaded
              ? state.wallet
              : (state is WalletLoading
                    ? state.currentWallet
                    : (state is WalletError ? state.currentWallet : null));

          final currentBalance = wallet?.balance ?? 450.0;
          final allTxns = wallet?.transactions ?? [];

          final filteredTxns = allTxns.where((txn) {
            if (_selectedFilter == 'Credit') {
              return txn.type == TransactionType.credit;
            } else if (_selectedFilter == 'Debit') {
              return txn.type == TransactionType.debit;
            }
            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WalletBloc>().add(const RefreshWalletEvent());
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Rapido-Style Balance Card
                  _buildBalanceCard(currentBalance),

                  const SizedBox(height: 20),

                  // Add Cash / Recharge Card
                  _buildAddMoneyCard(context, state is WalletLoading),

                  const SizedBox(height: 24),

                  // Transactions Header & Filters
                  _buildTransactionsSection(filteredTxns),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9500).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient Soft Top-Right Shimmer
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Abstract Concentric Ring for Fintech Depth
            Positioned(
              top: -45,
              right: -45,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 26,
                  ),
                ),
              ),
            ),

            // Decorative Background Emblem
            Positioned(
              right: 18,
              bottom: 40,
              child: Icon(
                Icons.contactless_rounded,
                size: 48,
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),

            // Foreground Card Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Wallet Emblem + Title + 100% Safe Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFFFFC72C),
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Car Driver Wallet',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                'Prepaid & Instant Refunds',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF16A34A),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '100% Safe',
                              style: TextStyle(
                                color: Color(0xFF14532D),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Total Balance Label
                  const Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Balance Amount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        balance.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bottom feature pill banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFF0F172A),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Instant 1-click checkout & auto-refunds on cancel',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoneyCard(BuildContext context, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Money to Wallet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recharge for quick and seamless bookings',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          // Amount Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter amount (e.g. 500)',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (_amountController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _amountController.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Quick amount preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts.map((amount) {
              final isSelected =
                  _amountController.text == amount.toInt().toString();
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _onQuickAmountTap(amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD97706)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '+ ₹${amount.toInt()}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFB45309)
                          : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          // Add Cash Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _handleAddMoney(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5FB),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Add Cash to Wallet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(List<WalletTransactionEntity> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // Filter Pills
            Row(
              children: ['All', 'Credit', 'Debit'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black87 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.black87
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No transactions found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade100,
                indent: 64,
              ),
              itemBuilder: (context, index) {
                final txn = transactions[index];
                final isCredit = txn.type == TransactionType.credit;
                final formattedDate = DateFormat(
                  'dd MMM yyyy, hh:mm a',
                ).format(txn.timestamp);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isCredit
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF475569),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              txn.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isCredit ? '+' : '-'} ₹${txn.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isCredit
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Success',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
