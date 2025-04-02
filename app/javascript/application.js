// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import Alpine from 'alpinejs'

document.addEventListener('DOMContentLoaded', () => {
    window.Alpine = Alpine
    Alpine.start()
})

import "trix"
import "@rails/actiontext"
