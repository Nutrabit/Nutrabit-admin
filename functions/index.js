/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Ejemplo función HTTP
exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});


exports.taskRunner = onSchedule("* * * * *", async (_context) => {
  const now = admin.firestore.Timestamp.now();
  const notificationsRef = admin.firestore().collection("notifications");

  const querySnap = await notificationsRef
      .where("scheduledTime", "<=", now)
      .where("sent", "==", false)
      .where("cancel", "==", false)
      .get();

  const promises = [];

  querySnap.forEach((doc) => {
    const data = doc.data();

    const message = {
      topic: data.topic,
      notification: {
        title: data.title,
        body: data.description,
      },
      data: {
        notificationId: doc.id,
      },
    };

    const promise = admin.messaging().send(message)
        .then(async () => {
          if (data.repeatEvery && data.endDate) {
            const nextTime = new Date(data.scheduledTime.toDate());
            nextTime.setDate(nextTime.getDate() + data.repeatEvery);

            if (nextTime <= data.endDate.toDate()) {
              await doc.ref.update({
                scheduledTime: admin.firestore.Timestamp.fromDate(nextTime),
              });
            } else {
              await doc.ref.update({sent: true});
            }
          } else {
            await doc.ref.update({sent: true});
          }
        })
        .catch((error) => {
          logger.error(`Error enviando notificación ${doc.id}:`, error);
        });

    promises.push(promise);
  });

  await Promise.all(promises);
});

const axios = require("axios");

exports.faviconProxy = onRequest(async (req, res) => {
  const domain = req.query.domain;
  if (!domain) {
    return res.status(400).send("Missing domain parameter");
  }

  try {
    const faviconUrl = `https://www.google.com/s2/favicons?domain=${domain}&sz=64`;

    const response = await axios.get(faviconUrl, {
      responseType: "arraybuffer",
    });

    res.set("Access-Control-Allow-Origin", "*");
    res.set("Content-Type", response.headers["content-type"] || "image/png");
    res.send(response.data);
  } catch (error) {
    console.error("Error fetching favicon:", error);
    res.status(500).send("Error fetching favicon");
  }
});
