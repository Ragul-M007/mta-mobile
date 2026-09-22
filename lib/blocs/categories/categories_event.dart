part of 'categories_bloc.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

/// Load the project's users (mirrors `getUserCats()`).
class CategoriesUsersRequested extends CategoriesEvent {
  const CategoriesUsersRequested();
}

/// Load the project's categories (mirrors `getCategories()`).
class CategoriesRequested extends CategoriesEvent {
  const CategoriesRequested();
}

/// Load the users assigned to a category (mirrors `getAssignedUsers(catID)`).
class AssignedUsersRequested extends CategoriesEvent {
  final int catID;

  const AssignedUsersRequested(this.catID);

  @override
  List<Object?> get props => [catID];
}
