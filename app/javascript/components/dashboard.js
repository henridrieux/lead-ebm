const initUpdateDashboardViewsOnClick = () => {
  const sidebar = document.querySelector('.side-bar');
  if (sidebar) {
    viewOver = document.querySelector('.over-btn');
    viewAbo = document.querySelector('.abo-btn');
    viewLead = document.querySelector('.lead-btn');

    viewOver.addEventListener('click', () => {
      viewOver.classList.add('active');
      viewAbo.classList.remove('active');
      viewLead.classList.remove('active');
    });

    viewAbo.addEventListener('click', () => {
      viewOver.classList.remove('active');
      viewAbo.classList.add('active');
      viewLead.classList.remove('active');
    });

    viewLead.addEventListener('click', () => {
      viewOver.classList.remove('active');
      viewAbo.classList.remove('active');
      viewLead.classList.add('active');
    });
}


export { initUpdateDashboardViewsOnClick };
