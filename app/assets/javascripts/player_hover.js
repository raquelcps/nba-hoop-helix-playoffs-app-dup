document.addEventListener("turbolinks:load", () => {
  const rosterPlayers = document.querySelectorAll(".roster-player");

  rosterPlayers.forEach((rosterPlayer) => {
    rosterPlayer.addEventListener("mouseenter", () => {
      const id = rosterPlayer.dataset.playerId;

      document
        .querySelectorAll(`[data-player-id="${id}"]`)
        .forEach((el) => el.classList.add("player-highlight"));
    });

    rosterPlayer.addEventListener("mouseleave", () => {
      const id = rosterPlayer.dataset.playerId;

      document
        .querySelectorAll(`[data-player-id="${id}"]`)
        .forEach((el) => el.classList.remove("player-highlight"));
    });
  });
});
