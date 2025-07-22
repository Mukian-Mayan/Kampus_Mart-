/* eslint-disable max-len */
/* eslint-disable no-unused-vars */
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// ============================================
// PRODUCT AND CATEGORY MANAGEMENT FUNCTIONS
// ============================================

// Update category product count when a product is created
exports.onProductCreate = functions
    .firestore
    .document("products/{productId}")
    .onCreate(async (snap, context) => {
      try {
        const productData = snap.data();
        const categoryId = productData.categoryId;

        if (categoryId && productData.isActive) {
          await db.collection("categories").doc(categoryId).update({
            productCount: admin.firestore.FieldValue.increment(1),
          });

          logger.info(`Incremented product count for category ${categoryId}`);
        }
      } catch (error) {
        logger.error("Error updating category count on product create:", error);
      }
    });

// Update category product count when a product is deleted
exports.onProductDelete = functions
    .firestore
    .document("products/{productId}")
    .onDelete(async (snap, context) => {
      try {
        const productData = snap.data();
        const categoryId = productData.categoryId;

        if (categoryId && productData.isActive) {
          const categoryRef = db.collection("categories").doc(categoryId);
          const categoryDoc = await categoryRef.get();

          if (categoryDoc.exists) {
            const currentCount = categoryDoc.data().productCount || 0;

            if (currentCount > 0) {
              await categoryRef.update({
                productCount: admin.firestore.FieldValue.increment(-1),
              });

              logger.info(`Decremented product count for category ${categoryId}`);
            }
          }
        }
      } catch (error) {
        logger.error("Error updating category count on product delete:", error);
      }
    });

// Update category product count when a product is updated
exports.onProductUpdate = functions
    .firestore
    .document("products/{productId}")
    .onUpdate(async (change, context) => {
      try {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        const oldCategoryId = beforeData.categoryId;
        const newCategoryId = afterData.categoryId;
        const oldIsActive = beforeData.isActive;
        const newIsActive = afterData.isActive;

        // Handle category change
        if (oldCategoryId !== newCategoryId) {
          if (oldCategoryId && oldIsActive) {
            const oldCategoryRef = db.collection("categories").doc(oldCategoryId);
            const oldCategoryDoc = await oldCategoryRef.get();

            if (oldCategoryDoc.exists) {
              const currentCount = oldCategoryDoc.data().productCount || 0;
              if (currentCount > 0) {
                await oldCategoryRef.update({
                  productCount: admin.firestore.FieldValue.increment(-1),
                });
              }
            }
          }

          if (newCategoryId && newIsActive) {
            await db.collection("categories").doc(newCategoryId).update({
              productCount: admin.firestore.FieldValue.increment(1),
            });
          }
        }

        // Handle activation/deactivation
        if (oldIsActive !== newIsActive && oldCategoryId === newCategoryId) {
          const categoryId = newCategoryId;

          if (categoryId) {
            const increment = newIsActive ? 1 : -1;

            if (!newIsActive) {
              const categoryRef = db.collection("categories").doc(categoryId);
              const categoryDoc = await categoryRef.get();

              if (categoryDoc.exists) {
                const currentCount = categoryDoc.data().productCount || 0;
                if (currentCount > 0) {
                  await categoryRef.update({
                    productCount: admin.firestore.FieldValue.increment(increment),
                  });
                }
              }
            } else {
              await db.collection("categories").doc(categoryId).update({
                productCount: admin.firestore.FieldValue.increment(increment),
              });
            }
          }
        }

        logger.info("Successfully handled product update for category counts");
      } catch (error) {
        logger.error("Error updating category count on product update:", error);
      }
    });

// ============================================
// ORDER PROCESSING FUNCTIONS
// ============================================

// Handle order status updates
exports.onOrderStatusUpdate = functions
    .firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
      try {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        const oldStatus = beforeData.status;
        const newStatus = afterData.status;

        if (oldStatus !== newStatus) {
        // Update product stock when order is completed
          if (newStatus === "completed") {
            const orderItems = afterData.items || [];

            for (const item of orderItems) {
              const productRef = db.collection("products").doc(item.productId);
              await productRef.update({
                stock: admin.firestore.FieldValue.increment(-item.quantity),
                soldCount: admin.firestore.FieldValue.increment(item.quantity),
              });
            }

            logger.info(`Updated stock for completed order ${context.params.orderId}`);
          }

          // Restore stock if order is cancelled
          if (newStatus === "cancelled" && oldStatus !== "cancelled") {
            const orderItems = afterData.items || [];

            for (const item of orderItems) {
              const productRef = db.collection("products").doc(item.productId);
              await productRef.update({
                stock: admin.firestore.FieldValue.increment(item.quantity),
                soldCount: admin.firestore.FieldValue.increment(-item.quantity),
              });
            }

            logger.info(`Restored stock for cancelled order ${context.params.orderId}`);
          }
        }
      } catch (error) {
        logger.error("Error handling order status update:", error);
      }
    });

// ============================================
// NOTIFICATION FUNCTIONS
// ============================================

// Send notification when order status changes
exports.sendOrderNotification = functions
    .firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
      try {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        if (beforeData.status !== afterData.status) {
          const userId = afterData.userId;
          const orderId = context.params.orderId;

          // Get user's FCM token
          const userDoc = await db.collection("users").doc(userId).get();
          if (userDoc.exists && userDoc.data().fcmToken) {
            const message = {
              token: userDoc.data().fcmToken,
              notification: {
                title: "Order Status Updated",
                body: `Your order ${orderId} status changed to ${afterData.status}`,
              },
              data: {
                orderId: orderId,
                status: afterData.status,
                type: "order_update",
              },
            };

            await admin.messaging().send(message);
            logger.info(`Notification sent for order ${orderId} status change`);
          }
        }
      } catch (error) {
        logger.error("Error sending order notification:", error);
      }
    });

// ============================================
// UTILITY AND MAINTENANCE FUNCTIONS
// ============================================

// Manual function to recalculate all category product counts
exports.recalculateCategoryCounts = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const batch = db.batch();
    const categoriesSnapshot = await db.collection("categories").get();

    for (const categoryDoc of categoriesSnapshot.docs) {
      const categoryId = categoryDoc.id;

      const productsSnapshot = await db.collection("products")
          .where("categoryId", "==", categoryId)
          .where("isActive", "==", true)
          .get();

      const productCount = productsSnapshot.size;
      batch.update(categoryDoc.ref, {productCount: productCount});
    }

    await batch.commit();

    return {
      success: true,
      message: `Recalculated product counts for ${categoriesSnapshot.size} categories`,
    };
  } catch (error) {
    logger.error("Error recalculating category counts:", error);
    throw new functions.https.HttpsError("internal", "Failed to recalculate category counts");
  }
});

// Scheduled function to verify and fix category counts
exports.verifyCategoryCounts = functions.pubsub
    .schedule("0 2 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
      try {
        logger.info("Starting daily category count verification...");

        const categoriesSnapshot = await db.collection("categories").get();
        const fixes = [];

        for (const categoryDoc of categoriesSnapshot.docs) {
          const categoryId = categoryDoc.id;
          const categoryData = categoryDoc.data();
          const storedCount = categoryData.productCount || 0;

          const productsSnapshot = await db.collection("products")
              .where("categoryId", "==", categoryId)
              .where("isActive", "==", true)
              .get();

          const actualCount = productsSnapshot.size;

          if (storedCount !== actualCount) {
            await categoryDoc.ref.update({productCount: actualCount});
            fixes.push({
              categoryId,
              oldCount: storedCount,
              newCount: actualCount,
            });

            logger.info(`Fixed category ${categoryId}: ${storedCount} -> ${actualCount}`);
          }
        }

        logger.info(`Category count verification completed. Fixed ${fixes.length} categories.`);
        return {success: true, fixes};
      } catch (error) {
        logger.error("Error in category count verification:", error);
        return {success: false, error: error.message};
      }
    });

// ============================================
// ANALYTICS AND REPORTING FUNCTIONS
// ============================================

// Generate sales report
exports.generateSalesReport = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }

    const {sellerId, startDate, endDate} = data;

    let query = db.collection("orders")
        .where("sellerId", "==", sellerId)
        .where("status", "==", "completed");

    if (startDate) {
      query = query.where("createdAt", ">=", new Date(startDate));
    }
    if (endDate) {
      query = query.where("createdAt", "<=", new Date(endDate));
    }

    const ordersSnapshot = await query.get();
    const orders = ordersSnapshot.docs.map((doc) => ({id: doc.id, ...doc.data()}));

    const totalSales = orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
    const totalOrders = orders.length;

    return {
      success: true,
      data: {
        totalSales,
        totalOrders,
        orders,
      },
    };
  } catch (error) {
    logger.error("Error generating sales report:", error);
    throw new functions.https.HttpsError("internal", "Failed to generate sales report");
  }
});

// Clean up old cart items
exports.cleanupOldCartItems = functions.pubsub
    .schedule("0 1 * * *")
    .timeZone("UTC")
    .onRun(async (context) => {
      try {
        logger.info("Starting cleanup of old cart items...");

        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const oldCartItems = await db.collection("cart")
            .where("createdAt", "<", thirtyDaysAgo)
            .get();

        const batch = db.batch();
        oldCartItems.docs.forEach((doc) => {
          batch.delete(doc.ref);
        });

        await batch.commit();

        logger.info(`Cleaned up ${oldCartItems.docs.length} old cart items`);
        return {success: true, cleaned: oldCartItems.docs.length};
      } catch (error) {
        logger.error("Error cleaning up old cart items:", error);
        return {success: false, error: error.message};
      }
    });
