
const initUpdateDashboardViewsOnClick = () => {
  const sidebar = document.querySelector('.side-bar');
  console.log(sidebar);
  if (sidebar) {
    const viewOver = document.querySelector('.over-btn');
    const viewAbo = document.querySelector('.abo-btn');
    const viewLead = document.querySelector('.lead-btn');
    const boxOver = document.querySelector('.overview');
    const boxAbo = document.querySelector('.abonnement');
    const boxLead = document.querySelector('.lead');
    boxAbo.hidden = true;
    boxLead.hidden = true;

    viewOver.addEventListener('click', () => {
      viewOver.classList.add('active');
      viewAbo.classList.remove('active');
      viewLead.classList.remove('active');
      boxOver.hidden = false;
      boxAbo.hidden = true;
      boxLead.hidden = true;
    });

    viewAbo.addEventListener('click', () => {
      viewOver.classList.remove('active');
      viewAbo.classList.add('active');
      viewLead.classList.remove('active');
      boxOver.hidden = true;
      boxAbo.hidden = false;
      boxLead.hidden = true;
    });

    viewLead.addEventListener('click', () => {
      console.log(viewLead);
      viewOver.classList.remove('active');
      viewAbo.classList.remove('active');
      viewLead.classList.add('active');
      boxOver.hidden = true;
      boxAbo.hidden = true;
      boxLead.hidden = false;
    });
  }
}

export { initUpdateDashboardViewsOnClick };
