import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notifications_repository.dart';

class GetUserNotificationsParams {
  final String userId;
  final int page;
  final int limit;
  final NotificationType? type;
  final NotificationStatus? status;

  const GetUserNotificationsParams({
    required this.userId,
    this.page = 1,
    this.limit = 20,
    this.type,
    this.status,
  });
}

class GetUserNotifications
    implements UseCase<List<Notification>, GetUserNotificationsParams> {
  final NotificationsRepository repository;

  GetUserNotifications(this.repository);

  @override
  Future<Either<Failure, List<Notification>>> call(
    GetUserNotificationsParams params,
  ) async {
    try {
      final notifications = await repository.getUserNotifications(
        params.userId,
        page: params.page,
        limit: params.limit,
        type: params.type,
        status: params.status,
      );
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class MarkNotificationAsReadParams {
  final String notificationId;

  const MarkNotificationAsReadParams({required this.notificationId});
}

class MarkNotificationAsRead
    implements UseCase<void, MarkNotificationAsReadParams> {
  final NotificationsRepository repository;

  MarkNotificationAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(
    MarkNotificationAsReadParams params,
  ) async {
    try {
      await repository.markAsRead(params.notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class MarkAllNotificationsAsReadParams {
  final String userId;

  const MarkAllNotificationsAsReadParams({required this.userId});
}

class MarkAllNotificationsAsRead
    implements UseCase<void, MarkAllNotificationsAsReadParams> {
  final NotificationsRepository repository;

  MarkAllNotificationsAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(
    MarkAllNotificationsAsReadParams params,
  ) async {
    try {
      await repository.markAllAsRead(params.userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetUnreadCountParams {
  final String userId;

  const GetUnreadCountParams({required this.userId});
}

class GetUnreadCount implements UseCase<int, GetUnreadCountParams> {
  final NotificationsRepository repository;

  GetUnreadCount(this.repository);

  @override
  Future<Either<Failure, int>> call(GetUnreadCountParams params) async {
    try {
      final count = await repository.getUnreadCount(params.userId);
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetNotificationStatsParams {
  final String userId;

  const GetNotificationStatsParams({required this.userId});
}

class GetNotificationStats
    implements UseCase<Map<String, int>, GetNotificationStatsParams> {
  final NotificationsRepository repository;

  GetNotificationStats(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(
    GetNotificationStatsParams params,
  ) async {
    try {
      final stats = await repository.getNotificationStats(params.userId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class DeleteNotificationParams {
  final String notificationId;

  const DeleteNotificationParams({required this.notificationId});
}

class DeleteNotification implements UseCase<void, DeleteNotificationParams> {
  final NotificationsRepository repository;

  DeleteNotification(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    try {
      await repository.deleteNotification(params.notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
