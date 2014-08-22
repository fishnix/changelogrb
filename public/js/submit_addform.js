$(document).ready(function() 
{
  $("#addform").submit(function(e) {
    e.preventDefault();  // stops the submit request
    
    // parse form parameters
    var cl_token = $("#cl_token").val();
    var cl_criticality = $("#cl_criticality").val();
    var cl_user = $("#cl_user").val();
    var cl_date = $("#cl_date").val();
    var cl_time = $("#cl_time").val();
    var cl_tag = $("#cl_tag").val();
    var cl_hostname = $("#cl_hostname").val();
    var cl_description = $("#cl_description").val();
    var cl_body = btoa($("#cl_body").val()); // base64-encode the body
    // make into JSON
    formjson = '{"token": "' + cl_token + 
               '", "date": "' + cl_date + 
               '", "time": "' + cl_time + 
               '", "user": "' + cl_user + 
               '", "tag": "' + cl_tag + 
               '", "hostname": "' + cl_hostname + 
               '", "criticality": ' + cl_criticality + 
               ', "description": "' + cl_description + 
               '", "body": "' + cl_body + '"}' 
    // log to js console
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
          // clear the hostname on success
          $("#cl_hostname").val("");
        } else {
          $("#divmsg").append('<div class="alert alert-danger"><strong>Error submitting request!</strong><br>' + response.status + ': ' + response.message + '</div>');
        }
      },
      error: function(jqXHR, textStatus, errorThrown) { 
        console.log(jqXHR.responseText);
        $("#divmsg").html('<div class="alert alert-danger"><strong>Error processing request!</strong><br>' +  errorThrown + '</div>');
      },
      contentType: "application/json"
    });
  });
});
