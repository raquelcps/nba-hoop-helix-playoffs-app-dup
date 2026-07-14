(function () {

  function showLoader() {
    console.log("Showing loader...");
    var loader = document.getElementById("page-loader");

    if (loader) {
      loader.classList.add("page-loader--visible");
    }
  }

  function hideLoader() {
    console.log("Hiding loader...");
    var loader = document.getElementById("page-loader");

    if (loader) {
      loader.classList.remove("page-loader--visible");
    }
  }


  function bindRoundForms() {
    console.log("Binding playoff round forms...");
    document.querySelectorAll(".playoff-round-form").forEach(function(form) {
      form.addEventListener("submit", function() {
        setLoaderMessage("Loading it UPUP");
        showLoader();
      });

      var select = form.querySelector("select");

      if (select) {
        select.addEventListener("change", function() {
          setLoaderMessage("Loading it UPUP");
          showLoader();
          form.submit();
        });
      }

    });
  }

  function setLoaderMessage(text) {
    
    var title = document.querySelector(".page-loader__title");

    if (title) {
      title.textContent = text;
    }
  } 

  


  //
  // Turbolinks
  //

  document.addEventListener("turbolinks:request-start", showLoader);
  document.addEventListener("turbolinks:load", hideLoader);
  document.addEventListener("turbolinks:load", function() {
    hideLoader();
    bindRoundForms();
  });

  //
  // Normal browser navigation
  //

  window.addEventListener("beforeunload", showLoader);

  window.addEventListener("load", hideLoader);

})();
