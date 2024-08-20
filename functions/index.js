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

exports.sendEventNotifications = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    // Send a notification to the topic
    const message = {
      notification: {
        title: 'Upcoming Event',
        body: `An event is starting in 1 hour!`,
      },
      topic: 'livestream_notifications'
    };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
  } catch (error) {
    console.log('Error sending message:', error);
  }
  return null;
});
