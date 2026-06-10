const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    }),
  });
}

const db = admin.firestore();

function resolveStatus(transactionStatus, fraudStatus) {
  if (transactionStatus === 'capture') {
    return fraudStatus === 'challenge' ? null : 'confirmed';
  }
  if (transactionStatus === 'settlement') return 'confirmed';
  if (transactionStatus === 'cancel') return 'cancelled';
  if (transactionStatus === 'deny') return 'cancelled';
  if (transactionStatus === 'expire') return 'cancelled';
  if (transactionStatus === 'pending') return 'pending';
  return null;
}

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  try {
    const {
      order_id: orderId,
      transaction_status: transactionStatus,
      fraud_status: fraudStatus,
    } = req.body || {};

    if (!orderId || !transactionStatus) {
      return res.status(200).json({ message: 'ok' });
    }

    const newStatus = resolveStatus(transactionStatus, fraudStatus);

    if (!newStatus) {
      return res.status(200).json({ message: 'Status ignored', transactionStatus });
    }

    const update = {
      status: newStatus,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const globalRef = db.collection('orders').doc(orderId);
    const globalSnap = await globalRef.get();

    if (!globalSnap.exists) {
      return res.status(200).json({ message: 'Order not found' });
    }

    const userId = globalSnap.data().userId;

    const batch = db.batch();
    batch.update(globalRef, update);

    if (userId) {
      const userRef = db.collection('users').doc(userId).collection('orders').doc(orderId);
      batch.update(userRef, update);
    }

    await batch.commit();

    return res.status(200).json({ success: true, orderId, status: newStatus });

  } catch (error) {
    return res.status(500).json({ error: 'Internal Server Error', message: error.message });
  }
};