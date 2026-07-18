document.addEventListener("turbolinks:load", () => {
  const searchInput = document.getElementById("roster-search");
  if (!searchInput) return;

  const rosterPlayers = document.querySelectorAll(".roster-player");

  const filterRoster = () => {
    const query = searchInput.value.trim().toLowerCase();

    rosterPlayers.forEach(player => {
      const name = player.dataset.playerName || "";
      player.style.display = name.includes(query) ? "" : "none";
    });
  };

  searchInput.addEventListener("input", filterRoster);
  searchInput.addEventListener("search", filterRoster);
});
