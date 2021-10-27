# anonymous_chat

A chat app that's based on anonymous users matching up by specific tags they choose. The chat is constrained to text messages on purpose.
The motive is to let people chat freely without any pressure of social rejection based on appearance/race/popularit and so. 

The app's features:
- Read recipients.
- Tags matching.
- Deleting the chat room for both sides.
- Archiving chat.
- Blocking users.
- Phone number authentication.
- Replying on specific messages.
- iOS and Android push notifications (in progress).

All data is stored in Firebase Firestore and uses it's apis for real time updates. The app also uses algolia for better searching results when looking up for tags to match.
