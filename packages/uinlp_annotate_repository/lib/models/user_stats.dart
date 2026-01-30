class UserStatsModel {
  final int tasksCompleted;
  final int tasksInProgress;
  final int hoursSpent;
  final double accuracy;

  const UserStatsModel({
    required this.tasksCompleted,
    required this.tasksInProgress,
    required this.hoursSpent,
    required this.accuracy,
  });
}
