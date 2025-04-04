// Módulo para manejar los métodos de pago

const initPaymentMethods = () => {
  console.log('Initializing payment methods');
  
  // Verificar si estamos en la página de pagos
  const paymentForm = document.querySelector('form[data-payment-form="true"]');
  if (!paymentForm) {
    console.log('Payment form not found');
    return;
  }

  // Elementos del DOM
  const paymentMethods = document.querySelectorAll('input[name="payment[payment_method]"]');
  const submitButton = document.getElementById('payment-submit-button');
  const cardElementContainer = document.getElementById('card-element-container');
  
  // Manejar el cambio de método de pago
  paymentMethods.forEach(method => {
    method.addEventListener('change', () => {
      updatePaymentUI(method.value);
    });
  });
  
  // Inicializar la UI basada en el método seleccionado actualmente
  const selectedMethod = document.querySelector('input[name="payment[payment_method]"]:checked');
  if (selectedMethod) {
    updatePaymentUI(selectedMethod.value);
  }
  
  // Función para actualizar la UI según el método de pago seleccionado
  function updatePaymentUI(paymentMethod) {
    // Ocultar todos los contenedores específicos de método de pago
    if (cardElementContainer) {
      cardElementContainer.style.display = 'none';
    }
    
    // Actualizar el texto del botón según el método de pago
    switch (paymentMethod) {
      case 'stripe':
        submitButton.value = 'Continuar a Stripe';
        if (cardElementContainer) {
          cardElementContainer.style.display = 'block';
        }
        break;
      case 'paypal':
        submitButton.value = 'Continuar a PayPal';
        break;
      case 'bank_transfer':
        submitButton.value = 'Ver Instrucciones de Transferencia';
        break;
      default:
        submitButton.value = 'Continuar al Pago';
    }
  }
  
  // Manejar el envío del formulario
  paymentForm.addEventListener('submit', (event) => {
    const selectedMethod = document.querySelector('input[name="payment[payment_method]"]:checked');
    if (!selectedMethod) {
      event.preventDefault();
      alert('Por favor, selecciona un método de pago');
      return;
    }
    
    // Mostrar indicador de carga
    submitButton.disabled = true;
    submitButton.value = 'Procesando...';
    
    // El formulario se enviará normalmente y el controlador manejará la redirección
    // a la pasarela de pago correspondiente
  });
};

// Exportar la función para que pueda ser importada desde otros archivos
export { initPaymentMethods };

// Inicializar en diferentes eventos para asegurar que funcione con Turbo
document.addEventListener('turbo:load', initPaymentMethods);
document.addEventListener('turbo:render', initPaymentMethods);
document.addEventListener('DOMContentLoaded', initPaymentMethods);

// Inicializar inmediatamente si el documento ya está cargado
if (document.readyState === 'complete' || document.readyState === 'interactive') {
  console.log('Document already loaded, initializing payment methods');
  setTimeout(initPaymentMethods, 100);
}