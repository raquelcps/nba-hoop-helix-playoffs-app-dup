function onResize() {
  updateResponsiveLayout();
}

document.addEventListener("turbolinks:load", () => {
  initializeCategoryCards();
  initializeResponsiveRoster();

  window.removeEventListener("resize", onResize);
  window.addEventListener("resize", onResize);

  updateCategoryCardLayout();
});

function updateResponsiveLayout() {
  updateCategoryCardLayout();
  initializeResponsiveRoster();
}

function initializeCategoryCards() {
  document.querySelectorAll(".category-card").forEach(card => {
    if (card.dataset.initialized === "true") return;

    card.dataset.initialized = "true";
    card.dataset.expanded = "false";

    const button = card.querySelector(".category-card-expand");

    button.addEventListener("click", () => {
      const expanded = card.dataset.expanded === "true";

      card.dataset.expanded = (!expanded).toString();

      updateSingleCategoryCard(card);
    });
  });
}

function updateCategoryCardLayout() {
  document.querySelectorAll(".category-card").forEach(updateSingleCategoryCard);
}

function updateSingleCategoryCard(card) {
  const mobile = window.matchMedia("(max-width: 991.98px)").matches;

  const visibleRows = mobile ? 3 : 5

  const rows = card.querySelectorAll(".category-card-row");
  const button = card.querySelector(".category-card-expand");
  const expanded = card.dataset.expanded === "true";

  rows.forEach((row, index) => {
    row.hidden = !expanded && index >= visibleRows;
  });

  button.querySelector(".expand-text").textContent =
    expanded ? "Show less" : "Full roster contributions";

  button.setAttribute("aria-expanded", expanded);
}


function initializeResponsiveRoster() {
  const roster = document.getElementById("teamRosterCollapse");

  if (!roster) return;

  const collapse = bootstrap.Collapse.getOrCreateInstance(roster, {
    toggle: false
  });

  const mobile = window.matchMedia("(max-width: 991.98px)").matches;
  const expanded = roster.classList.contains("show");

  if (mobile && expanded) {
    collapse.hide();
  } else if (!mobile && !expanded) {
    collapse.show();
  }
}
