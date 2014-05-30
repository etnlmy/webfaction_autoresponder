function toggleInputFieldsValidation(active){
  $("#subjectField").attr("required", active);
  $("#messageField").attr("required", active);
}

$(document).ready(function(){

  var active = $("#onButton").attr("checked");
  $("#subject-and-message").attr("hidden", !active);
  toggleInputFieldsValidation(active);

  $("#offButton").click(function(){
    $("#subject-and-message").hide(500);
    toggleInputFieldsValidation(false);
  });

  $("#onButton").click(function(){
    $("#subject-and-message").show(500);
    toggleInputFieldsValidation(true);
  });

});