import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['mobileMenu', 'dropdown']
  static classes = ['hidden']

  connect() {
    console.log('NavbarController conectado')
    // Cerrar al hacer clic fuera
    this.handleOutsideClicks = this.handleOutsideClicks.bind(this)
    document.addEventListener('click', this.handleOutsideClicks)

    // Cerrar al presionar Escape
    this.handleEscapeKey = this.handleEscapeKey.bind(this)
    document.addEventListener('keydown', this.handleEscapeKey)
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClicks)
    document.removeEventListener('keydown', this.handleEscapeKey)
  }

  toggleMobileMenu() {
    console.log('Alternando menú móvil')
    this.mobileMenuTarget.classList.toggle(this.hiddenClass)
    
    // Alternar íconos del menú móvil
    const openIcon = this.element.querySelector('.mobile-menu-open')
    const closeIcon = this.element.querySelector('.mobile-menu-close')
    
    if (openIcon && closeIcon) {
      openIcon.classList.toggle('hidden')
      closeIcon.classList.toggle('hidden')
    }
  }

  toggleDropdown(event) {
    console.log('Alternando dropdown')
    const button = event.currentTarget
    const dropdown = button.nextElementSibling
    
    // Verificar si el dropdown tiene la clase data-navbar-target="dropdown"
    if (dropdown && dropdown.hasAttribute('data-navbar-target')) {
      dropdown.classList.toggle(this.hiddenClass)
      
      // Cerrar otros dropdowns
      this.dropdownTargets.forEach(otherDropdown => {
        if (otherDropdown !== dropdown && !otherDropdown.classList.contains(this.hiddenClass)) {
          otherDropdown.classList.add(this.hiddenClass)
        }
      })
    } else {
      console.error('No se encontró el dropdown asociado al botón')
    }
  }

  handleOutsideClicks(event) {
    // No cerrar si se hace clic en un botón que controla un dropdown
    if (event.target.hasAttribute('data-action') && 
        event.target.getAttribute('data-action').includes('navbar#toggle')) {
      return
    }
    
    // Cerrar menú móvil si se hace clic fuera
    if (this.hasMobileMenuTarget && 
        !this.mobileMenuTarget.contains(event.target) && 
        !this.mobileMenuTarget.previousElementSibling.contains(event.target)) {
      this.mobileMenuTarget.classList.add(this.hiddenClass)
      
      // Restaurar íconos del menú móvil
      const openIcon = this.element.querySelector('.mobile-menu-open')
      const closeIcon = this.element.querySelector('.mobile-menu-close')
      
      if (openIcon && closeIcon) {
        openIcon.classList.remove('hidden')
        closeIcon.classList.add('hidden')
      }
    }

    // Cerrar dropdowns si se hace clic fuera
    this.dropdownTargets.forEach(dropdown => {
      if (!dropdown.contains(event.target) && 
          !dropdown.previousElementSibling.contains(event.target)) {
        dropdown.classList.add(this.hiddenClass)
      }
    })
  }
  
  handleEscapeKey(event) {
    if (event.key === 'Escape') {
      // Cerrar todos los dropdowns
      this.dropdownTargets.forEach(dropdown => {
        dropdown.classList.add(this.hiddenClass)
      })
      
      // Cerrar menú móvil
      if (this.hasMobileMenuTarget) {
        this.mobileMenuTarget.classList.add(this.hiddenClass)
        
        // Restaurar íconos del menú móvil
        const openIcon = this.element.querySelector('.mobile-menu-open')
        const closeIcon = this.element.querySelector('.mobile-menu-close')
        
        if (openIcon && closeIcon) {
          openIcon.classList.remove('hidden')
          closeIcon.classList.add('hidden')
        }
      }
    }
  }
}