public class BulkNotificationHelper {
    
    public static void sendBulkNotifications(Set<Id> userIds, String notificationMessage, String recordID) {
        
        CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'customnotification'];
        Id userId = Userinfo.getUserId();
        
        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
        customNotificationObj.setBody('Please check the case details');
        customNotificationObj.setTitle('Case got escalated !!');
        customNotificationObj.setNotificationTypeId(cnType.id);
        customNotificationObj.setSenderId(UserInfo.getUserId()); // Sender is the current user
        customNotificationObj.setTargetId(recordId); // Specify the target Record to receive the notification
        customNotificationObj.send(new Set<String> {userId});
        
    }
}