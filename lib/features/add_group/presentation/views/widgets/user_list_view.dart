import 'package:final_project/features/add_group/data/models/get_users_model/user.dart';
import 'package:final_project/features/add_group/presentation/views/widgets/user_tile.dart';
import 'package:flutter/material.dart';

class UserListView extends StatelessWidget {
  final List<User> users;
  final List<int> selectedUsers;
  final Function(int userId) onSelectUser;

  const UserListView({
    super.key,
    required this.users,
    required this.selectedUsers,
    required this.onSelectUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = selectedUsers.contains(user.id);

        return GestureDetector(

          onTap: () {
            onSelectUser(users[index].id!);
          },
          child: UserTile(
            user: user,
            isSelected: isSelected,
          ),
        );
      },
    );
  }
}
