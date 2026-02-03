$(function () {
  $("#send").on("click", function () {
    if (!$("#nombre").val() || !$("#email").val()) {
      alertify.error("Hombre, digo yo que el nombre y el email por lo menos ya me dirás, ¿no?");
      return;
    }

    $.ajax({
      type: "POST",
      url: "/contacto",
      data: {
        _method: "put",
        name: $("#nombre").val(),
        email: $("#email").val(),
        address: $("#address").val(),
        comments: $("#comments").val(),
      },
      complete: function (data) {
        $("#pedirLibro").foundation("reveal", "close");
        alertify.alert(data.responseText);
      },
    });
  });

  $("#pedir").hover(
    function () {
      $(this).addClass("rubberBand");
    },
    function () {
      $(this).removeClass("rubberBand");
    }
  );

  $("#aqui").hover(
    function () {
      $(this).addClass("shake");
    },
    function () {
      $(this).removeClass("shake");
    }
  );

  setInterval(function () {
    $("#reacciones").removeClass("bounceInRight").toggleClass("tada");
  }, 5000);
});
