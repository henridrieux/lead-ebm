const toggleActiveClass = (event) => {
  console.log(event)
  event.currentTarget.classList.toggle('active');
};

const toggleActiveOnClick = (target) => {
  console.log(target)
  target.addEventListener('click', toggleActiveClass);
};

function activateToggleOnClick(targetsClass) {
  console.log(targetsClass)
  const targets = document.querySelectorAll(targetsClass);
  console.log(targets)
  if (targets) {
    targets.forEach(toggleActiveOnClick);
  }
}

export { activateToggleOnClick };
