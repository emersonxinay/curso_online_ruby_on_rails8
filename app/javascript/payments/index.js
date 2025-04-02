// Stripe integration
const initStripe = () => {
  const stripe = Stripe(process.env.STRIPE_PUBLISHABLE_KEY);
  const elements = stripe.elements();

  // Create card element
  const card = elements.create('card');
  const cardElement = document.getElementById('card-element');
  if (cardElement) {
    card.mount('#card-element');
  }

  // Handle form submission
  const form = document.getElementById('payment-form');
  if (form) {
    form.addEventListener('submit', async (event) => {
      event.preventDefault();
      const { token, error } = await stripe.createToken(card);

      if (error) {
        const errorElement = document.getElementById('card-errors');
        errorElement.textContent = error.message;
      } else {
        const hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', 'stripeToken');
        hiddenInput.setAttribute('value', token.id);
        form.appendChild(hiddenInput);
        form.submit();
      }
    });
  }
};

// PayPal integration
const initPayPal = () => {
  if (typeof paypal !== 'undefined') {
    paypal.Buttons({
      createOrder: (data, actions) => {
        return fetch('/create-paypal-order', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          }
        })
        .then(response => response.json())
        .then(order => order.id);
      },
      onApprove: (data, actions) => {
        return fetch('/capture-paypal-order', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            orderID: data.orderID
          })
        })
        .then(response => response.json())
        .then(orderData => {
          const paymentForm = document.getElementById('payment-form');
          if (paymentForm) {
            const hiddenInput = document.createElement('input');
            hiddenInput.setAttribute('type', 'hidden');
            hiddenInput.setAttribute('name', 'paypalOrderId');
            hiddenInput.setAttribute('value', orderData.id);
            paymentForm.appendChild(hiddenInput);
            paymentForm.submit();
          }
        });
      }
    }).render('#paypal-button-container');
  }
};

// Initialize payment methods when DOM is loaded
document.addEventListener('turbo:load', () => {
  if (document.querySelector('[data-payment-method="stripe"]')) {
    initStripe();
  }
  if (document.querySelector('[data-payment-method="paypal"]')) {
    initPayPal();
  }
});
