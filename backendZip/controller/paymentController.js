const stripe = require('../config/stripe');

exports.createPaymentIntent = async (req, res) => {
    const { amount, currency } = req.body;

    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount,
            currency,
            payment_method_types: ['card'],
        });

        res.status(200).json({
            clientSecret: paymentIntent.client_secret,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Payment intent failed' });
    }
};
