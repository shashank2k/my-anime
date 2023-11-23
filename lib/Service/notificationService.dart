// import 'package:dio/dio.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   Future<void> initNotification() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('ic_launcher');
//
//     DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//         onDidReceiveLocalNotification:
//             (int id, String? title, String? body, String? payload) async {});
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) async {
//         // Handle notification response
//         // Get.to(()=> const MyHomePage(title: 'My-Anime'));
//       },
//     );
//   }
//
//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channelId',
//         'channelName',
//         importance: Importance.max,
//       ),
//       iOS: DarwinNotificationDetails(),
//     );
//   }
//
//   Future<void> showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//     String? payLoad,
//   }) async {
//     print('in show notification');
//     await notificationsPlugin.show(
//       id,
//       title,
//       body,
//       await notificationDetails(),
//     );
//   }
//
//   Future<void> checkConnection() async {
//     try {
//       print('in check connection');
//       final stopwatch = Stopwatch()..start();
//       final response = await Dio().get('https://my-anime.onrender.com');
//       stopwatch.stop();
//
//       if (response.statusCode == 200 && stopwatch.elapsed.inSeconds > 5) {
//         print(' in check  Notification sent');
//         await showNotification(
//           title: 'Your anime is now ready',
//           body: 'Server is up!',
//         );
//       } else {
//         print('in check Server open ${stopwatch.elapsed.inSeconds}');
//         await showNotification(
//           title: 'Your anime is now ready',
//           body: 'Server is up!',
//         );
//       }
//     } catch (e) {
//       print('Error in checkConnection: $e');
//       // Handle errors or server not reachable
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myanime/Shared/common.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      // Get.to(()=> const MyHomePage(title: 'My-Anime'));
    });
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    print('in show notification');
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future<void> checkConnection() async {
    try {
      print('in check connection');
      final stopwatch = Stopwatch()..start();
      final response = await Dio().get(Common.baseGogoUrl);
      stopwatch.stop();
      if (response.statusCode == 200 && stopwatch.elapsed.inSeconds > 5) {
          print(' in check  Notification sent');
          await showNotification(title: 'Your anime is now ready', body: 'Server is up!');
      } else{
        print('in check Server open ${stopwatch.elapsed.inSeconds}');
        // await showNotification(title: 'Your anime is now ready', body: 'Server is up!');
      }
    } catch (e) {
      // Handle errors or server not reachable
    }
  }



}