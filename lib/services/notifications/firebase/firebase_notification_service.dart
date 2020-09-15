import 'package:bson/bson.dart';
import 'package:googleapis/fcm/v1.dart';

import 'package:fokus/services/notifications/firebase/firebase_notification_provider.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/model/ui/notifications/notification_channel.dart';
import 'package:fokus/model/ui/notifications/notification_button.dart';
import 'package:fokus/model/ui/notifications/notification_icon.dart';
import 'package:fokus/widgets/cards/notification_card.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/model/ui/notifications/notification_text.dart';

class FirebaseNotificationService extends NotificationService {
	@override
	FirebaseNotificationProvider provider = FirebaseNotificationProvider();
	static final String _projectId = 'projects/fokus-application';

  @override
  Future sendNotification(NotificationType type, ObjectId userId, {NotificationText title,
	  NotificationText body, NotificationIcon icon, List<NotificationButton> buttons = const []}) async {
  	var tokens = await getUserTokens(userId);
  	if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
		var request = SendMessageRequest.fromJson({
			'message': {
				'notification': {
					'title': title.translate(),
					'body': body.translate()
				},
				'android': {
					'notification': {
						'channelId': type.channel.id,
						//'titleLocKey': titleKey,
						//'bodyLocKey': body
					}
				},
				'data': {
					'click_action': 'FLUTTER_NOTIFICATION_CLICK',
					'channel': '${type.channel.index}',
					if (title != null)
						...title.toJson('title'),
					if (body != null)
						...body.toJson('body'),
				}
			}
		});
		for (var token in tokens) {
			request.message.token = token;
			provider.notificationApi.send(request, _projectId);
		}
  }
}
