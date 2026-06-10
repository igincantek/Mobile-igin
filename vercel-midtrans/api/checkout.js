module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  try {
    const { orderId, total, customerName, phone } = req.body;

    if (!orderId || !total) {
      return res.status(400).json({ error: 'orderId and total are required' });
    }

    const rawServerKey = 'Mid-server-c227wIdTSJZh7u2keOO0wUhd';
    const base64Auth = Buffer.from(rawServerKey + ':').toString('base64');

    const payload = {
      transaction_details: {
        order_id: String(orderId),
        gross_amount: Math.round(Number(total)),
      },
      credit_card: { secure: true },
      customer_details: {
        first_name: customerName ? String(customerName) : 'Customer',
        phone: phone ? String(phone) : '0000000000',
      },
    };

    const response = await fetch('https://app.sandbox.midtrans.com/snap/v1/transactions', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${base64Auth}`,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json({ error: 'Rejected by Midtrans', details: data });
    }

    return res.status(200).json({
      snapToken: data.token,
      paymentUrl: data.redirect_url,
    });
  } catch (error) {
    return res.status(500).json({ error: 'Internal Server Error', message: error.message });
  }
};