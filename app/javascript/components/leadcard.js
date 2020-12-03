const addEventOnClick = (card) => {
  const expand = card.querySelector('.options-show');
  expand.addEventListener('click', () => {
    card.querySelector('.options-show').classList.toggle('d-none');
    card.querySelector('.card-lead-options').classList.toggle('d-none');
    card.querySelector('.options-hide').classList.toggle('d-none');
  });
  const collapse = card.querySelector('.options-hide');
  collapse.addEventListener('click', () => {
    card.querySelector('.options-show').classList.toggle('d-none');
    card.querySelector('.card-lead-options').classList.toggle('d-none');
    card.querySelector('.options-hide').classList.toggle('d-none');
  });
};


const toggleCardsLeadsDetailsOnClick = () => {
  const cards = document.querySelectorAll('.card-lead');
  if (cards) {
    cards.forEach(addEventOnClick);
  }
};

export { toggleCardsLeadsDetailsOnClick };
