/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.sendEventNotifications = functions.pubsub.schedule('every 60 minutes').onRun(async (context) => {
      const now = admin.firestore.Timestamp.now();
      const oneHourLater = new Date(now.toDate().getTime() + 60 * 60 * 1000);
      const eventsRef = db.collection('scheduled_streams');

  const snapshot = await eventsRef
        .where('date', '<=', oneHourLater)
        .where('date', '>=', now)
        .get();

      if (snapshot.empty) {
        console.log('No upcoming events found');
        return null;
      }

  const messages = [];
  snapshot.forEach(async doc => {
    const event = doc.data();
    const eventId = doc.id;
    const signupsRef = eventsRef.doc(eventId).collection('signups');
    const signupSnapshot = await signupsRef.get();

    if(!signupSnapshot.empty){
        signupSnapshot.forEach(async userDoc => {
            const signupId = userDoc.id;
            const userRef = db.collection('users').doc(signupId);
            const userSnapshot = await userRef.get();
          if (!userSnapshot.empty) {
            const fcmToken = userSnapshot.data().fcmToken;
            const notify = userSnapshot.data().notify;
            if (fcmToken && notify === true) {
              const message = {
                notification: {
                  title: event.title,
                  body: `Your event is starting soon!`,
                },
                token: fcmToken,
              };
              messages.push(admin.messaging().send(message));
            }
          } else {
              console.log("No such user found!");
          }
        });

    } else {
        console.log('No Signups found');
        return null;
    }

    });

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
  } catch (error) {
    console.log('Error sending message:', error);
  }
  return null;
});
