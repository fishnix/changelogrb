$(document).ready(function() 
{
  $("#addform").submit(function(e) {
    e.preventDefault();  // stops the submit request
    
    // parse form parameters
    var cl_criticality = $("#cl_criticality").val();
    var cl_user = $("#cl_user").val();
    var cl_hostname = $("#cl_hostname").val();
    var cl_description = $("#cl_description").val();
    var cl_body = btoa($("#cl_body").val()); // base64-encode the body
    // make into JSON
    formjson = '{"user": "' + cl_user + '", "hostname": "' + cl_hostname + '", "criticality": ' + cl_criticality + ', "description": "' + cl_description + '", "body": "' + cl_body + '"}' 
    console.log(formjson);
  
    $.ajax({
      type: 'POST',
      url: '/api/add',
      data: formjson,
      dataType: 'json',
      success: function(data, textStatus, jqXHR) { 
        $("#divmsg").html("");
        var response = JSON.parse(jqXHR.responseText);
        if (response.status == 200) {
          $("#divmsg").append('<div class="alert alert-success"><strong>Change record successfully submitted!</strong></div>');
        } else {
          $("#divmsg").append('<div class="alert alert-danger"><strong>Error submitting request!</strong><br>' + response.status + ': ' + response.message + '</div>');
        }
      },
      error: function(jqXHR, textStatus, errorThrown) { 
        console.log(jqXHR.responseText);
        $("#divmsg").html('<div class="alert alert-danger"><strong>Error processing request!</strong><br>' +  errorThrown + '</div>');
      },
  //    success: function(data) { console.log("Success!<br>" + data) },
  //    error: function(data) { console.log("Failed!<br>" + data) },
      contentType: "application/json"
    });
  });
});
