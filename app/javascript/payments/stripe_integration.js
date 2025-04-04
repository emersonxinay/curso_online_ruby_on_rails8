// Stripe integration module
const initStripeElements = () => {
  console.log('Initializing Stripe Elements');
  // Verificar si estamos en la página de pagos
  const paymentMethodForm = document.querySelector('form[action*="payments"]');
  if (!paymentMethodForm) {
    console.log('Payment form not found');
    return;
  }

  // Verificar si el método de pago Stripe está seleccionado
  const stripeRadio = document.querySelector('input[name="payment[payment_method]"][value="stripe"]');
  if (!stripeRadio) {
    console.log('Stripe radio button not found');
    return;
  }

  // Obtener la clave pública de Stripe
  const stripeKey = document.querySelector('meta[name="stripe-key"]')?.getAttribute('content');
  if (!stripeKey) {
    console.error('Stripe key not found');
    return;
  }

  // Inicializar Stripe
  const stripe = Stripe(stripeKey);

  // Manejar el cambio de método de pago
  const paymentMethods = document.querySelectorAll('input[name="payment[payment_method]"]');
  const submitButton = document.querySelector('input[type="submit"]');
  
  // Crear contenedor para el elemento de tarjeta si no existe
  let cardContainer = document.getElementById('card-element-container');
  if (!cardContainer) {
    console.log('Creating card container');
    cardContainer = document.createElement('div');
    cardContainer.id = 'card-element-container';
    cardContainer.className = 'mt-4 p-3 border rounded-md bg-white';
    cardContainer.style.display = 'none';
    
    // Crear el elemento para la tarjeta
    const cardElement = document.createElement('div');
    cardElement.id = 'card-element';
    cardContainer.appendChild(cardElement);
    
    // Crear el elemento para mostrar errores
    const cardErrors = document.createElement('div');
    cardErrors.id = 'card-errors';
    cardErrors.className = 'text-red-500 text-sm mt-2';
    cardContainer.appendChild(cardErrors);
    
    // Insertar después del último método de pago
    const paymentMethodsContainer = document.querySelector('.space-y-4');
    if (paymentMethodsContainer) {
      paymentMethodsContainer.appendChild(cardContainer);
    } else {
      console.error('Payment methods container not found');
      // Fallback: insertar después del último método de pago
      const lastPaymentMethod = Array.from(paymentMethods).pop();
      if (lastPaymentMethod) {
        const parentDiv = lastPaymentMethod.closest('div').parentNode;
        parentDiv.insertBefore(cardContainer, parentDiv.lastChild);
      }
    }
  }
  
  // Inicializar elementos de Stripe
  const elements = stripe.elements();
  const card = elements.create('card');
  
  // Montar el elemento de tarjeta cuando se selecciona Stripe
  let cardMounted = false;
  
  paymentMethods.forEach(method => {
    method.addEventListener('change', () => {
      if (method.value === 'stripe') {
        cardContainer.style.display = 'block';
        submitButton.value = 'Pagar con Tarjeta';
        
        if (!cardMounted) {
          card.mount('#card-element');
          cardMounted = true;
        }
      } else {
        cardContainer.style.display = 'none';
        submitButton.value = 'Continuar al Pago';
      }
    });
  });
  
  // Si Stripe ya está seleccionado, mostrar el elemento de tarjeta
  if (stripeRadio.checked) {
    cardContainer.style.display = 'block';
    submitButton.value = 'Pagar con Tarjeta';
    
    if (!cardMounted) {
      card.mount('#card-element');
      cardMounted = true;
    }
  }
  
  // Manejar errores en el elemento de tarjeta
  card.addEventListener('change', (event) => {
    const displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });
  
  // Manejar el envío del formulario
  paymentMethodForm.addEventListener('submit', async (event) => {
    const selectedMethod = document.querySelector('input[name="payment[payment_method]"]:checked');
    console.log('Form submitted, selected method:', selectedMethod?.value);
    
    if (selectedMethod && selectedMethod.value === 'stripe') {
      event.preventDefault();
      console.log('Processing Stripe payment...');
      
      try {
        const { token, error } = await stripe.createToken(card);
        
        if (error) {
          console.error('Stripe error:', error);
          const errorElement = document.getElementById('card-errors');
          errorElement.textContent = error.message;
        } else {
          console.log('Stripe token created:', token.id);
          // Insertar el token en el formulario y enviarlo
          const hiddenInput = document.createElement('input');
          hiddenInput.setAttribute('type', 'hidden');
          hiddenInput.setAttribute('name', 'stripeToken');
          hiddenInput.setAttribute('value', token.id);
          paymentMethodForm.appendChild(hiddenInput);
          
          console.log('Submitting form with Stripe token');
          paymentMethodForm.submit();
        }
      } catch (e) {
        console.error('Error processing Stripe payment:', e);
        const errorElement = document.getElementById('card-errors');
        errorElement.textContent = 'Error al procesar el pago. Por favor, inténtalo de nuevo.';
      }
    }
  });
};

// Exportar la función para que pueda ser importada desde otros archivos
export { initStripeElements };

// Inicializar en diferentes eventos para asegurar que funcione con Turbo
document.addEventListener('turbo:load', initStripeElements);
document.addEventListener('turbo:render', initStripeElements);
document.addEventListener('DOMContentLoaded', initStripeElements);

// Inicializar inmediatamente si el documento ya está cargado
if (document.readyState === 'complete' || document.readyState === 'interactive') {
  console.log('Document already loaded, initializing Stripe Elements');
  setTimeout(initStripeElements, 100);
}