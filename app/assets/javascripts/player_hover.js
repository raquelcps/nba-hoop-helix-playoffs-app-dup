document.addEventListener("turbolinks:load", () => {
  initializePlayerSelection();
});


function initializePlayerSelection() {
  const rosterPlayers = document.querySelectorAll(".roster-player");

  if (!rosterPlayers.length) return;


  const selection = {
    hoveredPlayerId: null,
    pinnedPlayerId: null
  };


  const renderSelection = () => {
    const activePlayerId =
      selection.hoveredPlayerId || selection.pinnedPlayerId;


    // Clear all existing highlights
    document
      .querySelectorAll("[data-player-id]")
      .forEach((element) => {
        element.classList.remove("player-highlight");
      });


    // Clear pinned states
    document
      .querySelectorAll(".roster-player")
      .forEach((player) => {
        player.classList.remove("is-pinned");
      });


    document
      .querySelectorAll(".roster-player-pin")
      .forEach((button) => {
        button.classList.remove("is-pinned");
        button.setAttribute("aria-pressed", "false");
      });


    if (!activePlayerId) return;


    // Highlight active player's rows
    document
      .querySelectorAll(`[data-player-id="${activePlayerId}"]`)
      .forEach((element) => {
        element.classList.add("player-highlight");
      });


    // Restore pinned UI state
    if (selection.pinnedPlayerId) {
      const pinnedPlayer = document.querySelector(
        `.roster-player[data-player-id="${selection.pinnedPlayerId}"]`
      );

      if (pinnedPlayer) {
        pinnedPlayer.classList.add("is-pinned");

        const pinButton =
          pinnedPlayer.querySelector(".roster-player-pin");

        if (pinButton) {
          pinButton.classList.add("is-pinned");
          pinButton.setAttribute("aria-pressed", "true");
        }
      }
    }
  };


  rosterPlayers.forEach((rosterPlayer) => {

    const actions =
      rosterPlayer.querySelector(".roster-player-actions");

    const pinButton =
      rosterPlayer.querySelector(".roster-player-pin");


    if (!actions || !pinButton) return;


    const playerId = rosterPlayer.dataset.playerId;


    //
    // Temporary inspection
    //
    rosterPlayer.addEventListener("mouseenter", (event) => {
      if (actions.contains(event.relatedTarget)) return;

      selection.hoveredPlayerId = playerId;
      renderSelection();
    });


    rosterPlayer.addEventListener("mouseleave", (event) => {
      if (actions.contains(event.relatedTarget)) return;

      selection.hoveredPlayerId = null;
      renderSelection();
  });


    //
    // Persistent pin
    //
    pinButton.addEventListener("click", (event) => {
      event.stopPropagation();


      if (selection.pinnedPlayerId === playerId) {
        selection.pinnedPlayerId = null;
      } else {
        selection.pinnedPlayerId = playerId;
      }


      renderSelection();
    });

  });

}
