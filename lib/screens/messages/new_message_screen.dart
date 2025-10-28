import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/new_message_mock_data.dart';
import 'package:sociord/models/contact_model.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/utils/routes.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  String selectedTab = 'Personal';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            _buildTabBar(),

            // Search Bar
            _buildSearchBar(),

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
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: kAppBlack, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'New Message',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: kAppBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            ['Creator', 'Personal'].map((tab) {
              final isSelected = selectedTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = tab;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? kAppPurple : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isSelected ? kAppPurple : kAppLightBlack,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kBorderGreay,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search icon
          SizedBox(
            width: 20,
            height: 20,
            child: Icon(Icons.search, color: Colors.grey, size: 16),
          ),
          const SizedBox(width: 8),
          // Search input field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Clear button
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                });
              },
              child: SizedBox(
                width: 20,
                height: 20,
                child: Icon(Icons.close, color: Colors.black, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final contacts = NewMessageMockData.getContactsForTab(selectedTab);
    final filteredContacts =
        contacts.where((contact) {
          if (_searchController.text.isEmpty) return true;
          return contact.username.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
        }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        return _buildContactItem(contact);
      },
    );
  }

  Widget _buildContactItem(ContactItem contact) {
    return GestureDetector(
      onTap: () {
        context.push(
          chatRoute,
          extra: {
            'contactName': contact.username,
            'contactUsername': contact.username,
            'contactProfileImage': contact.profileImage,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kAppGreay, width: 0.5)),
        ),
        child: Row(
          children: [
            // Profile Picture (same style as messages page)
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                contact.profileImage,
                width: 50,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Username
            Expanded(
              child: Text(
                contact.username,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kAppBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
