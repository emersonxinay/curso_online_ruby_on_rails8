// Import modules
import { initStripeElements } from './stripe_integration';
import { initPaymentMethods } from './payment_methods';

// Función para inicializar todos los componentes de pago
const initializePaymentComponents = () => {
  console.log('Initializing payment components');
  
  // Inicializar el selector de métodos de pago
  initPaymentMethods();
  
  // Inicializar Stripe Elements si es necesario
  if (document.querySelector('[data-payment-method="stripe"]')) {
    initStripeElements();
  }
};

// Inicializar en diferentes eventos de Turbo para asegurar que funcione en todas las situaciones
document.addEventListener('turbo:load', initializePaymentComponents);
document.addEventListener('turbo:render', initializePaymentComponents);
document.addEventListener('DOMContentLoaded', initializePaymentComponents);

// Inicializar inmediatamente si el documento ya está cargado
if (document.readyState === 'complete' || document.readyState === 'interactive') {
  console.log('Document already loaded, initializing payment components');
  setTimeout(initializePaymentComponents, 100);
}
