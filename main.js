Parse.Cloud.define("updateNotificationId", async(request) => {
    const attributes = request.params.attributes;
    const yearOfBirth = request.params.yearOfBirth;
  
    const query = new Parse.Query("task");  
    query.descending('notificationId');
    const results = await query.find();
  
    for (let i = 0; i < results.length; i++) {
      let object = results[i];
      object.add("attributes", attributes);
      try{
        await object.save();
      } catch (e){
        console.log(`Error while trying to save ${object.id}. Message: ${e.message}`)
      }
    }
  
    return results
  });