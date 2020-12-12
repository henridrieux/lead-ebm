// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
// require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)


// ----------------------------------------------------
// Note(lewagon): ABOVE IS RAILS DEFAULT CONFIGURATION
// WRITE YOUR OWN JS STARTING FROM HERE 👇
// ----------------------------------------------------

// External imports
import "bootstrap";

// Internal imports, e.g:
// import { initSelect2 } from '../components/init_select2';
import { initUpdateDashboardViewsOnClick } from "../components/dashboard";
import { toggleCardsLeadsDetailsOnClick } from "../components/leadcard";
import { initUpdateNavbarOnScroll } from "../components/navbar";
// import { cguOnClick } from "../components/navbar";

document.addEventListener('turbolinks:load', () => {
  // Call your functions here, e.g:
  // initSelect2();
  initUpdateNavbarOnScroll();
  toggleCardsLeadsDetailsOnClick();
  initUpdateDashboardViewsOnClick();
  // cguOnClick();
});



// const cgu = document.getElementById("cgu");
// cgu.addEventListener("click", (event) => {
//   const btn = document.getElementById("btn-cgu")
//   event.currentTarget.setAttribute("disabled", "");
//   console.log(event);
// });

// const button = document.querySelector('#cgu');

// button.addEventListener('click', (event) => {
//   event.currentTarget.setAttribute("disabled", "");
//   // event.currentTarget.innerText = 'Hold still...';
//   event.currentTarget.setAttribute("disabled", "");
// });


