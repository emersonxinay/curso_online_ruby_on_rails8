// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import Alpine from 'alpinejs'

document.addEventListener('DOMContentLoaded', () => {
    // Inicializar Alpine.js
    window.Alpine = Alpine
    
    // Definir funciones globales para los dropdowns y menú móvil
    window.dropdown = function() {
        return {
            open: false,
            toggle() {
                this.open = !this.open
            },
            close() {
                this.open = false
            }
        }
    }
    
    window.mobileMenu = function() {
        return {
            open: false,
            toggle() {
                this.open = !this.open
            },
            close() {
                this.open = false
            }
        }
    }
    
    // Iniciar Alpine
    Alpine.start()
})

// Importar Trix para el editor de texto enriquecido
import "trix"
import "@rails/actiontext"

// Inicializar componentes de pago si están disponibles
import "./payments"
