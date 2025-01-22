import 'package:equatable/equatable.dart';

import 'user.dart';

class GetMembersModel extends Equatable {
	final List<User>? user;
	final String? message;

	const GetMembersModel({this.user, this.message});

	factory GetMembersModel.fromJson(Map<String, dynamic> json) {
		return GetMembersModel(
			user: (json['user'] as List<dynamic>?)
						?.map((e) => User.fromJson(e as Map<String, dynamic>))
						.toList(),
			message: json['message'] as String?,
		);
	}



	Map<String, dynamic> toJson() => {
				'user': user?.map((e) => e.toJson()).toList(),
				'message': message,
			};

	@override
	List<Object?> get props => [user, message];
}
