function UrbanAirship(){
    
    push = window.pushNotification
    
    //alert("push done!!")
    
    // Reset Badge on resume
    document.addEventListener("resume", function() {
                              push.resetBadge()
                              })
    
    push.getIncoming(function (incoming) {
                     if(incoming.message) {
                     console.log("Incoming push: " + incoming.message)
                     } else {
                     console.log("No incoming message")
                     }
                     })
    
    function on_push(data) {
        console.log("Received push: " + data.message)
    }
    
    function on_reg(error, pushID) {
        if (!error) {
            console.log("Reg Success: " + pushID)
            $('#id').text(pushID)
        }
    }
    
    push.registerEvent('registration', on_reg)
    
    push.registerEvent('push', on_push)
    
    push.enablePush()
    push.enableLocation()
    

    push.registerForNotificationTypes(push.notificationType.badge | push.notificationType.sound | push.notificationType.alert)

    
    
    function add_tag(tag) {
        $('#tags').prepend("<p>" + tag + "<input type='button' class='removeTagButton' value='Remove' /></p>")
        //This needs to be here because the element doesn't exist at load.
        $(".removeTagButton").on("click", function(ev) {
                                 p = $(ev.target).parent()
                                 tag = p.text()
                                 p.remove()
                                 push.getTags(function(obj) {
                                              console.log("Removing tag: " + tag)
                                              obj.tags.splice(obj.tags.indexOf(tag), 1)
                                              push.setTags(obj.tags)
                                              })
                                 })
    }
    
    function set_alias(alias) {
        $("#alias").text(alias)
        $("#setAliasField").val("")
    }
    
    push.isPushEnabled(function(has_push) {
                       if (has_push) {
                       $('#toggle').val('on').change();
                       } else {
                       $('#toggle').val('off').change();
                       }
                       })
    
    push.isSoundEnabled(function(has_sound) {
                        if (has_sound) {
                        $('#soundEnabled').val('on').change();
                        } else {
                        $('#soundEnabled').val('off').change();
                        }
                        })
    
    push.isVibrateEnabled(function(has_vibrate) {
                          if (has_vibrate) {
                          $('#vibrateEnabled').val('on').change();
                          } else {
                          $('#vibrateEnabled').val('off').change();
                          }
                          })
    
    push.isQuietTimeEnabled(function(has_quiettime) {
                            if (has_quiettime) {
                            $('#quietTimeEnabled').val('on').change();
                            } else {
                            $('#quietTimeEnabled').val('off').change();
                            }
                            })
    
    push.isLocationEnabled(function(enabled) {
                           if (enabled) {
                           $('#locationEnabled').val('on').change();
                           } else {
                           $('#locationEnabled').val('off').change();
                           }
                           })
    
    $('#toggle').change(function() {
                             if ($('#toggle').val() == "on") {
                             // This means we want to turn it on
                             alert("bingo")
                             push.enablePush()
                             } else {
                             push.disablePush()
                             }
                             })
    
    $('#soundEnabled').change(function() {
                              if ($('#soundEnabled').val() == "on") {
                              //This means we want to turn it on
                              push.setSoundEnabled(true)
                              } else {
                              push.setSoundEnabled(false)
                              }
                              })
    
    $('#vibrateEnabled').change(function() {
                                if ($('#vibrateEnabled').val() == "on") {
                                //This means we want to turn it on
                                push.setVibrateEnabled(true)
                                } else {
                                push.setVibrateEnabled(false)
                                }
                                })
    
    $('#quietTimeEnabled').change(function() {
                                  if ($('#quietTimeEnabled').val() == "on") {
                                  //This means we want to turn it on
                                  push.setQuietTimeEnabled(true)
                                  } else {
                                  push.setQuietTimeEnabled(false)
                                  }
                                  })
    
    $('#locationEnabled').change(function() {
                                 if ($('#locationEnabled').val() == "on") {
                                 //This means we want to turn it on
                                 push.enableLocation()
                                 } else {
                                 push.disableLocation()
                                 }
                                 })
    
    $("#addTagButton").click(function(ev) {
                             var new_tag = $("#addTagField").val()
                             console.log("Adding new tag: " + new_tag)
                             push.getTags(function(obj) {
                                          if (obj.tags.indexOf(new_tag) == -1) {
                                          console.log("Valid tag: " + new_tag)
                                          obj.tags = obj.tags.concat([new_tag])
                                          push.setTags(obj.tags, function() {
                                                       add_tag(new_tag)
                                                       $("#addTagField").val('')
                                                       })
                                          }
                                          })
                             })
    
    $("#setQuietTimeButton").click(function(ev) {
                                   var startHour = parseInt($("#startHour").val())
                                   var startMinute = parseInt($("#startMinute").val())
                                   var endHour = parseInt($("#endHour").val())
                                   var endMinute = parseInt($("#endMinute").val())
                                   
                                   push.setQuietTime(startHour, startMinute, endHour, endMinute, function() {
                                                     console.log("Set quiet time from JS")
                                                     })
                                   })
    
    $("#setAliasButton").click(function(ev) {
                               var new_alias = $("#setAliasField").val()
                               push.setAlias(new_alias, function() {
                                             set_alias(new_alias)
                                             })
                               })
    
    push.getPushID(function (id) {
                   if(id) {
                   console.log("Got push ID: " + id)
                   $('#id').text(id)
                   }
                   })
    
    push.getAlias(function (alias) {
                  if(alias) {
                  console.log("Got alias: " + alias)
                  set_alias(alias)
                  } else {
                  console.log("No alias");
                  }
                  })
    
    push.getTags(function(obj) {
                 obj.tags.forEach(function(tag) {
                                  add_tag(tag)
                                  })
                 })
    
    push.getQuietTime(function(obj) {
                      $("#startHour").val(obj.startHour)
                      $("#startMinute").val(obj.startMinute)
                      $("#endHour").val(obj.endHour)
                      $("#endMinute").val(obj.endMinute)
                      })
    
    
    
    if (device.platform != "Android") {
        $("#soundEnabledSection").hide();
        $("#vibrateEnabledSection").hide();
    }
}