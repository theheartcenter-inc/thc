/**
 * Create and deploy your first functions:
 * https://firebase.google.com/docs/functions/get-started
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const dotenv = require("dotenv");
const {
  RtcTokenBuilder,
  RtcRole,
} = require("agora-token");

dotenv.config();


exports.sendEventNotifications = functions.pubsub.schedule('every 10 minutes').onRun(async (context) => {
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

    if (!signupSnapshot.empty) {
      signupSnapshot.forEach(async userDoc => {
        const signupData = userDoc.data();
        const notified = signupData.notified;
        const signupId = userDoc.id;
        const userRef = db.collection('users').doc(signupId);
        const userSnapshot = await userRef.get();
        if (!userSnapshot.empty) {
          const fcmToken = userSnapshot.data().fcmToken;
          const notify = userSnapshot.data().notify;
          if (fcmToken && notify === true && (notified === false || notified === undefined)) {
            const message = {
              notification: {
                title: event.title,
                body: `Your event is starting in 1 hour!`,
              },
              token: fcmToken,
            };
            messages.push(admin.messaging().send(message));
          }
          await signupsRef.doc(signupId).update({
            notified: true
          });
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

exports.generateToken = functions.https.onCall(async (data, context) => {
  const appId = process.env.APP_ID;
  const appCertificate = process.env.APP_CERTIFICATE;
  const channelName = data.channelName;
  const uid = data.uid || 0;
  const role = RtcRole.PUBLISHER;

  const expirationTimeInSeconds = data.expiryTime;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  if (channelName === undefined || channelName === null) {
    throw new functions.https.HttpsError(
      "aborted",
      "Channel name is required",
    );
  }

  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      role,
      privilegeExpiredTs,
    );
    return token;
  } catch (err) {
    throw new functions.https.HttpsError(
      "aborted",
      "Could not generate token",
    );
  }
});