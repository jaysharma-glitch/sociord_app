import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/buddy_requests_mock_data.dart';
import 'package:sociord/models/buddy_request_model.dart';

class BuddyRequestsScreen extends StatefulWidget {
  const BuddyRequestsScreen({super.key});

  @override
  State<BuddyRequestsScreen> createState() => _BuddyRequestsScreenState();
}

class _BuddyRequestsScreenState extends State<BuddyRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios, color: kAppBlack, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Buddy Requests',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: kAppBlack,
              ),
            ),
          ),
          const SizedBox(width: 36), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildContent() {
    final buddyRequests = BuddyRequestsMockData.getBuddyRequests();
    final suggestions = BuddyRequestsMockData.getSuggestions();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Buddy Requests Section
        if (buddyRequests.isNotEmpty) ...[
          ...buddyRequests.asMap().entries.map((entry) {
            final index = entry.key;
            final request = entry.value;
            return Column(
              children: [
                _buildBuddyRequestItem(request),
                if (index < buddyRequests.length - 1)
                  Container(
                    height: 1,
                    color: kAppGreay,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
              ],
            );
          }).toList(),
          const SizedBox(height: 24),
        ],

        // People you might know section
        Center(
          child: Text(
            'People you might know',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: kAppPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Suggestions Section
        ...suggestions.asMap().entries.map((entry) {
          final index = entry.key;
          final suggestion = entry.value;
          return Column(
            children: [
              _buildSuggestionItem(suggestion),
              if (index < suggestions.length - 1)
                Container(
                  height: 1,
                  color: kAppGreay,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBuddyRequestItem(BuddyRequest request) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(request.username),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      request.profileImage,
                      width: 50,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // User Info and Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToUserProfile(request.username),
                        child: Text(
                          request.username,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kAppBlack,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.message,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kAppBlack,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),
          // Profile Picture

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accept Button
              SizedBox(
                width: 60,
                height: 25,
                child: ElevatedButton(
                  onPressed: () => _handleAccept(request.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppPurple,
                    foregroundColor: kAppWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    'Accept',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: kAppWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Delete Button
              SizedBox(
                width: 60,
                height: 25,
                child: ElevatedButton(
                  onPressed: () => _handleDelete(request.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppDarkGreay,
                    foregroundColor: kAppWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    'Delete',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: kAppWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(BuddySuggestion suggestion) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(suggestion.username),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      suggestion.profileImage,
                      width: 50,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // User Info and Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap:
                            () => _navigateToUserProfile(suggestion.username),
                        child: Text(
                          suggestion.username,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kAppBlack,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suggestion.demographics,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kAppBlack,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suggestion.location,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kAppBlack,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),
              ],
            ),
          ),
          // Add as Buddy Button
          SizedBox(
            width: 120,
            height: 32,
            child: ElevatedButton(
              onPressed: () => _handleAddBuddy(suggestion.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAppBlack,
                foregroundColor: kAppWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                'Add as a buddy',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kAppWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAccept(String requestId) {
    // TODO: Handle accept buddy request
    print('Accepting buddy request: $requestId');
    // Remove from list or update status
  }

  void _handleDelete(String requestId) {
    // TODO: Handle delete buddy request
    print('Deleting buddy request: $requestId');
    // Remove from list
  }

  void _handleAddBuddy(String suggestionId) {
    // TODO: Handle add buddy from suggestion
    print('Adding buddy from suggestion: $suggestionId');
    // Send buddy request
  }

  void _navigateToUserProfile(String username) {
    // TODO: Navigate to user profile page
    print('Navigating to profile: $username');
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => UserProfileScreen(username: username),
    //   ),
    // );
  }
}
