const initUpdateNavbarOnScroll = () => {
  const navbar = document.querySelector('.navbar-lewagon');
  if (navbar) {
    window.addEventListener('scroll', () => {
      // const condition = window.scrollY >= window.innerHeight;
      const condition = window.scrollY >= 200;
      if (condition) {
        navbar.classList.add('sticky');
      } else {
        navbar.classList.remove('sticky');
      }
    });
  }
}

export { initUpdateNavbarOnScroll };
