$(document).ready(function(){

  var active = $("#onButton").attr("checked");
  $("#subject-and-message").attr("hidden", !active);

  $("#offButton").click(function(){
    $("#subject-and-message").hide(500);
  });

  $("#onButton").click(function(){
    $("#subject-and-message").show(500);
  });

});