part of 'categories_bloc.dart';

/// Command-style states: each emission drives a one-off UI side effect in the
/// widget's stream listener. Intentionally **not** `Equatable` — the
/// assigned-users lookup repeats (tapping the same category twice must reopen
/// the dialog), so states must re-fire rather than be de-duplicated.
abstract class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

// --- getUserCats() ---

/// Users loaded — widget sets `Strings.users` and `users`.
class CategoriesUsersLoaded extends CategoriesState {
  final List<FetchMapedUsersData> users;

  CategoriesUsersLoaded(this.users);
}

/// Unexpected error loading users (catchError) — dismiss spinner only.
class CategoriesUsersError extends CategoriesState {}

// --- getCategories() ---

/// Show the spinner while loading categories.
class CategoriesLoading extends CategoriesState {}

/// Categories loaded — dismiss spinner and set `_catsList`.
class CategoriesLoaded extends CategoriesState {
  final List<FectchCatsData> cats;

  CategoriesLoaded(this.cats);
}

/// `status == false` — dismiss spinner and show the "No Categories found !" text.
class CategoriesEmpty extends CategoriesState {}

/// Unexpected error loading categories (catchError) — dismiss spinner only.
class CategoriesLoadError extends CategoriesState {}

// --- getAssignedUsers() ---

/// Assigned users loaded — set `_catUsersList`, close the loading dialog and
/// open the assigned-users dialog.
class AssignedUsersLoaded extends CategoriesState {
  final List<CategoryUsersData> catUsers;

  AssignedUsersLoaded(this.catUsers);
}

/// `status == false` — error toast then close the loading dialog.
class AssignedUsersFailure extends CategoriesState {
  final String message;

  AssignedUsersFailure(this.message);
}

/// Unexpected error (catchError) — close the loading dialog then error toast.
class AssignedUsersError extends CategoriesState {
  final String error;

  AssignedUsersError(this.error);
}
