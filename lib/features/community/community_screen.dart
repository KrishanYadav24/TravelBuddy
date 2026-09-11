import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/community.dart';
import '../../models/mock_destinations.dart';
import 'providers/community_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Hub',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.people_outline, size: 20), text: 'Find Buddies'),
            Tab(icon: Icon(Icons.forum_outlined, size: 20), text: 'Ask Community'),
          ],
        ),
      ),
      endDrawer: const DebugNavigationDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindBuddiesTab(context, ref),
          _buildAskCommunityTab(context, ref),
        ],
      ),
    );
  }

  // ===========================================================================
  // Tab 1: Find Buddies Feed
  // ===========================================================================
  Widget _buildFindBuddiesTab(BuildContext context, WidgetRef ref) {
    final asyncPosts = ref.watch(filteredBuddyPostsProvider);
    final filter = ref.watch(buddyFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          // Filter Chips Row
          _buildFilterRow(context, ref, filter),

          Expanded(
            child: asyncPosts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading posts: $err')),
              data: (posts) {
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        const Text('No buddy posts match your filter', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(buddyFilterProvider.notifier).reset();
                          },
                          child: const Text('Clear Filters', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildBuddyPostCard(context, ref, post);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Find Buddies', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, WidgetRef ref, BuddyFeedFilter filter) {
    final states = [
      'Uttarakhand',
      'Himachal Pradesh',
      'Karnataka',
      'Ladakh',
      'Sikkim',
      'Kerala',
    ];

    final activities = [
      'Trekking',
      'Motorcycling',
      'Rock Climbing',
      'Kayaking',
      'Rafting',
      'Camping',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // State Dropdown Chip
            PopupMenuButton<String>(
              onSelected: (val) {
                final cur = ref.read(buddyFilterProvider);
                if (val == 'ALL') {
                  ref.read(buddyFilterProvider.notifier).updateFilter(cur.copyWith(clearState: true));
                } else {
                  ref.read(buddyFilterProvider.notifier).updateFilter(cur.copyWith(stateFilter: val));
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'ALL', child: Text('All States')),
                ...states.map((s) => PopupMenuItem(value: s, child: Text(s))),
              ],
              child: Chip(
                avatar: const Icon(Icons.map, size: 16, color: AppColors.primary),
                label: Text(
                  filter.stateFilter ?? 'State: All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: filter.stateFilter != null ? FontWeight.bold : FontWeight.normal,
                    color: filter.stateFilter != null ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                backgroundColor: filter.stateFilter != null
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.background,
              ),
            ),
            const SizedBox(width: 8),

            // Activity Type Dropdown Chip
            PopupMenuButton<String>(
              onSelected: (val) {
                final cur = ref.read(buddyFilterProvider);
                if (val == 'ALL') {
                  ref.read(buddyFilterProvider.notifier).updateFilter(cur.copyWith(clearActivity: true));
                } else {
                  ref.read(buddyFilterProvider.notifier).updateFilter(cur.copyWith(activityFilter: val));
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'ALL', child: Text('All Activities')),
                ...activities.map((a) => PopupMenuItem(value: a, child: Text(a))),
              ],
              child: Chip(
                avatar: const Icon(Icons.hiking, size: 16, color: AppColors.accent),
                label: Text(
                  filter.activityFilter ?? 'Activity: All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: filter.activityFilter != null ? FontWeight.bold : FontWeight.normal,
                    color: filter.activityFilter != null ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
                backgroundColor: filter.activityFilter != null
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : AppColors.background,
              ),
            ),
            const SizedBox(width: 8),

            // Fitness Level Filter Chip
            PopupMenuButton<FitnessLevel>(
              onSelected: (level) {
                final cur = ref.read(buddyFilterProvider);
                ref.read(buddyFilterProvider.notifier).updateFilter(cur.copyWith(fitnessFilter: level));
              },
              itemBuilder: (ctx) => FitnessLevel.values
                  .map((f) => PopupMenuItem(value: f, child: Text(f.displayName)))
                  .toList(),
              child: Chip(
                avatar: const Icon(Icons.fitness_center, size: 16, color: Colors.orange),
                label: Text(
                  filter.fitnessFilter != null
                      ? 'Fitness: ${filter.fitnessFilter!.displayName}'
                      : 'Fitness: All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: filter.fitnessFilter != null ? FontWeight.bold : FontWeight.normal,
                    color: filter.fitnessFilter != null ? Colors.orange.shade800 : AppColors.textPrimary,
                  ),
                ),
                backgroundColor: filter.fitnessFilter != null
                    ? Colors.orange.withValues(alpha: 0.15)
                    : AppColors.background,
              ),
            ),

            if (filter.stateFilter != null || filter.activityFilter != null || filter.fitnessFilter != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                onPressed: () {
                  ref.read(buddyFilterProvider.notifier).reset();
                },
                tooltip: 'Reset Filters',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBuddyPostCard(BuildContext context, WidgetRef ref, BuddyPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    post.userName.substring(0, 1),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Looking for trip buddies',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.fitnessLevel.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Destination & Date Badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      post.locationName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${post.plannedDate.day}/${post.plannedDate.month}/${post.plannedDate.year}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Note Text
            Text(
              post.note,
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
            ),

            const SizedBox(height: 12),

            // Action Bar: Interested Counter & Connect
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${post.interestedCount} interested',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: post.isInterested ? AppColors.accent : AppColors.surface,
                    foregroundColor: post.isInterested ? Colors.white : AppColors.primary,
                    side: BorderSide(
                      color: post.isInterested ? AppColors.accent : AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () {
                    ref.read(buddyPostsProvider.notifier).toggleInterested(post.id);
                  },
                  icon: Icon(
                    post.isInterested ? Icons.check : Icons.handshake_outlined,
                    size: 16,
                  ),
                  label: Text(
                    post.isInterested ? 'Interested!' : 'I\'m Interested',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Tab 2: Ask Community Q&A
  // ===========================================================================
  Widget _buildAskCommunityTab(BuildContext context, WidgetRef ref) {
    final asyncQuestions = ref.watch(communityQAProvider);

    return Scaffold(
      body: asyncQuestions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading questions: $err')),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No community questions yet. Be the first to ask!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return _buildQACard(context, ref, q);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAskQuestionSheet(context, ref),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.help_outline),
        label: const Text('Ask a Question', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildQACard(BuildContext context, WidgetRef ref, CommunityQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Badge & User
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.destinationName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                Text(
                  'Asked by ${question.userName}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Question Text
            Text(
              question.questionText,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Answers Section
            Row(
              children: [
                const Icon(Icons.question_answer_outlined, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  '${question.answers.length} Community Answers',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accent),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...question.answers.map((ans) => Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ans.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(ans.answerText, style: const TextStyle(fontSize: 12, height: 1.3)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Modal Sheet: Create Buddy Post
  // ===========================================================================
  void _showCreatePostSheet(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();
    final nameController = TextEditingController(text: 'Explorer User');
    String selectedDestination = MockDestinations.items.first.name;
    String selectedState = MockDestinations.items.first.state;
    String selectedActivity = MockDestinations.items.first.activityTypes.first;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 14));
    FitnessLevel selectedFitness = FitnessLevel.intermediate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Buddy Post',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Destination Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedDestination,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        border: OutlineInputBorder(),
                      ),
                      items: MockDestinations.items.map((d) {
                        return DropdownMenuItem(value: d.name, child: Text('${d.name} (${d.state})'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final match = MockDestinations.items.firstWhere((d) => d.name == val);
                          setModalState(() {
                            selectedDestination = val;
                            selectedState = match.state;
                            selectedActivity = match.activityTypes.first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Date Picker Row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Trip Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          child: const Text('Change Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fitness Level Selector
                    const Text('Required Fitness Level:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: FitnessLevel.values.map((level) {
                        final isSelected = selectedFitness == level;
                        return ChoiceChip(
                          label: Text(level.displayName, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => selectedFitness = level);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note (Trip details, pace, expectations...)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final noteText = noteController.text.trim();
                          if (noteText.isEmpty) return;

                          ref.read(buddyPostsProvider.notifier).addPost(
                                locationName: selectedDestination,
                                stateName: selectedState,
                                activityType: selectedActivity,
                                plannedDate: selectedDate,
                                fitnessLevel: selectedFitness,
                                note: noteText,
                                userName: nameController.text.trim().isEmpty ? 'Explorer' : nameController.text.trim(),
                              );

                          ctx.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Buddy Post published to Community feed!'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                        child: const Text('Publish Buddy Post', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // Modal Sheet: Ask Question
  // ===========================================================================
  void _showAskQuestionSheet(BuildContext context, WidgetRef ref) {
    final questionController = TextEditingController();
    final nameController = TextEditingController(text: 'Explorer User');
    String selectedDestination = MockDestinations.items.first.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask the Community',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: selectedDestination,
                    decoration: const InputDecoration(
                      labelText: 'Destination / Trail',
                      border: OutlineInputBorder(),
                    ),
                    items: MockDestinations.items.map((d) {
                      return DropdownMenuItem(value: d.name, child: Text('${d.name} (${d.state})'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedDestination = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Your Question (Permits, trail conditions, gear...)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        final qText = questionController.text.trim();
                        if (qText.isEmpty) return;

                        ref.read(communityQAProvider.notifier).addQuestion(
                              userName: nameController.text.trim().isEmpty ? 'Explorer' : nameController.text.trim(),
                              destinationName: selectedDestination,
                              questionText: qText,
                            );

                        ctx.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Question submitted to Community!'),
                            backgroundColor: AppColors.accent,
                          ),
                        );
                      },
                      child: const Text('Post Question', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
