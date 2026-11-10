import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/jobs_remote_datasource.dart';
import '../../data/repositories/jobs_repository_impl.dart';
import '../../domain/entities/user_job_entity.dart';
import '../../domain/usecases/get_my_jobs_usecase.dart';
import '../../domain/usecases/delete_job_usecase.dart';
import '../bloc/my_jobs_bloc.dart';
import '../bloc/my_jobs_event.dart';
import '../bloc/my_jobs_state.dart';

class MyJobPostsScreen extends StatelessWidget {
  const MyJobPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsRepo = JobsRepositoryImpl(
      remoteDataSource: JobsRemoteDataSourceImpl(),
    );
    return BlocProvider(
      create: (context) => MyJobsBloc(
        getMyJobsUseCase: GetMyJobsUseCase(jobsRepo),
        deleteJobUseCase: DeleteJobUseCase(jobsRepo),
      )..add(const LoadMyJobsEvent(page: 1, limit: 10)),
      child: const _MyJobPostsView(),
    );
  }
}

class _MyJobPostsView extends StatefulWidget {
  const _MyJobPostsView();

  @override
  State<_MyJobPostsView> createState() => _MyJobPostsViewState();
}

class _MyJobPostsViewState extends State<_MyJobPostsView> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Job Posts',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Color(0xFF1E3A8A),
            ),
            tooltip: 'Post a New Job',
            onPressed: () async {
              await context.push(AppRoutes.postJob);
              if (context.mounted) {
                context.read<MyJobsBloc>().add(
                  const LoadMyJobsEvent(refresh: true),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: BlocConsumer<MyJobsBloc, MyJobsState>(
        listenWhen: (previous, current) =>
            (current.successMessage != null &&
                previous.successMessage != current.successMessage) ||
            (current.errorMessage != null &&
                previous.errorMessage != current.errorMessage &&
                current.status != MyJobsStatus.loading),
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF059669),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state.errorMessage != null && state.jobs.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            color: const Color(0xFF1E3A8A),
            onRefresh: () async {
              context.read<MyJobsBloc>().add(
                const LoadMyJobsEvent(refresh: true),
              );
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Top Summary & Filter Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Stats Row
                        _buildStatsHeader(state),
                        const SizedBox(height: 14),
                        // Search Field
                        _buildSearchTextField(context, state),
                        const SizedBox(height: 14),
                        // Filter Pills
                        _buildFilterRow(context, state),
                      ],
                    ),
                  ),
                ),

                // Main Content List
                if (state.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  )
                else if (state.isFailure && state.errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(context, state.errorMessage!),
                  )
                else if (state.filteredJobs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final job = state.filteredJobs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildJobCard(context, job, state),
                        );
                      }, childCount: state.filteredJobs.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(MyJobsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: 'Total Posted',
              value: state.jobs.length.toString(),
              icon: Icons.work_outline_rounded,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
            ),
          ),
          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: _buildStatItem(
              title: 'Active Jobs',
              value: state.activeJobsCount.toString(),
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF059669),
              bgColor: const Color(0xFFECFDF5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context, MyJobsState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
        ),
        textInputAction: TextInputAction.search,
        onChanged: (val) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 400), () {
            context.read<MyJobsBloc>().add(SearchMyJobsEvent(val.trim()));
          });
          setState(() {});
        },
        onSubmitted: (val) {
          _debounceTimer?.cancel();
          context.read<MyJobsBloc>().add(SearchMyJobsEvent(val.trim()));
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          hintText: 'Search by job title, location, or Job ID...',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF1E3A8A),
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _debounceTimer?.cancel();
                    context.read<MyJobsBloc>().add(const SearchMyJobsEvent(''));
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext context, MyJobsState state) {
    const filters = [
      {'key': 'all', 'label': 'All Jobs'},
      {'key': 'active', 'label': 'Active'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'closed', 'label': 'Closed'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = state.selectedStatus == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  context.read<MyJobsBloc>().add(
                    FilterMyJobsByStatusEvent(f['key']!),
                  );
                }
              },
              selectedColor: const Color(0xFF1E3A8A),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    UserJobEntity job,
    MyJobsState state,
  ) {
    final statusColor = _resolveStatusColor(job.status);
    final statusBgColor = _resolveStatusBgColor(job.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final targetJobId = job.jobId.isNotEmpty ? job.jobId : job.id;
          final wasDeleted = await context.push<bool>(
            '${AppRoutes.jobDetails}/$targetJobId',
            extra: job,
          );
          if (wasDeleted == true && context.mounted) {
            context.read<MyJobsBloc>().add(
                  const LoadMyJobsEvent(refresh: true),
                );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Job ID, Status Badge & Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        job.jobId,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                job.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Icon Button
                        _buildDeleteButton(context, job, state),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

              // Job Title
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Salary & Job Type Row
              Row(
                children: [
                  Text(
                    job.formattedSalary,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      job.formattedJobType,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 15,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      job.location.isNotEmpty
                          ? job.location
                          : 'Location specified in contract',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Joining Date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Joining: ${job.formattedJoiningDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Description Snippet
              if (job.description.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Text(
                    job.description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Card Footer: Posted Date
              if (job.formattedCreatedAt.isNotEmpty) ...[
                const Divider(height: 14, color: Color(0xFFF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Posted on ${job.formattedCreatedAt}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Listing',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDeleteButton(
    BuildContext context,
    UserJobEntity job,
    MyJobsState state,
  ) {
    final targetJobId = job.jobId.isNotEmpty ? job.jobId : job.id;
    final isDeleting =
        state.isJobDeleting(targetJobId) ||
        state.isJobDeleting(job.jobId) ||
        (job.id.isNotEmpty && state.isJobDeleting(job.id));

    if (isDeleting) {
      return Container(
        width: 28,
        height: 28,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFDC2626),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _confirmDeleteJob(context, job),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 17,
            color: Color(0xFFDC2626),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteJob(BuildContext context, UserJobEntity job) {
    final targetJobId = job.jobId.isNotEmpty ? job.jobId : job.id;

    showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete Job Post?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this job post?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      job.jobId,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This listing will be permanently removed.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop(true);
                context.read<MyJobsBloc>().add(DeleteMyJobEvent(targetJobId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _resolveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'open':
        return const Color(0xFF059669);
      case 'pending':
        return const Color(0xFFD97706);
      case 'closed':
      case 'completed':
        return const Color(0xFF64748B);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _resolveStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'open':
        return const Color(0xFFECFDF5);
      case 'pending':
        return const Color(0xFFFFFBEB);
      case 'closed':
      case 'completed':
        return const Color(0xFFF1F5F9);
      case 'cancelled':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                size: 48,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Job Posts Yet',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have not posted any driver job requirements yet. Post one to reach verified drivers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () async {
                await context.push(AppRoutes.postJob);
                if (context.mounted) {
                  context.read<MyJobsBloc>().add(
                    const LoadMyJobsEvent(refresh: true),
                  );
                }
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Post a Driver Job',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to Load Jobs',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () {
                context.read<MyJobsBloc>().add(
                  const LoadMyJobsEvent(refresh: true),
                );
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
